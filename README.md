# 05 · 心靈療癒 Apple Watch App

> **目標**：開發一款 watchOS App，讓用戶在手腕上練習呼吸調節、正念冥想和減壓技巧，整合 HealthKit 的 HRV 與心率數據提供個人化引導。

---

## 專案狀態

| 里程碑 | 目標 | 狀態 |
|--------|------|------|
| 技術選型確認 | 第 1 週 | ⬜ |
| 基礎呼吸功能 | 第 4 週 | ⬜ |
| HealthKit 整合 | 第 6 週 | ⬜ |
| TestFlight Beta | 第 10 週 | ⬜ |
| App Store 提交 | 第 14 週 | ⬜ |

---

## 先備條件

```bash
# 需要：
# - Mac 電腦（必要，watchOS 開發限定 macOS）
# - Xcode 15+（免費）
# - Apple Developer 帳號（$99 USD/年）
# - Apple Watch（Series 4+ 推薦，用於 HRV 測量）
# - iPhone（用於 Companion App）
```

---

## 專案目錄

```
05-wellness-watch/
├── README.md
├── WellnessWatch/                    ← Xcode 專案
│   ├── WellnessWatch.xcodeproj
│   ├── WellnessWatch Watch App/      ← watchOS Target
│   │   ├── Views/
│   │   │   ├── BreathingView.swift   ← 呼吸練習畫面
│   │   │   ├── HomeView.swift        ← 主選單
│   │   │   ├── SessionView.swift     ← 練習進行中
│   │   │   └── ResultView.swift      ← 完成後統計
│   │   ├── Services/
│   │   │   ├── HealthKitService.swift← 心率/HRV 讀取
│   │   │   ├── HapticService.swift   ← 震動引導
│   │   │   └── AICoachService.swift  ← Claude API 個人化建議
│   │   └── Models/
│   │       ├── BreathingSession.swift
│   │       └── UserProgress.swift
│   └── WellnessWatch/                ← iOS Companion App
│       ├── Views/
│       └── Services/
├── backend/
│   ├── coach_api.py                  ← FastAPI + Claude API
│   └── requirements.txt
├── design/
│   ├── wireframes/                   ← Figma 設計稿連結
│   └── assets/                      ← 圖標、動畫素材
└── docs/
    ├── healthkit_guide.md            ← HealthKit 整合說明
    └── app_store_checklist.md        ← 上架前檢查清單
```

---

## 核心功能規格

### 呼吸練習模式

| 模式 | 吸氣 | 屏氣 | 吐氣 | 效果 | 時長 |
|------|------|------|------|------|------|
| 4-7-8 呼吸法 | 4秒 | 7秒 | 8秒 | 快速放鬆 | 4分鐘 |
| Box Breathing | 4秒 | 4秒 | 4秒 | 集中注意力 | 5分鐘 |
| 腹式呼吸 | 5秒 | - | 5秒 | 日常減壓 | 5分鐘 |
| 共鳴呼吸 | 5秒 | - | 5秒 | 提升 HRV | 10分鐘 |
| 生理式嘆息 | 2秒+1秒 | - | 7秒 | 快速平靜（雙吸長吐） | 5分鐘 |

---

## SwiftUI 核心程式碼

### 呼吸練習畫面

```swift
// WellnessWatch Watch App/Views/BreathingView.swift
import SwiftUI

struct BreathingView: View {
    @StateObject private var session = BreathingSession()
    @State private var circleScale: CGFloat = 0.6
    @State private var instructionText = "準備開始"
    @State private var phaseColor = Color.blue.opacity(0.6)
    
    var body: some View {
        ZStack {
            // 背景漸層
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 12) {
                // 呼吸動畫圓圈
                ZStack {
                    Circle()
                        .fill(phaseColor)
                        .frame(width: 100, height: 100)
                        .scaleEffect(circleScale)
                        .animation(
                            .easeInOut(duration: session.currentPhaseDuration),
                            value: circleScale
                        )
                    
                    Text(session.countdownText)
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // 引導文字
                Text(instructionText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                // 進度條
                ProgressView(value: session.progress)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 120)
                
                // 完成圈數
                Text("第 \(session.completedCycles) / \(session.totalCycles) 輪")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .onAppear { session.start(pattern: .breathing478) }
        .onChange(of: session.currentPhase) { _, phase in
            updateAnimation(for: phase)
        }
        .onDisappear { session.stop() }
    }
    
    private func updateAnimation(for phase: BreathingPhase) {
        withAnimation {
            switch phase {
            case .inhale:
                circleScale = 1.0
                phaseColor = Color.blue.opacity(0.7)
                instructionText = "吸氣"
            case .hold:
                circleScale = 1.0
                phaseColor = Color.purple.opacity(0.7)
                instructionText = "屏氣"
            case .exhale:
                circleScale = 0.6
                phaseColor = Color.teal.opacity(0.7)
                instructionText = "吐氣"
            case .rest:
                circleScale = 0.6
                phaseColor = Color.gray.opacity(0.4)
                instructionText = "放鬆"
            }
        }
    }
}
```

