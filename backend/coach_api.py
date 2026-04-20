"""
WellnessWatch AI Coach API
FastAPI + Claude API — 練習後個人化回饋
部署目標：Railway 或 Render（免費方案）
"""

import json
import os
import time
from collections import defaultdict
from typing import Optional

import anthropic
import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# 載入環境變數
load_dotenv()

# ──────────────────────────────────────────────
# 常數與設定
# ──────────────────────────────────────────────

MODEL = "claude-opus-4-5"  # 任務指定的模型

# AI Coach 人設 Prompt（verbatim，請勿修改）
COACH_SYSTEM_PROMPT = """你是 WellnessWatch 的 AI 健康教練。

人設與語氣：
- 溫暖、友善，像一位你信任的身心健康心理師
- 以數據與科學研究為依據做判斷，不說空泛的心靈雞湯
- 建議以正面鼓勵表達，不強求，不恐嚇，不誇大效果
- 當數據顯示進步時，具體指出哪個指標改善，說明科學原因
- 當數據沒有明顯變化時，正常化這個情況（「每次練習都有累積效果」），而非假裝有進步
- 字數限制：繁體中文，100字以內（Apple Watch 螢幕空間有限）
- 不使用「太棒了！」「超厲害！」等誇張詞彙
- 可以使用的語氣：「不錯」「值得注意」「這很正常」「建議你」「數據顯示」

回覆語言規則：
- 若 locale 為 "en" 或 "en-US"，所有回覆（feedback、next_reason）必須用英文
- 其他 locale 一律用繁體中文"""

# 成就里程碑
ACHIEVEMENTS = {
    1:   "第一次練習 🌱",
    7:   "連續 7 天 🔥",
    30:  "30 次練習 ⭐",
    50:  "50 次達成 💫",
    100: "百次正念師 🏆",
}

# Rate limiting：每分鐘最多 20 次請求（in-memory，簡易版本）
_rate_limit_store: dict[str, list[float]] = defaultdict(list)
RATE_LIMIT_MAX = 20
RATE_LIMIT_WINDOW = 60  # 秒


# ──────────────────────────────────────────────
# Pydantic 資料模型
# ──────────────────────────────────────────────

class HistorySummary(BaseModel):
    """User's historical performance summary passed from the Watch app."""
    avg_duration_seconds: float = 0      # average session length across all past sessions
    avg_completion_rate: float = 0       # 0.0–1.0, avg(completed_cycles / total_cycles)
    sessions_this_week: int = 0          # sessions completed in last 7 days
    sessions_last_week: int = 0          # sessions completed in the 7 days before that
    avg_pace_label: str = "標準"         # most common pace used
    most_used_pattern_id: str = ""       # most frequently used pattern


class NextSuggestion(BaseModel):
    pattern_id: str
    pattern_name: str
    duration_minutes: int
    pace_label: str
    reason: str  # ≤30 字


class SessionFeedbackRequest(BaseModel):
    # 練習基本資料
    pattern_id: str           # "box", "4-7-8", "diaphragmatic", "resonance", "physiological-sigh"
    pattern_name: str         # "Box Breathing"
    duration_seconds: float   # 實際經過秒數
    completed_cycles: int
    total_cycles: int
    was_completed: bool       # 正常結束 vs 提前停止
    pace_label: str           # "慢" / "標準" / "快"

    # 生理數據（可能因 HealthKit 未授權而缺席）
    heart_rate_before: Optional[float] = None
    heart_rate_after: Optional[float] = None
    hrv_ms: Optional[float] = None
    stress_level: Optional[str] = None  # "放鬆" / "輕度緊張" / "高度緊張" / "測量中..."

    # 使用者歷史（匿名）
    total_sessions: int = 0
    streak_days: int = 0

    # 歷史比較數據
    history: Optional[HistorySummary] = None

    # 語言設定
    locale: str = "zh-TW"


