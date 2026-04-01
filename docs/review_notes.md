# App Store Review Notes

> **WellnessWatch — Mindful Breathing App for Apple Watch**
> Submission Version: 1.0.0
> Submission Date: [Insert Date]

---

> 💡 **How to use this document**: When submitting the app, paste the content below into App Store Connect under "Version Information" → "App Review Information" → "Notes".

---

## Review Notes (paste into App Store Connect)

```
Dear App Review Team,

Thank you for reviewing WellnessWatch. The following notes are intended to help
facilitate a smooth and efficient review.

---

APP OVERVIEW
WellnessWatch is a wellness support app that guides users through evidence-based
breathing exercises using Apple Watch haptic feedback and visual cues. It reads
(but does not write) Heart Rate and HRV data from HealthKit to provide a
real-time stress indicator and personalized breathing recommendations.

---

HEALTHKIT USAGE
This app requests read-only access to the following HealthKit data types:

  • Heart Rate (HKQuantityTypeIdentifierHeartRate)
  • Heart Rate Variability SDNN (HKQuantityTypeIdentifierHeartRateVariabilitySDNN)
  • Resting Heart Rate (HKQuantityTypeIdentifierRestingHeartRate)

Purpose: These values are used exclusively to:
  (a) Display a real-time stress level indicator during and after sessions
  (b) Show before/after comparisons to help users quantify the effect of practice
  (c) Recommend the most suitable breathing pattern for the user's current state

All health data is processed on-device only. Raw HealthKit samples are NEVER
transmitted to external servers. When the optional AI Coaching feature is enabled
by the user, only anonymized summary statistics (e.g., "heart rate decreased 8 bpm")
are sent — no raw samples, no identifiers.

The app does NOT write any data to HealthKit.

---

AI COACHING FEATURE (Optional)
The app optionally connects to a backend API powered by Anthropic Claude to
generate personalized post-session feedback. This feature:

  • Is OFF by default — users must explicitly opt in via Settings
  • Transmits only anonymized session statistics (no PII of any kind)
  • Can be disabled at any time in the app's Settings screen
  • Has a 5-second timeout with a graceful fallback message if unavailable

---

MEDICAL DISCLAIMER
This app is NOT a medical device. It does not diagnose, treat, cure, or monitor
any medical condition. This is clearly communicated in:

  • The App Store description (final paragraph)
  • The in-app onboarding screen (first launch)
  • The Privacy Policy (Section 7)

All language in the app and metadata has been reviewed to ensure it does not
contain medical claims (no use of "treat," "diagnose," "clinical," or similar).

---

TEST INSTRUCTIONS
No account creation or login is required to use this app.

To test the core experience:
  1. Install on Apple Watch (Series 4 or later recommended)
  2. Launch the app and grant HealthKit permissions when prompted
     — or tap "Skip" to use the app without health data access
  3. Tap any breathing mode on the Home screen (e.g., "Box Breathing")
     to start a session
  4. The haptic guidance will lead you through each breathing phase

Note for simulator testing: HealthKit is not available in the Apple Watch
Simulator. All core breathing functionality works without health data access
(app enters graceful degradation mode automatically).

To test AI feedback (optional feature):
  1. Complete any breathing session
  2. On the Results screen, tap "View AI Suggestion"
  3. A loading indicator appears while the request is processed
  4. Actual AI feedback requires a live internet connection; without connectivity,
     a default motivational message is displayed instead

---

HAPTIC FEEDBACK
The app uses standard WKInterfaceDevice haptic types (start, click, stop,
notification, success) to guide breathing phases. No special entitlements or
permissions are required for haptic feedback on watchOS.

---

NO LOGIN REQUIRED
The app works fully offline. An internet connection is only used for the optional
AI coaching feature, which is disabled by default.

---

PRIVACY POLICY URL
https://wellnesswatch.app/privacy

Thank you for your thorough review.
```

---

## Internal Reference: Common Rejection Reasons & Mitigations

### HealthKit-Related (Guidelines 5.1.3 / 5.1.1)

| Rejection Risk | Prevention Measure | Our Mitigation |
|----------------|-------------------|----------------|
| Vague HealthKit usage description | Write specific, detailed `NSHealthShareUsageDescription` | See Info.plist examples below |
| HealthKit data used for advertising | Ensure zero ad SDKs are present | No advertising integrations in this app |
| Requesting unused HealthKit types | Only request types actually used | We request exactly 3 types; none written |
| Sending raw HealthKit data to 3rd-party servers | AI feature sends only anonymous stats | Clearly stated in review notes above |

### Medical Claims (Guidelines 5.1.3(iii) / 4.0)

| Prohibited Phrasing | Approved Alternative |
|---------------------|---------------------|
| Treats anxiety disorder | Supports stress management |
| Diagnoses your stress level | Provides a stress reference indicator |
| Medical advice | General wellness guidance |
| Improves heart conditions | Supports heart rate recovery |
| Clinically proven | Based on scientific breathing research |

### AI Feature (Guideline 5.6)

- AI-generated content must be clearly labeled as AI-generated (not presented as human-written)
- AI feedback must include a disclaimer: "This is AI-generated guidance, not medical advice"
- AI responses must not contain diagnostic or clinical language

---

## Required Info.plist Keys

Add the following to both the **watchOS Target** and **iOS Target** `Info.plist` files:

```xml
<!-- HealthKit read access description (required) -->
<key>NSHealthShareUsageDescription</key>
<string>WellnessWatch reads your heart rate and Heart Rate Variability (HRV)
to calculate a real-time stress indicator and provide personalized breathing
recommendations. All health data is processed on-device only and is never
transmitted to external servers.</string>

<!-- HealthKit write access — NOT used by this app, omit this key entirely -->
<!-- <key>NSHealthUpdateUsageDescription</key> -->
```

---

## Submission History

| Attempt | Date | Result | Rejection Reason | Resolution |
|---------|------|--------|-----------------|------------|
| #1 | — | ⬜ Pending | — | — |

---

## Tips for Faster Review

1. **Zero crashes in TestFlight** before submitting — at least 10 beta testers for 2+ weeks
2. **Screenshots must match actual app UI** exactly — no mocked or exaggerated screens
3. **Avoid submitting Friday afternoon** or the day before public holidays — longer wait times
4. **Expedited Review** — only request this for critical security or crash fixes
5. **Test account not required** — but document this explicitly in review notes
