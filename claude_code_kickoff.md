# WellnessWatch — Claude Code 啟動 Prompt

> 複製以下內容，貼到 Claude Code（Code 分頁）的對話框，作為開工的第一則訊息。

---

## 啟動 Prompt（直接複製貼上）

```
你好！我要開始開發 WellnessWatch，一款 Apple Watch 的呼吸冥想 App。

請先讀以下兩個文件來了解完整背景：
- docs/WellnessWatch_MVP_PRD.md（產品需求）
- README.md（技術架構與程式碼範例）

讀完後，請確認你理解以下幾個關鍵點，然後等我指示下一步：

1. 這是 watchOS + iOS Companion 雙 Target 的 Xcode 專案
2. 核心功能是 5 種呼吸模式（4-7-8、Box、腹式、共鳴、冷靜）
3. 整合 HealthKit 讀取心率與 HRV（只讀不寫）
4. 有一個可選的 AI 教練功能（FastAPI 後端 + Claude API）
5. 目標是 14 週內上架 App Store

專案目錄結構如 README.md 所示。Xcode 專案資料夾（WellnessWatch/）目前還不存在，需要從零建立。

等你讀完文件後告訴我你的理解，我們再決定今天從哪裡開始。
```

---

## 第一週建議任務清單（讀完文件後，從以下選一個開始）

### 選項 A：建立 Xcode 專案骨架
```
請幫我建立完整的 Xcode 專案目錄結構：
- WellnessWatch.xcodeproj 設定（watchOS + iOS Companion）
- 所有 Swift 檔案的骨架（空的 struct/class，包含正確的 import）
- Info.plist 包含 NSHealthShareUsageDescription
- Asset Catalog 的初始設定

使用 SwiftUI + async/await，watchOS 10.0+ / iOS 16.0+
```

### 選項 B：先從核心 BreathingSession Model 開始
```
請實作 Models/BreathingSession.swift，需要包含：
- 5 種呼吸模式的設定（節奏、時長、循環次數）
- 計時器邏輯（使用 Timer + @Published）
- 目前階段（inhale/hold/exhale/rest）
- 進度計算（0.0 ~ 1.0）
- 倒數計時文字
使用 ObservableObject + Combine
```

### 選項 C：先實作 BreathingView UI
```
請實作 Views/BreathingView.swift，根據 README.md 中的程式碼範例，
補完所有功能並確保：
- 圓圈動畫流暢（easeInOut）
- 吸/屏/吐三個階段顏色不同（藍/紫/青）
- 顯示倒數秒數
- 顯示完成輪數 / 總輪數
- 有一個「停止」按鈕
```

---

## 有用的背景資訊（給 Claude Code 參考）

| 項目 | 內容 |
|------|------|
| 語言 | Swift 5.9+，UI 使用 SwiftUI |
| 最低版本 | watchOS 10.0 / iOS 16.0 |
| HealthKit 讀取 | HeartRate、HRV SDNN、Resting Heart Rate |
| 顏色規範 | 吸氣藍 `#335FE5`、屏氣紫 `#7D4DCC`、吐氣綠 `#33B399` |
| 背景色 | 深黑 `#0D0D1A` |
| Bundle ID | `com.[yourname].wellnesswatch` |
| 後端 | FastAPI + Anthropic SDK（Python）|
| 部署目標 | Railway 或 Render |

---

*此文件由 Cowork 模式生成，用於在 Code 模式中快速啟動開發。*
