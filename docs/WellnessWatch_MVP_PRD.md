# WellnessWatch — MVP Product Requirements Document

> **Version**: 1.1
> **Status**: ⚠️ Review Ready — 待 Product Owner 確認後轉為 Approved
> **Target Platform**: watchOS 7+ · iOS 16+
> **Planned Launch**: Week 14–15 (TestFlight Beta: Week 10)
> **Author**: [Product Owner]
> **Reviewers**: [Tech Lead / Design Lead]
> **Last updated**: 2026-03-26

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Problem Statement](#2-problem-statement)
3. [MVP Scope Definition](#3-mvp-scope-definition)
4. [Functional Requirements](#4-functional-requirements)
5. [Non-Functional Requirements](#5-non-functional-requirements)
6. [Technical Architecture](#6-technical-architecture)
7. [UX Design Guidelines](#7-ux-design-guidelines)
   - 7.5 [User Flow](#75-user-flow)
8. [Milestones & Timeline](#8-milestones--timeline)
9. [Success Metrics (KPIs)](#9-success-metrics-kpis)
10. [Risks & Assumptions](#10-risks--assumptions)
11. [Appendix & References](#11-appendix--references)

---

## 1. Product Overview

WellnessWatch is a mindful breathing app built natively for Apple Watch. It combines five science-backed breathing techniques with real-time HealthKit biometrics (heart rate and HRV) to deliver personalized, on-wrist stress relief and mindfulness experiences.

The MVP focuses on delivering the core value proposition: **breathing guidance + haptic feedback + HealthKit integration**, with an optional AI coaching layer. The goal is to submit to the App Store by Week 14.

### Problem–Solution Summary

| Dimension | Current Problem | WellnessWatch Solution |
|-----------|----------------|------------------------|
| Friction | Stress relief requires picking up the phone and opening an app | Wrist-based haptic guidance — zero-friction, in-context activation |
| Data blindness | Users don't know when they need to practice | HRV + heart rate monitoring with proactive reminders |
| Motivation gap | No personalized feedback after sessions | AI coach uses biometric data to generate tailored recommendations |

---

## 2. Problem Statement

### 2.1 Target Users

The primary target audience is urban professionals aged 25–45 who own an Apple Watch and have stress management needs. Secondary audiences include athletes seeking improved HRV recovery and users with sleep-onset difficulties.

| Persona | Core Pain Point | Primary Use Case | Success Definition |
|---------|----------------|------------------|--------------------|
| Stressed Professional | Pre-meeting anxiety; mid-afternoon energy crash | Box Breathing 5 min before a meeting | Heart rate drops ≥ 5 bpm |
| Sleep-Challenged User | Difficulty falling asleep; racing thoughts at bedtime | 4-7-8 Breathing 4 min before bed | HRV improves post-session |
| Fitness Enthusiast | Slow HRV recovery after training | Resonance Breathing 10 min post-workout | HRV trend improves next day |

### 2.2 Market Opportunity

- The global meditation app market was valued at $2.3B in 2025, with a 41% CAGR.
- Apple Watch active users surpassed 150M in 2024; health features are the top purchase driver.
- **Competitive gap**: Calm and Headspace are primarily iOS-first; their watchOS experiences are shallow.
- **Our differentiation**: The only watchOS-native breathing app combining real-time HRV feedback with AI personalization.

---

## 3. MVP Scope Definition

> **MVP Principle**: Deliver the minimum feature set required to validate the core hypothesis — *"Real-time HRV guidance increases user practice adherence"* — while deferring all non-essential features to v1.1+.

### 3.1 In Scope — MVP Features

| # | Feature Module | Description | Priority |
|---|---------------|-------------|----------|
| 1 | Five Breathing Modes | 4-7-8 / Box / Diaphragmatic / Resonance / Physiological Sigh — with full animation and haptic guidance | **P0 — Core** |
| 2 | HealthKit Integration | Read heart rate + HRV; calculate stress level; before/after comparison | **P0 — Core** |
| 3 | Haptic Guidance System | Distinct vibration patterns for inhale / hold / exhale; usable without looking at screen | **P0 — Core** |
| 4 | Session Results Screen | Post-session heart rate change, HRV change, and completed cycles | **P1 — Important** |
| 5 | AI Personalized Coaching | Post-session Claude API feedback (≤ 150 words); optional, off by default | **P1 — Important** |
| 6 | iOS Companion App | Session history trends, basic settings, privacy controls | **P2 — Supporting** |

### 3.2 Out of Scope — Planned for v1.1+

- Social features (challenges, leaderboards)
- Guided meditation (voice narration, background audio)
- Sleep tracking integration (sleep stages)
- Writing mindful minutes back to Apple Health
- Watch face complications / widgets
- Additional locales (v1.0: English + Traditional Chinese only)
- Subscription model (v1.0: one-time purchase or limited free trial)

---

## 4. Functional Requirements

### 4.1 Breathing Exercise Core (P0)

#### 4.1.1 Breathing Mode Specifications

| Mode | Inhale | Hold | Exhale | Duration | Primary Effect |
|------|--------|------|--------|----------|---------------|
| 4-7-8 Breathing | 4 sec | 7 sec | 8 sec | 4 min | Rapid relaxation; ideal before sleep |
| Box Breathing | 4 sec | 4 sec | 4 sec | 5 min | Focus and composure under pressure |
| Diaphragmatic Breathing | 5 sec | — | 5 sec | 5 min | Everyday stress relief baseline |
| Resonance Breathing | 5 sec | — | 5 sec | 10 min | Maximizes HRV improvement |
| Physiological Sigh | 2 sec + 1 sec | — | 7 sec | 5 min | Fastest single-cycle calm-down; double inhale reopens alveoli, long exhale activates parasympathetic response |

#### 4.1.2 Animation Requirements

- Primary visual: circular breathing animation — expands from 0.6× to 1.0× on inhale; contracts on exhale.
- Animation uses `.easeInOut` with duration synchronized to the current breathing phase.
- Color transitions: Inhale Blue (`#3382E5`) → Hold Purple (`#7B4FCB`) → Exhale Teal (`#2FBCB2`) → Rest Gray.
- Countdown timer displayed at the center of the circle; font size 28 pt, `.rounded` design.
- Progress bar shows overall session progress (current cycle / total cycles).

#### 4.1.3 Haptic Guidance Requirements

- **Inhale start**: `.start` followed by `.click` 300 ms later (double cue).
- **Hold phase**: `.notification` every 2 seconds (gentle reminder).
- **Exhale start**: `.stop` (single long cue).
- **Session complete**: `.success` (positive completion signal).
- All haptic patterns must function in Apple Watch Silent Mode.

---

### 4.2 HealthKit Integration (P0)

#### 4.2.1 Data Reading Specifications

- **Types read**: `heartRate`, `heartRateVariabilitySDNN`, `restingHeartRate`.
- **Authorization timing**: Requested when the user first taps "Start Session" — not on app launch.
- **Graceful degradation**: If authorization is denied, breathing guidance continues fully; biometric displays are hidden.
- **Heart rate refresh rate**: Continuous via `HKAnchoredObjectQuery` (updated each second during sessions).
- **HRV source**: Most recent SDNN sample within the past 7 days.

#### 4.2.2 Stress Level Calculation

The MVP uses a simplified compound model (v1.1 will introduce a machine learning model):

| Stress Level | Heart Rate | HRV (if available) | Display |
|-------------|-----------|-------------------|---------|
| Relaxed | < 65 bpm | > 50 ms | 😌 Relaxed |
| Mildly Stressed | 65–85 bpm | 30–50 ms | 😐 Mildly Stressed |
| Highly Stressed | ≥ 85 bpm | < 30 ms | 😰 Highly Stressed |
| Measuring | — | — | ⏳ Measuring... |

---

### 4.3 AI Personalized Coaching (P1)

- **Default state**: Disabled. Users must explicitly enable via Settings.
- **Trigger**: "View AI Suggestion" button on the Results screen after each completed session.
- **Response length**: ≤ 150 words; suitable for Apple Watch small screen.
- **Tone requirements**: Warm, encouraging, and grounded in science; three-part format (evaluation + physiological explanation + next session recommendation).
- **Data transmitted**: Anonymized statistics only — heart rate delta, HRV delta, breathing pattern, duration, total session count. **No PII.**
- **Failure handling**: On network error or API timeout (5 seconds), display a default motivational message. Never crash.

---

### 4.4 iOS Companion App (P2)

- **History view**: 30-day session calendar with daily heart rate / HRV trend line charts.
- **Settings**: Toggle AI coaching, notification preferences, clear all data, privacy policy link.
- **WatchConnectivity**: Bidirectional sync of session records between Watch and iPhone.

---

## 5. Non-Functional Requirements

| Category | Requirement | Acceptance Criterion |
|----------|------------|---------------------|
| Performance — Launch | App cold start to HomeView | < 3 seconds (watchOS system limit) |
| Performance — Memory | Memory usage during a session | < 50 MB (watchOS recommended ceiling) |
| Battery — Watch | Power consumption for a 10-minute session | < 5% battery |
| Reliability | In-session app crash rate | < 0.1% (verified via Crashlytics) |
| Offline availability | Core breathing features without network | 100% available; AI feature degrades gracefully |
| Privacy — Storage | Where health data is stored | On-device only; no external database writes |
| Security — API key | Anthropic API key storage | Keychain only; never hardcoded in binary |
| Accessibility | Minimum font size | ≥ 16 pt; supports Dynamic Type |
| App Store compliance | Regulatory requirements | HealthKit usage description, no medical claims, Privacy Nutrition Label complete |

---

## 6. Technical Architecture

### 6.1 System Layer Overview

| Layer | Component | Tech Stack | Notes |
|-------|-----------|-----------|-------|
| Watch Front-end | WellnessWatch Watch App | SwiftUI + Combine | watchOS native app |
| iOS Front-end | WellnessWatch (iOS) | SwiftUI + WatchConnectivity | Companion app |
| Health Data | HealthKitService | HealthKit Framework | Heart rate + HRV read-only |
| Haptic Guidance | HapticService | WatchKit | WKInterfaceDevice haptic types |
| AI Backend | coach_api.py | FastAPI + Anthropic SDK | Deployed on Railway / Render |
| Local Storage | CoreData / UserDefaults | Apple Frameworks | Session records + preferences |

### 6.2 Xcode Project Structure

| Target | Key Files |
|--------|-----------|
| WellnessWatch Watch App | HomeView / BreathingView / SessionView / ResultView |
| Services (Watch) | HealthKitService / HapticService / AICoachService |
| Models (Watch) | BreathingSession / UserProgress |
| WellnessWatch (iOS) | HistoryView / SettingsView |
| backend/ | coach_api.py / requirements.txt |

### 6.3 AI Coach API Specification

**Endpoint**: `POST /api/session-feedback`

| Parameter | Type | Description |
|-----------|------|-------------|
| `heart_rate_before` | `float` | Heart rate before session (bpm) |
| `heart_rate_after` | `float` | Heart rate after session (bpm) |
| `hrv_before` | `float?` | HRV SDNN before session (ms); nullable |
| `hrv_after` | `float?` | HRV SDNN after session (ms); nullable |
| `breathing_pattern` | `string` | Pattern identifier: `4-7-8` / `box` / `diaphragmatic` / `resonance` / `physiological-sigh` |
| `duration_minutes` | `int` | Session duration in minutes |
| `sessions_count` | `int` | User's total cumulative session count (anonymized) |

**Response**: JSON with `feedback` (string), `next_session_suggestion` (object), and `achievement` (string or null).

---

## 7. UX Design Guidelines

### 7.1 watchOS Screen Sizes

| Model | Point Size | Screenshot Resolution | Design Baseline |
|-------|-----------|----------------------|----------------|
| 45mm (Ultra / S8+) | 198 × 242 pt | 396 × 484 px | |
| 44mm (S6 / SE) | 184 × 224 pt | 368 × 448 px | |
| 41mm (S7+) | 176 × 215 pt | 352 × 430 px | ✅ Minimum design target |
| 40mm (S4/5/SE) | 162 × 197 pt | 324 × 394 px | Backward compatible |

### 7.2 Color System

| Usage | Name | Hex | Context |
|-------|------|-----|---------|
| Inhale animation | Breathe Blue | `#3382E5` | Circle expanding, inhale cue |
| Hold animation | Hold Purple | `#7B4FCB` | Circle static, hold cue |
| Exhale animation | Exhale Teal | `#2FBCB2` | Circle contracting, exhale cue |
| Background | Calm Dark | `#0D0D1A` | Fixed dark background (night-safe) |
| Rest state | Rest Gray | `#4A4A6A` | Rest phase and secondary text |

### 7.3 Typography

- **Minimum readable size**: 16 pt (Apple HIG minimum)
- **Primary headings**: 20–24 pt, SF Pro Rounded
- **Countdown timer**: 28 pt, `.light` weight, `.rounded` design
- **Body / instruction text**: 14–16 pt, `.medium` weight
- **Session stats**: 12–14 pt, `.caption2` style

### 7.4 Interaction Design Principles

- Maximum 2 actions per screen (Apple Watch HIG).
- Sessions should require minimal touch interaction — haptics lead the user.
- Digital Crown controls volume / scrolling through session history.
- All tap target areas ≥ 44 × 44 pt.

### 7.5 User Flow

本節定義 4 條核心使用路徑，作為 Xcode 專案畫面結構與導航邏輯的設計依據。

---

#### Flow A：首次啟動（First Launch）

```
[App 安裝完成 / 首次開啟]
         │
         ▼
┌─────────────────────┐
│   OnboardingView    │  "在手腕上練習減壓，隨時隨地"
│   (僅首次顯示)       │  [開始使用] 按鈕
└─────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│        HealthKit 授權請求               │
│  "WellnessWatch 需讀取心率與 HRV…"      │
└─────────────────────────────────────────┘
         │
    ┌────┴────┐
    │         │
  [允許]    [拒絕 / 略過]
    │         │
    ▼         ▼
┌────────┐  ┌──────────────────┐
│完整模式│  │ 簡化模式         │
│HomeView│  │ HomeView         │
│含壓力  │  │ 隱藏生理指標     │
│指標    │  │ 呼吸功能完整保留 │
└────────┘  └──────────────────┘
```

**涉及畫面**：OnboardingView → HomeView
**設計要點**：
- Onboarding 僅顯示一次（UserDefaults `hasLaunchedBefore` flag）
- HealthKit 授權請求時機：點擊「開始使用」後，非 App 啟動時
- 拒絕授權後，App 所有核心呼吸功能仍完整可用（見 Flow D）

---

#### Flow B：核心練習流程（Core Breathing Session）

```
┌──────────────────────────────────┐
│           HomeView               │
│  ┌──────────────────────────┐    │
│  │  壓力指標（若有 HK 授權）  │    │
│  │  😐 Mildly Stressed       │    │
│  │  HR: 72 bpm / HRV: 38ms  │    │
│  └──────────────────────────┘    │
│  選擇練習模式：                   │
│  ● 4-7-8 Breathing  (4 min)      │
│  ● Box Breathing    (5 min)      │
│  ● Diaphragmatic    (5 min)      │
│  ● Resonance        (10 min)     │
│  ● Physiological Sigh (5 min)    │
└──────────────────────────────────┘
         │ 點擊任一模式
         ▼
┌──────────────────────────────────────────────────┐
│              PreviewView（新增）                  │
│                                                  │
│  ▶ 預覽示範                                      │
│  Box Breathing  ·  4 · 4 · 4 秒                  │
│                                                  │
│         ●  ← 完整循環動畫（持續播放）              │
│             顏色隨吸氣/屏氣/吐氣切換               │
│                                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐                      │
│  │ 吸氣 │ │ 屏氣 │ │ 吐氣 │  ← 當前相位高亮       │
│  │  4s  │ │  4s  │ │  4s  │                      │
│  └──────┘ └──────┘ └──────┘                      │
│  [█████████][████████][█████████]  ← 時間比例條   │
│  （藍）       （紫）      （青綠）                 │
│                                                  │
│  震動提示時機：                                   │
│  [📳 .start] › [〰 .note] › [📳 .stop]           │
│    ↑ 發光閃爍代表此刻震動觸發                      │
│                                                  │
│  [開始練習]  [← 返回]                             │
└──────────────────────────────────────────────────┘
         │ 點擊「開始練習」
         ▼
┌──────────────────────────────────┐
│         BreathingView            │
│                                  │
│   ●  ← 呼吸動畫圓圈（縮放）       │
│       顏色隨相位切換              │
│                                  │
│   [倒數秒數]  吸氣 / 屏氣 / 吐氣  │
│   ──────────────────────         │
│   進度條  第 2 / 5 輪             │
│                                  │
│   震動引導同步進行（背景）         │
└──────────────────────────────────┘
         │
    ┌────┴────────────────────┐
    │  正常完成所有輪次         │   Digital Crown 上滑 → 提前結束
    ▼                         ▼
┌────────────────────┐    ┌─────────────────────────┐
│    ResultView      │    │  確認對話框              │
│                    │    │  "確定要結束練習？"      │
│  心率：72 → 64 bpm │    │  [繼續] [結束]           │
│  HRV：38 → 45 ms  │◄───┘  結束 → ResultView      │
│  壓力：↓ 好轉      │         （顯示已完成輪數）    │
│  完成：5 / 5 輪    │
│                    │
│  [查看 AI 建議]    │ → Flow C
│  [完成，返回首頁]  │
└────────────────────┘
         │ 點擊完成
         ▼
    [HomeView]
```

**涉及畫面**：HomeView → **PreviewView** → BreathingView → ResultView → HomeView
**設計要點**：
- **PreviewView（新）**：選擇模式後自動進入，以完整循環動畫示範節奏；3 個震動圖示在對應時機發光閃爍，讓使用者在開始前確認震動節奏
- PreviewView 的「← 返回」可返回 HomeView 換選其他模式
- 正式練習中整個過程盡量不需觸控（震動引導優先）
- Digital Crown 是唯一的中途退出手勢
- 提前結束仍顯示 ResultView，紀錄已完成輪數

---

#### Flow C：AI 個人化教練（AI Coaching — Optional）

```
[ResultView]
         │ 點擊「查看 AI 建議」
         │ (僅在 Settings 已啟用 AI 功能時顯示此按鈕)
         ▼
┌──────────────────────────────┐
│       AICoachView            │
│                              │
│        ◌  Loading...         │  ← 旋轉動畫（timeout: 5 秒）
│                              │
└──────────────────────────────┘
         │
    ┌────┴────────────────────────┐
    │  API 回應成功（< 5 秒）      │   網路錯誤 / Timeout
    ▼                             ▼
┌────────────────────────┐   ┌────────────────────────┐
│    AICoachView         │   │    AICoachView          │
│  (AI 回饋顯示)          │   │  (降級訊息)             │
│                        │   │                        │
│  本次練習評價：         │   │  "很棒！持續練習是      │
│    "心率明顯下降…"      │   │  改善 HRV 的最佳方式。  │
│                        │   │  明天繼續加油！"        │
│  身體狀態說明：         │   │                        │
│    "HRV 提升表示…"      │   │  ⚠️ AI 建議目前暫不可用  │
│                        │   └────────────────────────┘
│  下次建議：             │             │
│    "明日嘗試共鳴呼吸…"  │             │
│                        │             │
│  ⚙️ AI 生成內容，非醫療建議│           │
└────────────────────────┘             │
         │                             │
         └─────────────┬───────────────┘
                       ▼
                  [返回 ResultView]
```

**涉及畫面**：ResultView → AICoachView → ResultView
**設計要點**：
- AI 功能預設關閉（`Settings > AI Coaching > Toggle OFF`）
- ResultView 的「查看 AI 建議」按鈕僅在功能啟用時顯示
- 所有 AI 輸出末尾固定標示「⚙️ AI 生成內容，非醫療建議」
- 降級訊息（fallback）為靜態文案，儲存於 App Bundle，不依賴網路

---

#### Flow D：無 HealthKit 授權降級模式（Graceful Degradation）

```
[HealthKit 授權被拒 / 已撤回]
         │
         ▼
┌──────────────────────────────────┐
│     HomeView（簡化模式）          │
│                                  │
│  ✗ 壓力指標隱藏                  │
│  ✗ 心率顯示隱藏                  │
│                                  │
│  選擇練習模式：（5 種，完整）      │
│  ● 4-7-8 / Box / Diaphragmatic  │
│  ● Resonance / Phys. Sigh       │
└──────────────────────────────────┘
         │ 選擇模式
         ▼
┌──────────────────────────────────┐
│     BreathingView（同完整版）     │
│  呼吸動畫 + 震動引導：完整保留    │
│  ✗ 即時心率顯示隱藏              │
└──────────────────────────────────┘
         │ 完成
         ▼
┌──────────────────────────────────┐
│     ResultView（簡化模式）        │
│                                  │
│  完成輪數：5 / 5                  │
│  練習時長：5 分鐘                  │
│  ✗ 心率前後比較（隱藏）           │
│  ✗ HRV 比較（隱藏）              │
│  ✗ AI 建議按鈕（隱藏）           │
│                                  │
│  💡 開啟健康資料以獲取個人化分析  │ → 引導至 iPhone 設定
└──────────────────────────────────┘
```

**涉及畫面**：HomeView → BreathingView → ResultView（三個畫面均為同一元件，依授權狀態條件渲染）
**設計要點**：
- 無 HealthKit 時，不彈出任何錯誤或警告（靜默降級）
- ResultView 底部顯示一次性的引導提示（可關閉），建議開啟健康資料
- 授權狀態改變後（例如使用者去設定開啟），App 無需重啟即自動偵測

---

#### 畫面結構總覽

```
App 啟動
  └── OnboardingView（首次）
        └── HomeView ──────────────────────┐
              └── PreviewView（新）         │
                    └── BreathingView       │
                          └── ResultView   │
                                ├── AICoachView（可選）
                                └── 返回 HomeView ◄──┘

iOS Companion App（獨立）
  ├── HistoryView（30 天趨勢）
  └── SettingsView（AI 開關、通知、隱私）
```

---

## 8. Milestones & Timeline

| Week | Milestone | Deliverables | Status |
|------|-----------|-------------|--------|
| W1–2 | Tech stack confirmed | Xcode project scaffolded; dependencies decided; HealthKit proof of concept | ⬜ Not started |
| W3–4 | Core breathing features | All 5 mode animations; HapticService; HomeView; BreathingView | ⬜ Not started |
| W5–6 | HealthKit integration | HealthKitService; stress level calculation; ResultView data display | ⬜ Not started |
| W7–8 | AI coach backend | FastAPI deployed; Claude API integrated; rate limiting; error handling | ⬜ Not started |
| W9 | iOS Companion App | History view; settings; WatchConnectivity sync | ⬜ Not started |
| W10 | Internal TestFlight | TestFlight distribution; crash monitoring setup; performance testing | ⬜ Not started |
| W11–12 | Beta testing + fixes | 20–50 external beta testers; bug fixes; UX refinements | ⬜ Not started |
| W13 | Launch preparation | Screenshots; metadata; privacy policy deployed; backend load testing | ⬜ Not started |
| W14 | App Store submission | Official submission (review typically 1–3 business days) | ⬜ Not started |
| W15 | Public launch | Manual release timing; launch announcement; first-week monitoring | ⬜ Not started |

---

## 9. Success Metrics (KPIs)

### 9.1 Targets — First 30 Days Post-Launch

| Metric | Definition | Target | Measurement Method |
|--------|-----------|--------|--------------------|
| Downloads | Organic App Store downloads | ≥ 500 in 30 days | App Store Connect Analytics |
| Day 7 Retention | Users who complete a session on Day 7 | ≥ 40% | Local session records (aggregated, anonymous) |
| Weekly Practice Frequency | Sessions per active user per week | ≥ 3 sessions | Local records |
| AI Feature Opt-in Rate | % of users who enable AI coaching | ≥ 30% | Backend API call statistics |
| App Store Rating | Initial average rating | ≥ 4.2 ★ | App Store Connect |
| Crash Rate | In-session crash rate | < 0.1% | Xcode Organizer / Crashlytics |
| Heart Rate Improvement Rate | % of sessions with ≥ 5 bpm post-session HR drop | ≥ 60% | Local HealthKit records |

### 9.2 Core Hypothesis Validation

- **Hypothesis 1**: Real-time HRV guidance increases practice adherence vs. no biometric data → validation: A/B test (v1.1).
- **Hypothesis 2**: AI personalized coaching increases "next session" motivation → validation: 7-day retention comparison between AI-enabled vs. disabled users.
- **Hypothesis 3**: Haptic guidance is more suitable than visual-only guidance for watchOS → validation: Beta tester survey (NPS question).

---

## 10. Risks & Assumptions

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|---------------------|
| App Store rejection (HealthKit description insufficient) | Medium | High | Prepare detailed Info.plist descriptions and comprehensive review notes in advance; reference `docs/review_notes.md` |
| Insufficient HRV data (users don't wear watch daily) | High | Medium | App works fully without HRV; falls back to heart-rate-only stress estimation |
| High AI API latency (> 5 seconds) | Low | Medium | 5-second timeout with a graceful fallback message; UI is never blocked |
| Claude API cost overrun | Low | Low | Set monthly usage cap; limit AI calls per user during Beta |
| Excessive battery drain | Medium | High | Limit HealthKit query frequency; stop heart rate monitoring immediately after session ends |
| Competitor (Calm / Headspace) launches watchOS native app | Low | High | Accelerate AI personalization differentiation; establish HRV integration as the core moat |

### Key Assumptions

- Users are willing to grant HealthKit access for a personalized experience.
- HRV data from Apple Watch SDNN readings is sufficiently reliable for stress estimation at this fidelity level.
- The Claude API can consistently respond within 5 seconds for 150-word outputs.
- Apple Watch Series 4+ hardware is sufficient for the target feature set.

---

## 11. Appendix & References

### 11.1 Related Documents

| Document | Path | Description |
|----------|------|-------------|
| App Store Metadata | `docs/app_store_metadata.md` | App Store Connect copy and screenshot specs |
| Privacy Policy | `docs/privacy_policy.md` | Full privacy policy (English) |
| Review Notes | `docs/review_notes.md` | App Store submission reviewer notes |
| Pre-Submission Checklist | `docs/app_store_checklist.md` | Full go-live checklist |
| HealthKit Guide | `docs/healthkit_guide.md` | HealthKit integration technical reference |

### 11.2 External Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [Anthropic Claude API Documentation](https://docs.anthropic.com)

### 11.3 Glossary

| Term | Definition |
|------|-----------|
| HRV (Heart Rate Variability) | A measure of the variation in time between heartbeats; a key indicator of autonomic nervous system health. SDNN is the standard deviation of normal-to-normal intervals, measured in milliseconds. |
| MVP (Minimum Viable Product) | The smallest feature set that validates the core product hypothesis. |
| HealthKit | Apple's health data integration framework, allowing apps to read and write health data from iPhone and Apple Watch. |
| P0 / P1 / P2 | Feature priority levels. P0 = required for MVP, P1 = important, P2 = nice-to-have. |
| WatchConnectivity | Apple's framework enabling communication between a watchOS app and its iOS companion app. |
| Resonance Breathing | A breathing rhythm of approximately 6 cycles per minute, clinically shown to maximize HRV improvement. |
| Graceful Degradation | The app's ability to continue functioning meaningfully when optional features (e.g., HealthKit, network) are unavailable. |

---

*This document is maintained by the WellnessWatch product team.*
*Last updated: 2026-03-26*
