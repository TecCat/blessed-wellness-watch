# WellnessWatch UAT Test Plan

**Version:** 1.1 | **Date:** 2026-04-19 | **Platform:** watchOS

---

## How to Use This Document

1. Set up the test environment as described below.
2. Execute each scenario in order. UI labels are shown in Chinese because the app interface is Chinese; all technical terms remain in English.
3. Mark each row with one of three symbols:
   - ✅ Pass — behaviour matches the expected result exactly
   - ❌ Fail — behaviour does not match; add a note describing what actually happened
   - ⚠️ Partial — behaviour is mostly correct but has a minor deviation; add a note
4. Complete the QA Log entry at the bottom after each test run.
5. Sign off when all critical TCs are ✅.

---

## Test Environment

| Item | Value |
|------|-------|
| Device | Apple Watch Simulator 45mm **and** real Apple Watch (series 7 or later) |
| Xcode | 26.x (latest stable) |
| Build configuration | Debug |
| iOS companion app | Not required — standalone watchOS app |
| HealthKit (Run A) | Capability **enabled** in target; permissions granted |
| HealthKit (Run B) | Capability **disabled** or permissions **denied** |
| Language / Region | Traditional Chinese (zh-Hant) preferred; app UI is always Chinese |

> Run all 20 TCs twice: once with HealthKit enabled (Run A) and once disabled/denied (Run B). TCs that say "(HealthKit disabled)" only apply to Run B.

---

## UAT Scenarios

---

### TC-01 — App Launch

**Preconditions:** App is not already running. Watch face is visible.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the WellnessWatch app icon on the watch face | App launches without crash | | |
| 2 | Observe the first screen | HomeView is shown within 2 seconds | | |
| 3 | Check for any alert dialogs | No unexpected alerts appear on launch | | |

---

### TC-02 — HomeView: All 5 Breathing Modes Visible

**Preconditions:** App is on HomeView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Scroll through the HomeView list | Exactly 5 breathing mode rows are visible | | |
| 2 | Verify row 1 | Shows "4-7-8 呼吸法" with label "快速放鬆・助眠" | | |
| 3 | Verify row 2 | Shows "Box Breathing" with label "專注・抗壓" | | |
| 4 | Verify row 3 | Shows "腹式呼吸" with label "日常減壓" | | |
| 5 | Verify row 4 | Shows "共鳴呼吸" with label "提升 HRV" | | |
| 6 | Verify row 5 | Shows "生理式嘆息" with label "急速平靜・雙吸法" | | |
| 7 | Verify accent color dots | Each row has a distinct colored dot (not white) | | |

---

### TC-03 — HomeView: Stress Card Hidden (HealthKit Disabled)

**Preconditions:** HealthKit capability is disabled or permissions denied (Run B).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Open HomeView | Scroll to top of the list | | |
| 2 | Check for stress card | No HRV / stress card is shown | | |
| 3 | Verify list still works | All 5 mode rows remain fully accessible | | |

---

### TC-04 — HomeView: Stress Card Shown (HealthKit Authorized)

**Preconditions:** HealthKit capability enabled, permissions granted (Run A).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Open HomeView | Scroll to top of the list | | |
| 2 | Observe stress card | Card is visible at the top with an emoji and a stress label | | |
| 3 | Check initial state | Label shows "測量中..." or a resolved stress level | | |
| 4 | Wait 5–10 seconds | Label updates to "放鬆", "輕度緊張", or "高度緊張" | | |

---

### TC-05 — PreviewView: Default Duration and Pace Shown

**Preconditions:** App is on HomeView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap any breathing mode row (e.g. "Box Breathing") | PreviewView slides in | | |
| 2 | Observe duration label | Shows the default duration for the selected pattern (e.g. "5 分鐘") | | |
| 3 | Observe pace | A default pace indicator (🐢 / ◎ / 🐇) is pre-selected | | |
| 4 | Observe rhythm preview | Animated rhythm preview is visible and playing | | |

---

### TC-06 — PreviewView: Pace Self-Assessment (No HealthKit)

**Preconditions:** Run B (HealthKit disabled/denied). PreviewView is open.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Look for pace recommendation | No automatic pace is forced; default pace is shown | | |
| 2 | Verify no crash or error alert | App continues normally without HealthKit data | | |

---

### TC-07 — PreviewView: Pace Override (Tap 🐢 / ◎ / 🐇)

**Preconditions:** PreviewView is open for any pattern.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the 🐢 (slow) button | 🐢 becomes highlighted / selected | | |
| 2 | Tap the ◎ (normal) button | ◎ becomes highlighted; 🐢 deselects | | |
| 3 | Tap the 🐇 (fast) button | 🐇 becomes highlighted; ◎ deselects | | |
| 4 | Tap 🐢 again | 🐢 re-selects | | |

---

### TC-08 — PreviewView: Rhythm Preview Updates with Pace Change

