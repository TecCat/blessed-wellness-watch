"""
WellnessWatch AI Coach API — pytest 測試套件
使用 httpx + unittest.mock 進行端點與邏輯測試
"""

import json
from unittest.mock import MagicMock, patch

import pytest
from httpx import AsyncClient

from coach_api import app, suggest_next, SessionFeedbackRequest


# ──────────────────────────────────────────────
# 測試輔助：建立最小請求資料
# ──────────────────────────────────────────────

def minimal_request(**overrides) -> dict:
    """回傳最小合法的請求 payload（無生理數據）。"""
    base = {
        "pattern_id": "box",
        "pattern_name": "Box Breathing",
        "duration_seconds": 300.0,
        "completed_cycles": 5,
        "total_cycles": 5,
        "was_completed": True,
        "pace_label": "標準",
        "total_sessions": 3,
        "streak_days": 1,
    }
    base.update(overrides)
    return base


def full_request(**overrides) -> dict:
    """回傳包含完整生理數據的請求 payload。"""
    base = minimal_request()
    base.update({
        "heart_rate_before": 78.0,
        "heart_rate_after": 68.0,
        "hrv_ms": 42.5,
        "stress_level": "輕度緊張",
        "total_sessions": 10,
        "streak_days": 5,
    })
    base.update(overrides)
    return base


# ──────────────────────────────────────────────
# Mock Claude API 回應
# ──────────────────────────────────────────────

def make_mock_claude_response(feedback: str = "數據顯示心率明顯下降，這次練習效果不錯。") -> MagicMock:
    """建立模擬的 Claude API 回應物件。"""
    mock_response = MagicMock()
    mock_response.content = [MagicMock()]
    mock_response.content[0].text = json.dumps({
        "feedback": feedback,
        "next_pattern_id": "resonance",
        "next_duration_minutes": 10,
        "next_pace": "標準",
        "next_reason": "繼續提升 HRV",
        "achievement": None,
    })
    return mock_response


# ──────────────────────────────────────────────
# Test 1: GET /health
# ──────────────────────────────────────────────

@pytest.mark.asyncio
async def test_health_endpoint():
    """健康檢查端點應回傳 200 與正確的 JSON 結構。"""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/health")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "model" in data


# ──────────────────────────────────────────────
# Test 2: POST /api/session-feedback（無生理數據）
# ──────────────────────────────────────────────

@pytest.mark.asyncio
@patch("coach_api.anthropic.Anthropic")
async def test_feedback_without_biometrics(mock_anthropic_class):
    """
    無 HealthKit 生理數據時，API 應成功回傳 general 信心等級的回饋。
    """
    # 設定 mock：Anthropic client.messages.create 回傳模擬回應
    mock_client = MagicMock()
    mock_client.messages.create.return_value = make_mock_claude_response(
        "每次練習都在累積效果，持續下去是最好的方式。"
    )
    mock_anthropic_class.return_value = mock_client

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/session-feedback",
            json=minimal_request(),
        )

    assert response.status_code == 200
    data = response.json()

    assert "feedback" in data
    assert len(data["feedback"]) <= 100
    assert "next_suggestion" in data
    assert data["next_suggestion"]["pattern_id"] in [
        "box", "4-7-8", "diaphragmatic", "resonance", "physiological-sigh"
    ]
    # 無生理數據 → 信心等級應為 general
    assert data["coach_confidence"] == "general"


# ──────────────────────────────────────────────
# Test 3: POST /api/session-feedback（有完整生理數據）
# ──────────────────────────────────────────────

@pytest.mark.asyncio
@patch("coach_api.anthropic.Anthropic")
async def test_feedback_with_biometrics(mock_anthropic_class):
    """
    有心率與 HRV 數據時，API 應回傳 data-based 信心等級的回饋。
    """
    mock_client = MagicMock()
    mock_client.messages.create.return_value = make_mock_claude_response(
        "數據顯示心率從 78 降至 68 bpm，副交感神經系統明顯活化。"
    )
    mock_anthropic_class.return_value = mock_client

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/session-feedback",
            json=full_request(),
        )

    assert response.status_code == 200
    data = response.json()

    assert "feedback" in data
    assert len(data["feedback"]) <= 100
    # 有生理數據 → 信心等級應為 data-based
    assert data["coach_confidence"] == "data-based"
    assert "next_suggestion" in data
    next_s = data["next_suggestion"]
    assert next_s["duration_minutes"] > 0
    assert next_s["pace_label"] in ["慢", "標準", "快"]


# ──────────────────────────────────────────────
# Test 4: 第一次練習觸發成就
# ──────────────────────────────────────────────

@pytest.mark.asyncio
@patch("coach_api.anthropic.Anthropic")
async def test_achievement_first_session(mock_anthropic_class):
    """
    total_sessions=1 時，回應應包含「第一次練習」成就訊息。
    """
    mock_client = MagicMock()
    mock_client.messages.create.return_value = make_mock_claude_response()
    mock_anthropic_class.return_value = mock_client

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/session-feedback",
            json=minimal_request(total_sessions=1),
        )

    assert response.status_code == 200
    data = response.json()
    assert data["achievement"] is not None
    assert "第一次練習" in data["achievement"]


# ──────────────────────────────────────────────
# Test 5: suggest_next fallback 邏輯
# ──────────────────────────────────────────────

def test_next_suggestion_fallback():
    """
    直接測試 suggest_next() fallback 函式的三條邏輯分支。
    """
    # 分支 A：高度緊張 → 建議腹式呼吸 + 慢速
    req_high_stress = SessionFeedbackRequest(
        pattern_id="box",
        pattern_name="Box Breathing",
        duration_seconds=300,
        completed_cycles=5,
        total_cycles=5,
        was_completed=True,
        pace_label="標準",
        stress_level="高度緊張",
    )
    result_a = suggest_next(req_high_stress)
    assert result_a.pattern_id == "diaphragmatic"
    assert result_a.pace_label == "慢"

    # 分支 B：已完成 + 快速 → 維持相同模式 + 快速
    req_fast_done = SessionFeedbackRequest(
        pattern_id="4-7-8",
        pattern_name="4-7-8 Breathing",
        duration_seconds=240,
        completed_cycles=4,
        total_cycles=4,
        was_completed=True,
        pace_label="快",
    )
    result_b = suggest_next(req_fast_done)
    assert result_b.pattern_id == "4-7-8"
    assert result_b.pace_label == "快"

    # 分支 C：預設 → 相同模式 + 標準
    req_default = SessionFeedbackRequest(
        pattern_id="resonance",
        pattern_name="Resonance Breathing",
        duration_seconds=600,
        completed_cycles=6,
        total_cycles=6,
        was_completed=True,
        pace_label="標準",
    )
    result_c = suggest_next(req_default)
    assert result_c.pattern_id == "resonance"
    assert result_c.pace_label == "標準"