### HealthKit 心率服務

```swift
// WellnessWatch Watch App/Services/HealthKitService.swift
import HealthKit
import Combine

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var currentHeartRate: Double = 0
    @Published var currentHRV: Double = 0
    @Published var stressLevel: StressLevel = .unknown
    
    enum StressLevel: String {
        case low = "放鬆"
        case medium = "輕度緊張"
        case high = "高度緊張"
        case unknown = "測量中..."
    }
    
    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.restingHeartRate)
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType(.heartRate)
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            guard let samples = samples as? [HKQuantitySample],
                  let latest = samples.last else { return }
            
            let bpm = latest.quantity.doubleValue(for: .init(from: "count/min"))
            
            DispatchQueue.main.async {
                self?.currentHeartRate = bpm
                self?.updateStressLevel(heartRate: bpm)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchLatestHRV() async -> Double? {
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let hrv = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: .init(from: "ms"))
                continuation.resume(returning: hrv)
            }
            healthStore.execute(query)
        }
    }
    
    private func updateStressLevel(heartRate: Double) {
        // 根據心率估算壓力程度（簡化模型）
        switch heartRate {
        case ..<65: stressLevel = .low
        case 65..<85: stressLevel = .medium
        default: stressLevel = .high
        }
    }
}
```

### 觸覺引導服務

```swift
// WellnessWatch Watch App/Services/HapticService.swift
import WatchKit

class HapticService {
    static let shared = HapticService()
    
    func playInhalePattern() {
        // 3次輕觸 = 開始吸氣
        WKInterfaceDevice.current().play(.start)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    func playExhalePattern() {
        // 2次長觸 = 開始吐氣
        WKInterfaceDevice.current().play(.stop)
    }
    
    func playHoldPattern() {
        // 輕柔提示 = 屏氣中
        WKInterfaceDevice.current().play(.notification)
    }
    
    func playCompletionPattern() {
        // 成功完成
        WKInterfaceDevice.current().play(.success)
    }
}
```

### AI 個人化教練（後端）

```python
# backend/coach_api.py
"""
為 Watch App 提供個人化建議的後端 API
部署於 Railway 或 Render
"""

from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
import anthropic

app = FastAPI()
client = anthropic.Anthropic()

class SessionData(BaseModel):
    heart_rate_before: float
    heart_rate_after: float
    hrv_before: Optional[float]
    hrv_after: Optional[float]
    breathing_pattern: str
    duration_minutes: int
    completed_cycles: int
    stress_level_before: str
    user_note: Optional[str]

class UserProfile(BaseModel):
    sessions_count: int
    avg_hrv: Optional[float]
    preferred_time: str  # "morning/afternoon/evening"
    goals: list[str]     # ["stress_relief", "focus", "sleep"]

@app.post("/api/session-feedback")
async def get_session_feedback(session: SessionData, profile: UserProfile) -> dict:
    """根據本次練習數據，生成個人化回饋與下次建議"""
    
    hr_change = session.heart_rate_before - session.heart_rate_after
    hrv_change = (session.hrv_after or 0) - (session.hrv_before or 0)
    
    message = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=400,
        messages=[{"role": "user", "content": f"""
        根據以下呼吸練習數據，生成簡短的個人化回饋（繁體中文，150字以內，適合 Apple Watch 顯示）：
        
        練習模式：{session.breathing_pattern}
        時長：{session.duration_minutes} 分鐘
        完成輪數：{session.completed_cycles}
        
        生理數據變化：
        - 心率：{session.heart_rate_before:.0f} → {session.heart_rate_after:.0f} bpm（變化 {hr_change:+.0f}）
        - HRV：{session.hrv_before or 'N/A'} → {session.hrv_after or 'N/A'} ms（變化 {hrv_change:+.1f}）
        
        用戶目標：{', '.join(profile.goals)}
        累計練習次數：{profile.sessions_count}
        
        請提供：
        1. 一句本次練習評價
        2. 身體狀態說明（根據 HRV/心率變化）
        3. 下次練習建議
        
        語氣：溫暖、鼓勵、科學
        """}]
    )
    
    return {
        "feedback": message.content[0].text,
        "next_session_suggestion": suggest_next_session(session, profile),
        "achievement": check_achievements(profile.sessions_count)
    }

def suggest_next_session(session: SessionData, profile: UserProfile) -> dict:
    """根據數據推薦下次練習"""
    # 如果 HRV 下降，建議更長的練習
    if session.hrv_after and session.hrv_before:
        if session.hrv_after < session.hrv_before:
            return {"pattern": "box_breathing", "duration": 10, "reason": "今天壓力較高，建議更長練習"}
    
    return {"pattern": session.breathing_pattern, "duration": session.duration_minutes, "reason": "維持當前練習"}

def check_achievements(sessions_count: int) -> Optional[str]:
    """成就系統"""
    milestones = {
        1: "初次練習者",
        7: "一週堅持",
        30: "月度冥想者",
        100: "正念達人"
    }
    return milestones.get(sessions_count)
```