class SessionFeedbackResponse(BaseModel):
    feedback: str                          # ≤100 繁體中文字
    next_suggestion: NextSuggestion        # 下次建議
    achievement: Optional[str] = None     # 里程碑訊息（如適用）
    coach_confidence: str                  # "data-based" | "general"


# ──────────────────────────────────────────────
# FastAPI 應用程式初始化
# ──────────────────────────────────────────────

app = FastAPI(
    title="WellnessWatch AI Coach API",
    description="練習後個人化 AI 教練回饋 — by WellnessWatch",
    version="1.0.0",
)

# CORS：允許所有來源（Watch App 整合需要）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ──────────────────────────────────────────────
# 工具函式
# ──────────────────────────────────────────────

def check_rate_limit(client_ip: str) -> bool:
    """
    簡易 in-memory rate limiting。
    回傳 True 代表通過（可繼續），False 代表超限。
    """
    now = time.time()
    window_start = now - RATE_LIMIT_WINDOW
    requests = _rate_limit_store[client_ip]

    # 清除過期記錄
    _rate_limit_store[client_ip] = [t for t in requests if t > window_start]

    if len(_rate_limit_store[client_ip]) >= RATE_LIMIT_MAX:
        return False

    _rate_limit_store[client_ip].append(now)
    return True


def get_achievement(total_sessions: int) -> Optional[str]:
    """根據 total_sessions 判斷是否觸發成就。"""
    return ACHIEVEMENTS.get(total_sessions)


def suggest_next(req: SessionFeedbackRequest) -> NextSuggestion:
    """
    Fallback 邏輯：當 Claude 回傳無法解析的 JSON 時使用。
    規則：
    - 高度緊張 → 慢速、較長練習
    - 已完成且快速步調 → 維持快速
    - 其他 → 相同模式、標準步調
    """
    is_en = req.locale.startswith("en")

    # 呼吸模式對應表（pattern_id → 預設時長分鐘）
    duration_map = {
        "box": 5,
        "4-7-8": 4,
        "diaphragmatic": 5,
        "resonance": 10,
        "physiological-sigh": 5,
    }

    reason_high_stress = "Slow breathing helps with high stress" if is_en else "壓力較高，慢速腹式呼吸更舒緩"
    reason_keep_fast = "Good state, keep it up" if is_en else "狀態不錯，繼續保持"
    reason_default = "Consistent practice builds results" if is_en else "每次練習都在累積效果"

    if req.stress_level in ("高度緊張", "high"):
        # 高壓 → 建議較溫和的模式，慢速
        return NextSuggestion(
            pattern_id="diaphragmatic",
            pattern_name="Diaphragmatic Breathing",
            duration_minutes=5,
            pace_label="慢" if not is_en else "Slow",
            reason=reason_high_stress,
        )

    if req.was_completed and req.pace_label in ("快", "Fast", "fast"):
        # 已完成 + 快速 → 繼續挑戰
        return NextSuggestion(
            pattern_id=req.pattern_id,
            pattern_name=req.pattern_name,
            duration_minutes=duration_map.get(req.pattern_id, 5),
            pace_label=req.pace_label,
            reason=reason_keep_fast,
        )

    # 預設：相同模式、標準步調
    return NextSuggestion(
        pattern_id=req.pattern_id,
        pattern_name=req.pattern_name,
        duration_minutes=duration_map.get(req.pattern_id, 5),
        pace_label="標準" if not is_en else "Normal",
        reason=reason_default,
    )


