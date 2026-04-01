# App Store Connect Metadata Template

> **WellnessWatch — Mindful Breathing App for Apple Watch**
> Category: Health & Fitness
> Platform: watchOS (primary) + iOS (Companion App)
> Last updated: 2026-03

---

## Basic Information

### App Name (≤ 30 characters)

| Locale | Name | Characters |
|--------|------|-----------|
| English | WellnessWatch | 13 |
| Traditional Chinese | 心靈療癒 · 呼吸冥想 | 11 |
| Simplified Chinese | 心灵疗愈 · 呼吸冥想 | 11 |
| Japanese | ウェルネスウォッチ | 9 |

> ⚠️ The Apple Watch App name appears directly on the watch face. Keep it under 15 characters to avoid truncation.

---

### Subtitle (≤ 30 characters)

| Locale | Subtitle |
|--------|----------|
| English | HRV-Guided Breathing & Calm |
| Traditional Chinese | HRV 智慧引導 · 減壓放鬆 |

---

### App Description (≤ 4,000 characters)

```
[Find Inner Calm on Your Wrist]

WellnessWatch combines evidence-based breathing techniques with real-time heart rate monitoring to deliver a personalized stress-relief and mindfulness experience on Apple Watch. By tracking your HRV (Heart Rate Variability) and heart rate, the app proactively guides you to practice when you need it most — right from your wrist.

━━━━━━━━━━━━━━━━━━

🫁 Five Science-Backed Breathing Techniques

• 4-7-8 Breathing — Rapid nervous system relaxation in just 4 minutes. Perfect before sleep.
• Box Breathing — Used by Navy SEALs to build focus and composure under pressure.
• Diaphragmatic Breathing — The everyday stress-relief foundation that restores autonomic balance.
• Resonance Breathing (6x/min) — Clinically validated to maximize HRV and parasympathetic tone.
• Physiological Sigh — A 5-minute double-inhale, long-exhale technique proven to rapidly reduce stress in a single cycle.

━━━━━━━━━━━━━━━━━━

❤️ Smart HealthKit Integration

• Real-time heart rate and HRV with a visual stress indicator
• Before/after data comparison to quantify the improvement from each session
• Historical trend tracking so you can see your progress over time
• All health data stays on your device — never uploaded or shared

━━━━━━━━━━━━━━━━━━

📳 Immersive Haptic Guidance

Precise haptic rhythms guide every breathing phase — inhale, hold, and exhale. You can complete a full session even in the dark, after a workout, or whenever your eyes can't be on the screen.

━━━━━━━━━━━━━━━━━━

🤖 AI Personal Coach

After each session, your AI coach analyzes your HRV and heart rate changes to deliver personalized, warm feedback and recommend the best breathing pattern for your current state.

━━━━━━━━━━━━━━━━━━

[Who It's For]
✓ Professionals who need fast, in-context stress relief
✓ Anyone struggling with sleep onset or racing thoughts at bedtime
✓ Athletes looking to optimize HRV recovery between training sessions
✓ Health-conscious users who want quantifiable mindfulness habits

━━━━━━━━━━━━━━━━━━

[Disclaimer]
WellnessWatch is a wellness support tool that provides guided breathing exercises and health data reference. This app is not a medical device and does not provide medical diagnosis or treatment advice. Please consult a qualified healthcare professional for any medical concerns.
```

---

### Keywords (≤ 100 characters)

| Locale | Keyword String | Characters |
|--------|---------------|-----------|
| English | breathing,meditation,HRV,stress,mindfulness,relax,sleep,anxiety,calm,wellness | 75 |

> 💡 Do not include the app name itself — Apple auto-indexes names and subtitles.
> 💡 Avoid competitor brand names (Calm, Headspace, etc.) to comply with App Store guidelines.

---

### Category

| Field | Value |
|-------|-------|
| Primary Category | Health & Fitness |
| Secondary Category | Lifestyle |

---

### Age Rating

Questionnaire recommendations:

| Question | Answer |
|----------|--------|
| Cartoon or fantasy violence | None |
| Realistic violence | None |
| Sexual content or nudity | None |
| Profanity or crude humor | None |
| Medical / Treatment app | No — this is a general wellness tool, not a medical device |
| Frequent / intense medical information | None |

**Expected result: 4+**

---

### Version Information

| Field | Content |
|-------|---------|
| Version number | 1.0.0 |
| Release notes | Initial release: five breathing modes, HealthKit heart rate / HRV integration, AI personalized coaching |

---

### Support & Marketing URLs

| Field | Notes |
|-------|-------|
| Support URL (required) | Must be a live, accessible URL — e.g., `https://wellnesswatch.app/support` |
| Marketing URL (optional) | `https://wellnesswatch.app` |
| Privacy Policy URL (required) | `https://wellnesswatch.app/privacy` |

> ⚠️ Apps using HealthKit **must** provide a publicly accessible Privacy Policy URL. Missing this will result in App Store rejection.

---

### Copyright

```
© 2026 [Developer / Company Name]. All rights reserved.
```

---

### Pricing Considerations

| Model | Suggested Pricing | Notes |
|-------|------------------|-------|
| Free + Subscription | 7-day free trial, then $2.99/month | Lowers download barrier; aligns with Apple Watch app market norms |
| One-time purchase | $12.99 | Simpler, no recurring billing friction |
| Freemium | 3 free modes; 2 advanced + AI coaching unlocked | Maximizes top-of-funnel downloads |

> Recommended: Free download + subscription model with a 7-day trial.

---

## App Clip (Optional)

No App Clip is planned for v1.0. A future version could offer a "Physiological Sigh" App Clip triggered via NFC tag for on-demand emergency use.

---

## Screenshot Specifications

### Apple Watch Screenshots (Required)

| Size | Resolution | Supported Models |
|------|-----------|-----------------|
| 45mm | 396 × 484 px | Series 7/8/9/10, Ultra |
| 41mm | 352 × 430 px | Series 7/8/9/10 |
| 44mm | 368 × 448 px | Series 4/5/6/SE (recommended to include) |
| 40mm | 324 × 394 px | Series 4/5/6/SE (recommended to include) |

### iOS Companion App Screenshots (Required)

| Device | Resolution | Notes |
|--------|-----------|-------|
| 6.7" (iPhone 14 Pro Max, etc.) | 1290 × 2796 px | **Required** |
| 6.5" (iPhone 11 Pro Max, etc.) | 1242 × 2688 px | Required |
| 5.5" (iPhone 8 Plus, etc.) | 1242 × 2208 px | Required |

### Recommended Screenshot Order (Apple Watch)

1. Breathing animation — circle expanding during inhale phase
2. HomeView — mode selection screen
3. HealthKit data display — heart rate + HRV stress indicator
4. Session results — stats after completing a session
5. AI feedback — personalized coaching text

> 💡 Use Apple's official device frames (Sketch or Figma templates) to add the watch hardware shell.
