# 05 · WellnessWatch — 心靈療癒 Apple Watch App

> **目標**：開發一款 watchOS App，讓用戶在手腕上練習呼吸調節、正念冥想和減壓技巧，整合 HealthKit 的 HRV 與心率數據提供個人化引導。

---

## 專案狀態

| 里程碑 | 目標 | 狀態 |
|--------|------|------|
| 技術選型確認 | 第 1 週 | ✅ 完成 |
| 基礎呼吸功能 | 第 4 週 | ✅ 完成 |
| HealthKit 整合 | 第 6 週 | 🚧 模擬器完成，需實機測試 |
| SwiftData 練習紀錄 | 第 7 週 | ✅ 完成 |
| 統計分析 + 提醒 | 第 7 週 | ✅ 完成 |
| TestFlight Beta | 第 10 週 | ⬜ 待開始 |
| App Store 提交 | 第 14 週 | ⬜ 待開始 |

---

## 先備條件

- Mac 電腦（必要，watchOS 開發限定 macOS）
- Xcode 26.x（免費）
- Apple Developer 帳號（$99 USD/年，實機測試 HealthKit 需要）
- Apple Watch Series 4+（推薦，用於 HRV 測量）

---

## 專案目錄

```
05-wellness-watch/
├── README.md
├── WellnessWatch/                          ← Xcode 專案
│   ├── WellnessWatch.xcodeproj
│   ├── WellnessWatch Watch App/            ← watchOS Target
│   │   ├── wellnessApp.swift               ← @main, NavigationStack, SwiftData
│   │   ├── AppNav.swift                    ← pop-to-root 導航管理
│   │   ├── AppLogger.swift                 ← OSLog 結構化日誌
│   │   ├── SessionRecord.swift             ← SwiftData model
│   │   ├── BreathingSession.swift          ← timer + patterns
│   │   ├── HealthKitService.swift          ← HR + HRV 監測
│   │   ├── HapticService.swift             ← 震動引導
│   │   ├── NotificationService.swift       ← 每日提醒
│   │   ├── HomeView.swift                  ← 主選單
│   │   ├── PreviewView.swift               ← pace selector
│   │   ├── BreathingView.swift             ← 呼吸練習畫面
│   │   ├── ResultView.swift                ← 完成後統計
│   │   ├── HistoryView.swift               ← SwiftData list
│   │   ├── StatsView.swift                 ← 統計圖表
│   │   └── ReminderView.swift              ← 提醒設定
│   └── WellnessWatchTests/
│       └── BreathingSessionTests.swift     ← 18 unit tests
├── backend/
│   ├── coach_api.py                        ← FastAPI + Claude API（待開發）
│   └── requirements.txt
└── docs/
    ├── WellnessWatch_MVP_PRD.md
    ├── UAT_TestPlan.md
    └── app_store_checklist.md
```

---

## 核心功能規格

| 功能 | 說明 | 狀態 |
|------|------|------|
| 5種呼吸模式 | 4-7-8 / Box / 腹式 / 共鳴 / 生理式嘆息 | ✅ |
| Box 方形動畫 | 筆跡沿正方形路徑描繪，每相位 25% | ✅ |
| 自適應配速 | 🐢/◎/🐇 手動選擇 + HealthKit 自動建議 | ✅ |
| 震動引導 | 吸氣/屏氣/吐氣/完成各有不同震動模式 | ✅ |
| 壓力監測 | HR + HRV → StressLevel (放鬆/輕度/高度) | ✅ |
| 練習紀錄 | SwiftData 儲存，支援左滑刪除 | ✅ |
| 統計圖表 | 7天長條圖 + 連續天數 + 最常練習 | ✅ |
| 每日提醒 | 自訂時間，UNCalendarNotificationTrigger | ✅ |
| AI 教練 | FastAPI + Claude API 個人化建議 | ⬜ 待開發 |

---

## 呼吸模式詳細規格

| 模式 | 吸氣 | 屏氣 | 吐氣 | 效果 | 時長 |
|------|------|------|------|------|------|
| 4-7-8 呼吸法 | 4秒 | 7秒 | 8秒 | 快速放鬆 | 4分鐘 |
| Box Breathing | 4秒 | 4秒 | 4秒 | 集中注意力 | 5分鐘 |
| 腹式呼吸 | 5秒 | — | 5秒 | 日常減壓 | 5分鐘 |
| 共鳴呼吸 | 5秒 | — | 5秒 | 提升 HRV | 10分鐘 |
| 生理式嘆息 | 2秒+1秒 | — | 7秒 | 快速平靜（雙吸長吐） | 5分鐘 |

---

## 技術架構

| 層次 | 技術 | 說明 |
|------|------|------|
| Watch UI | SwiftUI + NavigationStack | watchOS native |
| 本地資料 | SwiftData | 練習紀錄 (@Model SessionRecord) |
| 健康數據 | HealthKit | heartRate + heartRateVariabilitySDNN |
| 震動 | WatchKit HapticFeedback | WKInterfaceDevice |
| 通知 | UserNotifications | UNCalendarNotificationTrigger |
| 日誌 | OSLog | 4 個 category：session/healthkit/nav/ui |
| AI 後端 | FastAPI + Anthropic SDK | 待開發，部署於 Railway/Render |

---

## 單元測試

`WellnessWatchTests/BreathingSessionTests.swift` — 18 個 XCTest 案例（全數通過）

覆蓋範圍：BreathingSession 計時器狀態、配速乘數計算、SessionRecord SwiftData model 邏輯。

---

## 下一步

1. **AI Coach 後端**：建立 `backend/coach_api.py`，串接 FastAPI + Claude API，提供每次練習後的個人化回饋。
2. **TestFlight Beta**：取得付費 Apple Developer 帳號 → 實機測試 HealthKit → 上傳 TestFlight → 邀請 20–50 名 Beta 測試者。
3. **iOS Companion App**：實作 WatchConnectivity 同步、30天趨勢圖表、AI 開關設定。

---

## 開發資源

- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [SwiftUI for watchOS](https://developer.apple.com/tutorials/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

*最後更新：2026-04-19*