**Preconditions:** PreviewView is open. Rhythm animation is visible.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Note the animation speed at current pace | Observe cycle timing | | |
| 2 | Tap 🐢 (slow) | Rhythm animation visibly slows down | | |
| 3 | Tap 🐇 (fast) | Rhythm animation visibly speeds up | | |
| 4 | Tap ◎ (normal) | Rhythm animation returns to original speed | | |

---

### TC-09 — BreathingView: Session Starts, Countdown Visible

**Preconditions:** PreviewView is open with a pattern selected.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the Start / 開始 button | BreathingView appears | | |
| 2 | Observe the countdown number | A large countdown number (e.g. "4") is displayed | | |
| 3 | Observe phase label | Phase label (e.g. "吸氣") is shown below the animation | | |
| 4 | Observe the animation | Breathing animation is running (expanding/contracting circle or box path) | | |

---

### TC-10 — BreathingView: Box Animation Draws Square Path

**Preconditions:** "Box Breathing" pattern is selected and session is running.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Start a Box Breathing session | BreathingView appears | | |
| 2 | Observe the animation | Animation traces a square / rectangular path (not a circle) | | |
| 3 | Watch through one full cycle (16 s) | The square path resets and begins again | | |

---

### TC-11 — BreathingView: Time Remaining Counts Down MM:SS

**Preconditions:** Any session is running in BreathingView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Note the time remaining label | Displays in MM:SS format (e.g. "5:00" for a 5-minute session) | | |
| 2 | Wait 5 seconds | Timer decrements to "4:55" (±1 s) | | |
| 3 | Verify format is maintained | Still shows "4:55" not "295" or "4.9" | | |

---

### TC-12 — BreathingView: Phase Label Changes

**Preconditions:** A session with multiple phases is running (e.g. 4-7-8 or Box).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Observe phase label at start | Shows "吸氣" | | |
| 2 | Wait for inhale phase to complete | Label changes to next phase (e.g. "屏氣" for 4-7-8, or "屏氣" for Box) | | |
| 3 | Wait for hold phase to complete | Label changes to "吐氣" | | |
| 4 | (Box only) Wait for exhale to complete | Label changes to "放鬆" | | |
| 5 | (生理式嘆息 only) Observe second inhale | Label shows "再吸！" | | |

---

### TC-13 — BreathingView: Stop Button Shows Confirmation

**Preconditions:** A session is running in BreathingView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the Stop / 停止 button | A confirmation dialog or sheet appears | | |
| 2 | Verify dialog content | Dialog asks to confirm stopping (e.g. "確認停止？") | | |
| 3 | Tap Cancel / 取消 | Dialog dismisses; session continues running | | |

---

### TC-14 — BreathingView: Stop Confirmed → ResultView Shown

**Preconditions:** A session is running in BreathingView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the Stop / 停止 button | Confirmation dialog appears | | |
| 2 | Tap Confirm / 確認 (or equivalent) | Session stops; ResultView is pushed/shown | | |
| 3 | Observe ResultView | Shows elapsed time and completed cycles count | | |
| 4 | Verify no 🎉 confetti / completion banner | Since session was stopped early, no "完成" celebration shown | | |

---

### TC-15 — BreathingView: Session Completes Naturally → ResultView with 🎉

**Preconditions:** A short-duration session can be triggered, or tester waits for full session. (Recommended: use a pattern and let the timer count to zero in a test build with reduced duration, or verify on a full 4-minute 4-7-8 session.)

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Start a session and do not stop it | Session runs all cycles automatically | | |
| 2 | Wait for the last cycle to complete | BreathingView transitions to ResultView automatically | | |
| 3 | Observe ResultView | A celebration indicator (🎉 or "完成！" banner) is displayed | | |
| 4 | Verify completion stats | Cycles completed equals the pattern's total cycle count | | |

---

### TC-16 — ResultView: Stats Show Correct Elapsed Time and Cycles

**Preconditions:** ResultView is shown (from TC-14 or TC-15).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Read the elapsed time value | Time matches how long the session ran (e.g. "0:32" if stopped after 32 s) | | |
| 2 | Read the completed cycles value | Cycles value is a non-negative integer consistent with elapsed time | | |
| 3 | Verify formatting | Time displayed in MM:SS format; cycles shown as a whole number | | |

---

### TC-17 — ResultView: Encouragement Text Shown on Complete

**Preconditions:** ResultView shown after natural session completion (TC-15).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Read encouragement text | An encouraging Chinese message is displayed (e.g. "做得好！" or similar) | | |
| 2 | Verify it is absent on early stop | Encouragement text is NOT shown when session was stopped early (TC-14) | | |

---

### TC-18 — ResultView: Done Button Returns to HomeView

**Preconditions:** ResultView is currently shown.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the Done / 完成 button | App navigates back to HomeView | | |
| 2 | Verify HomeView state | All 5 mode rows visible; no stale session data displayed | | |
| 3 | Tap another mode row | PreviewView opens normally (no leftover state) | | |

---

### TC-19 — HealthKit: Crash-Free When Capability Removed