---

## 設計規範

### watchOS UI 限制與最佳實踐

```markdown
螢幕尺寸：
- Apple Watch 45mm：198 x 242 pt
- Apple Watch 41mm：176 x 215 pt
- 永遠設計最小尺寸（41mm）

字體大小：
- 最小可讀字體：16pt
- 主要標題：20–24pt
- 說明文字：14–16pt

互動設計：
- 每個畫面最多 2 個操作
- 優先使用 Digital Crown 滾動
- 避免複雜手勢
- 練習中盡量不需要觸控
```

### 顏色系統

```swift
// 療癒色彩調色板
let breatheBlue = Color(red: 0.2, green: 0.5, blue: 0.9)    // 吸氣
let holdPurple = Color(red: 0.5, green: 0.3, blue: 0.8)     // 屏氣
let exhaleGreen = Color(red: 0.2, green: 0.7, blue: 0.6)    // 吐氣
let calmBackground = Color(red: 0.05, green: 0.05, blue: 0.1) // 夜間模式背景
```

---

## App Store 提交準備

```markdown
# app_store_checklist.md

## 元數據
- [ ] App 名稱（30字元以內）
- [ ] 副標（30字元以內）
- [ ] 描述（最多4000字元）
- [ ] 關鍵字（100字元）
- [ ] 類別：Health & Fitness

## 截圖規格
- [ ] Apple Watch 45mm：396 x 484 px
- [ ] Apple Watch 41mm：352 x 430 px

## 審核注意事項
- HealthKit 使用說明（必填）
- 不得有「治療」、「診斷」等醫療聲稱
- 描述清楚這是「健康輔助工具」而非醫療設備

## 隱私政策
- 健康數據僅存於設備本地
- 不分享給第三方
- GDPR 合規聲明
```

---

## Claude Code 快速開發指令

```bash
# 建立完整 Xcode 專案結構
claude "根據 README.md 的架構，生成完整的 watchOS SwiftUI 專案
包含：所有 View、Service、Model 的骨架程式碼
使用最新 SwiftUI + async/await 模式"

# 生成動畫程式碼
claude "為呼吸練習 App 生成一個流暢的 SwiftUI 動畫，
圓圈在吸氣時緩慢擴大（4秒），屏氣時靜止（7秒），
吐氣時收縮（8秒），使用 withAnimation 和 .easeInOut"

# 生成 HealthKit 整合
claude "生成完整的 HealthKit 授權請求流程，
讀取心率和 HRV 數據，在 SwiftUI @StateObject 中管理狀態"

# 建立後端 API
claude "根據 backend/coach_api.py，
完整實作 FastAPI 後端，包含錯誤處理、Rate Limiting 和測試"
```

---

## 開發資源

- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [SwiftUI for watchOS](https://developer.apple.com/tutorials/swiftui)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

*最後更新：2025-03*
