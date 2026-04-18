# SKILL.md — 05 心靈療癒 Apple Watch App

> 本文件定義此專案的標準工作流程、輸出規範、品質標準與常用指令。
> 與 Claude 合作時，請先參考本文件。

---

## 標準工作流程

### 先備確認（開始前必查）

- [ ] Mac 電腦（watchOS 開發限定 macOS）
- [ ] Xcode 15+ 已安裝
- [ ] Apple Developer 帳號（$99 USD/年）
- [ ] Apple Watch Series 4+（用於 HRV 測量）

### Phase 1：基礎建置（第 1–4 週）

1. 建立 Xcode 專案（watchOS + iOS Companion App Target）
2. 設定專案目錄結構（參考 README.md 架構）
3. 實作基礎 `BreathingView.swift`（呼吸動畫 + 計時器）
4. 實作 `HapticService.swift`（震動引導：吸氣/屏氣/吐氣/完成）
5. 實作 `BreathingSession.swift` Model（5 種呼吸模式）
6. 在模擬器驗證動畫流暢度

### Phase 2：HealthKit 整合（第 5–6 週）

7. 在 Xcode 開啟 HealthKit Capability
8. 實作 `HealthKitService.swift`（請求授權 + 讀取心率 + 讀取 HRV）
9. 在真實 Apple Watch 上測試心率讀取
10. 整合壓力等級判斷邏輯到 `SessionView.swift`

### Phase 3：後端 AI 教練（第 7–8 週）

11. 建立 FastAPI 後端（`backend/coach_api.py`）
12. 串接 Claude API（`POST /api/session-feedback`）
13. 部署至 Railway 或 Render
14. Watch App 串接後端 API（`AICoachService.swift`）

### Phase 4：TestFlight Beta（第 9–10 週）

15. 完成 App Store 截圖（45mm + 41mm 兩種尺寸）
16. 撰寫 App Store 描述與關鍵字
17. 上傳至 App Store Connect，提交 TestFlight 審核
18. 邀請 Beta 測試者，收集反饋

### Phase 5：App Store 提交（第 11–14 週）

19. 修復 Beta 反饋的問題
20. 逐項確認 `docs/app_store_checklist.md`
21. 提交 App Store 審核

---

## 輸出規範

### 目錄結構

```
05-wellness-watch/
├── WellnessWatch/
│   ├── WellnessWatch Watch App/
│   │   ├── Views/
│   │   │   ├── HomeView.swift         ← 主選單
│   │   │   ├── BreathingView.swift    ← 呼吸練習畫面
│   │   │   ├── SessionView.swift      ← 練習進行中
│   │   │   └── ResultView.swift       ← 完成後統計
│   │   ├── Services/
│   │   │   ├── HealthKitService.swift ← 心率/HRV 讀取
│   │   │   ├── HapticService.swift    ← 震動引導
│   │   │   └── AICoachService.swift   ← 後端 API 串接
│   │   └── Models/
│   │       ├── BreathingSession.swift ← 呼吸模式與計時
│   │       └── UserProgress.swift     ← 練習歷史記錄
│   └── WellnessWatch/                 ← iOS Companion App
├── backend/
│   ├── coach_api.py                   ← FastAPI + Claude API
│   └── requirements.txt
├── design/
│   ├── wireframes/                    ← Figma 設計稿
│   └── assets/                       ← 圖標、動畫素材
└── docs/
    ├── healthkit_guide.md             ← HealthKit 整合說明
    └── app_store_checklist.md         ← 上架前完整檢查清單
```

### Swift 檔案命名規則

- View 檔案：`[功能名稱]View.swift`（如 `BreathingView.swift`）
- Service 檔案：`[功能名稱]Service.swift`（如 `HealthKitService.swift`）
- Model 檔案：`[資料名稱].swift`（如 `BreathingSession.swift`）
- 使用 SwiftUI + async/await，不使用舊版 completion handler

### 設計規範

**螢幕尺寸（永遠以最小尺寸設計）**

| 型號 | 點數尺寸 | 截圖像素 |
|------|---------|---------|
| 41mm（最小，主要設計目標） | 176 × 215 pt | 352 × 430 px |
| 45mm | 198 × 242 pt | 396 × 484 px |

**字體大小限制**

| 用途 | 大小 |
|------|------|
| 主要標題 | 20–24 pt |
| 說明文字 | 14–16 pt |
| 最小可讀字體 | 16 pt |

**顏色系統（必須使用）**

