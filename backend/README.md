# WellnessWatch AI Coach Backend

FastAPI + Claude API 提供練習後個人化回饋。

---

## 本地開發 Local Development

```bash
# 1. 安裝依賴
pip install -r requirements.txt

# 2. 設定環境變數（複製範例檔後填入你的 API Key）
cp .env.example .env
# 編輯 .env，填入 ANTHROPIC_API_KEY=sk-ant-...

# 3. 啟動開發伺服器
uvicorn coach_api:app --reload

# API 文件自動產生於 http://localhost:8000/docs
```

---

## 測試 API Test with curl

```bash
curl -X POST http://localhost:8000/api/session-feedback \
  -H "Content-Type: application/json" \
  -d '{
    "pattern_id": "box",
    "pattern_name": "Box Breathing",
    "duration_seconds": 300,
    "completed_cycles": 5,
    "total_cycles": 5,
    "was_completed": true,
    "pace_label": "標準",
    "heart_rate_before": 78,
    "heart_rate_after": 68,
    "hrv_ms": 42.5,
    "stress_level": "輕度緊張",
    "total_sessions": 7,
    "streak_days": 3
  }'
```

健康檢查：

```bash
curl http://localhost:8000/health
```

---

## 部署到 Railway Deploy to Railway

1. 在 [Railway](https://railway.app) 建立新專案，連結此 GitHub repo
2. 設定環境變數：
   - `ANTHROPIC_API_KEY` → 你的 Anthropic API Key（從 console.anthropic.com 取得）
3. Railway 自動偵測 `requirements.txt` 並執行 `uvicorn coach_api:app --host 0.0.0.0 --port $PORT`
4. 取得部署 URL，更新 Watch App 的 API 端點設定

> **注意**: `ANTHROPIC_API_KEY` 絕對不能 commit 進 git。請只透過 Railway 環境變數設定。

---

## 部署到 Render Deploy to Render

1. 在 [Render](https://render.com) 建立 **Web Service**，連結此 repo
2. Build Command: `pip install -r requirements.txt`
3. Start Command: `uvicorn coach_api:app --host 0.0.0.0 --port $PORT`
4. Environment Variables（Environment 頁面）：
   - `ANTHROPIC_API_KEY` → 你的 Anthropic API Key
5. 選擇 Free Instance Type（512MB RAM，適合低流量 beta 測試）

> **注意**: `ANTHROPIC_API_KEY` 絕對不能 commit 進 git。請只透過 Render 環境變數頁面設定。

---

## 安全注意事項 Security

- `ANTHROPIC_API_KEY` **永遠不應出現在程式碼或 git 歷史中**
- `.env` 已加入 `.gitignore`，只提交 `.env.example`（值為空）
- Rate limiting：每個 IP 每分鐘最多 20 次請求（in-memory，重啟後重置）
- 所有 Claude API 錯誤都會優雅降級，不暴露錯誤細節給客戶端