def build_user_message(req: SessionFeedbackRequest) -> str:
    """
    將 Session 資料格式化成給 Claude 的 user message。
    """
    has_biometrics = req.heart_rate_before is not None or req.hrv_ms is not None
    duration_min = round(req.duration_seconds / 60, 1)

    lines = [
        "請根據以下練習數據，以 JSON 格式回傳教練意見。",
        "",
        "## 練習資料",
        f"用戶語言設定：{req.locale}",
        "",
        f"- 呼吸模式：{req.pattern_name}（{req.pattern_id}）",
        f"- 實際時長：{duration_min} 分鐘",
        f"- 完成輪數：{req.completed_cycles} / {req.total_cycles}",
        f"- 是否正常完成：{'是' if req.was_completed else '提前結束'}",
        f"- 步調：{req.pace_label}",
        "",
    ]

    if has_biometrics:
        lines.append("## 生理數據（已取得）")
        if req.heart_rate_before is not None:
            lines.append(f"- 練習前心率：{req.heart_rate_before:.0f} bpm")
        if req.heart_rate_after is not None:
            lines.append(f"- 練習後心率：{req.heart_rate_after:.0f} bpm")
        if req.hrv_ms is not None:
            lines.append(f"- HRV（SDNN）：{req.hrv_ms:.1f} ms")
        if req.stress_level:
            lines.append(f"- 壓力狀態：{req.stress_level}")
    else:
        lines.append("## 生理數據：無（HealthKit 未授權）")
        lines.append("## 歷史比較數據（請根據這些比較，判斷用戶是否有進步）")
        if req.history and req.history.avg_duration_seconds > 0:
            current_duration = req.duration_seconds
            avg_duration = req.history.avg_duration_seconds
            duration_change_pct = ((current_duration - avg_duration) / avg_duration) * 100

            current_ratio = req.completed_cycles / max(req.total_cycles, 1)
            avg_ratio = req.history.avg_completion_rate

            lines.append(f"- 本次時長：{round(current_duration/60, 1)} 分鐘 vs 歷史平均 {round(avg_duration/60, 1)} 分鐘（{'+' if duration_change_pct >= 0 else ''}{duration_change_pct:.0f}%）")
            lines.append(f"- 本次完成率：{current_ratio*100:.0f}% vs 歷史平均 {avg_ratio*100:.0f}%")
            lines.append(f"- 本週練習次數：{req.history.sessions_this_week} 次 vs 上週 {req.history.sessions_last_week} 次")
            lines.append("")
            lines.append("判斷規則：")
            lines.append("- 若本次時長 > 歷史平均 且 完成率 > 歷史平均 → 有進步，以正面鼓勵表達")
            lines.append("- 若時長或完成率明顯下降（>15%）→ 給予注意提示（不責備，說可能原因）")
            lines.append("- 若差距在 ±15% 內 → 屬正常波動，肯定持續練習即可")
        else:
            lines.append("- 這是用戶的第一次或早期練習，無足夠歷史數據比較")
            lines.append("- 請以鼓勵初學者的語氣給予建議")

    lines += [
        "",
        "## 使用者歷史",
        f"- 累計練習次數：{req.total_sessions} 次",
        f"- 連續天數：{req.streak_days} 天",
        "",
        "## 回傳格式（只回傳有效 JSON，不要加其他文字）",
        "```json",
        "{",
        '  "feedback": "（100字以內的繁體中文教練回饋）",',
        '  "next_pattern_id": "（建議下次的 pattern_id）",',
        '  "next_duration_minutes": （整數分鐘）,',
        '  "next_pace": "（慢 / 標準 / 快）",',
        '  "next_reason": "（30字以內的繁體中文原因）",',
        '  "achievement": null',
        "}",
        "```",
    ]

    return "\n".join(lines)


# ──────────────────────────────────────────────
# API 端點
# ──────────────────────────────────────────────

@app.get("/health")
def health_check():
    """健康檢查端點（Railway / Render 部署用）。"""
    return {"status": "ok", "model": MODEL}