```swift
let breatheBlue   = Color(red: 0.2, green: 0.5, blue: 0.9)   // 吸氣
let holdPurple    = Color(red: 0.5, green: 0.3, blue: 0.8)    // 屏氣
let exhaleGreen   = Color(red: 0.2, green: 0.7, blue: 0.6)    // 吐氣
let calmBackground = Color(red: 0.05, green: 0.05, blue: 0.1) // 背景
```

### 後端 API 格式

`POST /api/session-feedback` 回傳：

```json
{
  "feedback": "string（≤ 150 字，適合 Watch 顯示）",
  "next_session_suggestion": {
    "pattern": "string",
    "duration": number,
    "reason": "string"
  },
  "achievement": "string | null"
}
```

---

## 品質標準

**SwiftUI 介面**
- 每個畫面最多 2 個操作按鈕
- 練習進行中不需要用戶觸控（全自動計時）
- 所有動畫使用 `.easeInOut`，時長對應呼吸相位秒數
- 在 41mm 模擬器驗證佈局不超出邊界

**HealthKit**
- 必須在 App 首次啟動時請求授權
- 授權失敗不得 crash，需顯示優雅的降級畫面（無 HRV 數據時仍可使用）
- 心率更新頻率：練習中每 5 秒刷新一次

**後端 AI 回饋**
- 回饋字數 ≤ 150 字（Apple Watch 螢幕限制）
- 語氣：溫暖、鼓勵、帶科學感
- 回應時間目標：< 3 秒

**🔑 API Key 安全（後端開發必讀）**
- `ANTHROPIC_API_KEY` 只能存在 `backend/.env`，**絕對不寫進程式碼**
- `backend/.env` 已加入 `.gitignore`，不得手動 commit
- 程式碼讀取方式：`os.environ.get("ANTHROPIC_API_KEY")`（搭配 `python-dotenv`）
- 提供 `backend/.env.example`（值為空）供新開發者參考：
  ```
  ANTHROPIC_API_KEY=
  ```
- 每次 `git push` 前執行：`git log -p --all | grep -i "sk-ant-"` 確認無洩漏
- Swift 端不需要 API key（透過後端代理），**Watch App 程式碼中禁止出現任何 key**

**App Store 審核必備**
- HealthKit 使用說明（Privacy - Health Share Usage Description）必填
- 描述中不得出現「治療」「診斷」「醫療」等醫療聲稱
- 隱私政策：健康數據僅存設備本地，不分享給第三方
- 截圖必須包含 41mm 與 45mm 兩種尺寸

**里程碑驗收標準**
- 第 4 週：呼吸動畫在模擬器流暢運行（60 fps）
- 第 6 週：在真實 Apple Watch 上成功讀取心率
- 第 10 週：TestFlight Beta 版本可邀請測試者安裝
- 第 14 週：`app_store_checklist.md` 全部勾選，無任何未完成項目

---

## 常用指令範例

以下可直接貼入對話框執行：

```
根據 README.md 的架構，生成完整的 watchOS SwiftUI 專案骨架：
包含所有 View、Service、Model 的骨架程式碼
使用最新 SwiftUI + async/await 模式
顏色使用 SKILL.md 定義的色彩系統
輸出到對應的 Swift 檔案路徑
```

```
為 BreathingView.swift 生成流暢的 SwiftUI 呼吸動畫：
- 吸氣（4秒）：圓圈擴大，顏色 breatheBlue
- 屏氣（7秒）：圓圈靜止，顏色 holdPurple
- 吐氣（8秒）：圓圈收縮，顏色 exhaleGreen
使用 withAnimation + .easeInOut
顯示倒數計時與輪數進度
```

```
生成完整的 HealthKit 整合程式碼（HealthKitService.swift）：
- 請求心率與 HRV 授權（async/await）
- 即時心率監測（每5秒更新）
- 讀取最新 HRV 數值
- 授權失敗的降級處理
在 SwiftUI @StateObject 中管理狀態
```

```
完整實作 FastAPI 後端（backend/coach_api.py）：
- 加入輸入驗證（Pydantic）
- 加入錯誤處理（HTTP 400/500）
- 加入 Rate Limiting（每用戶每分鐘 10 次）
- 加入基本 pytest 單元測試
```

```
生成 docs/app_store_checklist.md 的完整版本：
根據 Apple App Store Review Guidelines（最新版）
包含：元數據、截圖規格、HealthKit 聲明、隱私政策、審核注意事項
每個項目用 checkbox 格式（- [ ]）
```

```
讀取目前 WellnessWatch/ 目錄結構，
告訴我：
1. 哪些 Swift 檔案已存在
2. 哪些檔案還沒建立
3. 建議下一步優先實作哪個功能
```

---

*最後更新：2026-04-18*