**Preconditions:** Run B — HealthKit capability removed from Xcode target or permissions denied on device.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Launch the app | No crash on launch | | |
| 2 | Navigate through all views | HomeView → PreviewView → BreathingView → ResultView — no crash at any point | | |
| 3 | Complete or stop a session | ResultView shown without crash or error | | |
| 4 | Check console for errors | No fatal HealthKit errors in the Xcode debug console | | |

---

### TC-20 — HealthKit: Auth Request Appears on First Session Start

**Preconditions:** Run A — HealthKit enabled. App is freshly installed (permissions not yet granted).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Launch the app | HomeView shown; no HealthKit prompt yet | | |
| 2 | Tap any mode row | PreviewView shown; still no HealthKit prompt | | |
| 3 | Tap the Start / 開始 button | HealthKit authorization sheet appears before or when session begins | | |
| 4 | Grant permissions | Session starts normally after authorization | | |
| 5 | Tap the Start button on a second session | No repeated auth request (already authorized) | | |

---

### TC-21 — HistoryView: Session record saved after completion

**Preconditions:** App has completed at least one session. HistoryView is accessible via the clock icon toolbar button on HomeView.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Complete a full session (let it run to zero) | ResultView is shown | | |
| 2 | Tap the Done / 完成 button | App navigates back to HomeView | | |
| 3 | Tap the clock icon in the HomeView toolbar | HistoryView opens | | |
| 4 | Observe the top row | New record appears at the top with the correct pattern name | | |
| 5 | Verify the record details | Elapsed time and a ✅ completion indicator are shown | | |

---

### TC-22 — HistoryView: Swipe to delete single record

**Preconditions:** HistoryView is open with at least two records present.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Swipe left on one row in the list | A Delete button (紅色「刪除」) appears on that row | | |
| 2 | Tap the Delete button | That record is removed from the list | | |
| 3 | Verify other records are untouched | All remaining records are still present and unchanged | | |

---

### TC-23 — HistoryView: Clear All with confirmation

**Preconditions:** HistoryView is open with at least one record present.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Scroll to the bottom of HistoryView | A "清除全部" button is visible | | |
| 2 | Tap "清除全部" | A confirmation dialog appears | | |
| 3 | Confirm the action | All records are removed | | |
| 4 | Observe the empty state | The message "🌙 尚無練習紀錄" (or equivalent empty state) is displayed | | |

---

### TC-24 — StatsView: Stats reflect session data

**Preconditions:** At least 2 sessions have been completed and saved. HistoryView is accessible.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Complete 2 sessions if not already done | Sessions are saved in HistoryView | | |
| 2 | Open HistoryView via the clock icon | Session records are visible | | |
| 3 | Tap the chart icon in the HistoryView toolbar | StatsView opens | | |
| 4 | Verify total sessions card | Value is ≥ 2 | | |
| 5 | Verify total minutes card | Value is > 0 | | |
| 6 | Verify 7-day chart | Bar(s) for today are visible | | |

---

### TC-25 — ReminderView: Enable daily reminder

**Preconditions:** App is on HomeView. Notification permissions have been granted (or will be requested).

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Tap the bell icon in the HomeView toolbar | ReminderView opens | | |
| 2 | Toggle the "每日提醒" switch to ON | Toggle turns on; a time picker becomes visible | | |
| 3 | Observe the status text | Status text shows "每天 20:00 提醒練習" (or the current default time) | | |
| 4 | Verify no crash | App remains stable throughout | | |

---

### TC-26 — ReminderView: Change reminder time

**Preconditions:** ReminderView is open with the "每日提醒" toggle ON.

| # | Action | Expected Result | Result | Notes |
|---|--------|-----------------|--------|-------|
| 1 | Use the hour picker to select 08 | Picker shows 08 | | |
| 2 | Use the minute picker to select 30 | Picker shows 30 | | |
| 3 | Observe the status text | Status text updates to "每天 08:30 提醒練習" | | |
| 4 | Background verification (optional) | System notification for the new time has been scheduled (can verify in Xcode console) | | |

---

## QA Log Template

Use this table to record each test run.

| Date | Tester | Build # | TC | Result | Notes |
|------|--------|---------|----|--------|-------|
| | | | TC-01 | | |
| | | | TC-02 | | |
| | | | TC-03 | | |
| | | | TC-04 | | |
| | | | TC-05 | | |
| | | | TC-06 | | |
| | | | TC-07 | | |
| | | | TC-08 | | |
| | | | TC-09 | | |
| | | | TC-10 | | |
| | | | TC-11 | | |
| | | | TC-12 | | |
| | | | TC-13 | | |
| | | | TC-14 | | |
| | | | TC-15 | | |
| | | | TC-16 | | |
| | | | TC-17 | | |
| | | | TC-18 | | |
| | | | TC-19 | | |
| | | | TC-20 | | |
| | | | TC-21 | | |
| | | | TC-22 | | |
| | | | TC-23 | | |
| | | | TC-24 | | |
| | | | TC-25 | | |
| | | | TC-26 | | |

---

## Sign-off

All critical TCs (TC-01 through TC-26) must be ✅ before a release build is submitted to TestFlight or App Store Connect.

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| QA Lead | | | |
| Product Owner | | | |