@app.post("/api/session-feedback", response_model=SessionFeedbackResponse)
async def session_feedback(req: SessionFeedbackRequest, request: Request):
    """
    接收練習後資料，呼叫 Claude API 產生個人化教練回饋。
    """
    # ── Rate limiting ──
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip):
        raise HTTPException(status_code=429, detail="請求過於頻繁，請稍後再試。")

    # ── 基本輸入驗證 ──
    if req.duration_seconds <= 0:
        raise HTTPException(status_code=400, detail="duration_seconds 必須大於 0。")
    if req.completed_cycles < 0 or req.total_cycles <= 0:
        raise HTTPException(status_code=400, detail="cycles 數值不合法。")

    # ── 成就判斷 ──
    achievement = get_achievement(req.total_sessions)

    # ── 是否有生理數據 ──
    has_biometrics = req.heart_rate_before is not None or req.hrv_ms is not None
    coach_confidence = "data-based" if has_biometrics else "general"

    # ── 呼叫 Claude API ──
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="伺服器設定錯誤：API 金鑰未設定。")

    try:
        client = anthropic.Anthropic(api_key=api_key)
        user_message = build_user_message(req)

        response = client.messages.create(
            model=MODEL,
            max_tokens=300,
            system=COACH_SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user_message}],
        )

        raw_text = response.content[0].text.strip()

        # 嘗試解析 JSON（Claude 可能夾帶 markdown code block）
        if "```" in raw_text:
            # 擷取 ```json ... ``` 或 ``` ... ``` 區塊
            import re
            match = re.search(r"```(?:json)?\s*([\s\S]*?)```", raw_text)
            if match:
                raw_text = match.group(1).strip()

        parsed = json.loads(raw_text)

        feedback = parsed.get("feedback", "每次練習都有累積效果，繼續保持。")
        next_pattern_id = parsed.get("next_pattern_id", req.pattern_id)
        next_duration = int(parsed.get("next_duration_minutes", 5))
        next_pace = parsed.get("next_pace", "標準")
        next_reason = parsed.get("next_reason", "持續練習")
        # 成就優先使用里程碑邏輯，Claude 回傳的 achievement 作為備用
        if not achievement:
            achievement = parsed.get("achievement")

        # 呼吸模式中文名稱對應表
        pattern_name_map = {
            "box": "Box Breathing",
            "4-7-8": "4-7-8 Breathing",
            "diaphragmatic": "Diaphragmatic Breathing",
            "resonance": "Resonance Breathing",
            "physiological-sigh": "Physiological Sigh",
        }

        next_suggestion = NextSuggestion(
            pattern_id=next_pattern_id,
            pattern_name=pattern_name_map.get(next_pattern_id, next_pattern_id),
            duration_minutes=next_duration,
            pace_label=next_pace,
            reason=next_reason[:30],  # 強制截斷至 30 字
        )

    except json.JSONDecodeError:
        # JSON 解析失敗 → 使用 fallback 建議
        next_suggestion = suggest_next(req)
        _is_en = req.locale.startswith("en")
        _fallback_default = "Every session builds results. Keep going." if _is_en else "每次練習都有累積效果，持續下去吧。"
        feedback = raw_text[:100] if 'raw_text' in dir() else _fallback_default

    except anthropic.APIError:
        # Claude API 錯誤 → 優雅降級，不暴露錯誤細節
        next_suggestion = suggest_next(req)
        _is_en = req.locale.startswith("en")
        feedback = "Each session builds a foundation for wellbeing. Keep it up." if _is_en else "每次練習都在為身心健康打下基礎，持續是最好的方式。"
        coach_confidence = "general"

    except Exception:
        # 其他未預期錯誤
        next_suggestion = suggest_next(req)
        _is_en = req.locale.startswith("en")
        feedback = "Keep up your practice rhythm — every breath session matters." if _is_en else "繼續保持練習節奏，每一次呼吸練習都有意義。"
        coach_confidence = "general"

    return SessionFeedbackResponse(
        feedback=feedback[:100],  # 強制 ≤100 字
        next_suggestion=next_suggestion,
        achievement=achievement,
        coach_confidence=coach_confidence,
    )


# ──────────────────────────────────────────────
# 直接執行入口
# ──────────────────────────────────────────────

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
