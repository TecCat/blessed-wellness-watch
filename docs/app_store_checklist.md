# App Store Pre-Submission Checklist

> **WellnessWatch — Mindful Breathing App for Apple Watch**
> watchOS + iOS | Version 1.0.0

---

## How to Use This Checklist

Mark each item with its completion status:
- `[ ]` Not yet completed
- `[x]` Completed
- `[~]` Partially completed or pending confirmation
- `[N/A]` Not applicable

---

## A. Developer Account & Environment

- [ ] Apple Developer Program membership is active ($99 USD/year) and not expired
- [ ] App entry created in App Store Connect with correct Bundle ID
- [ ] Bundle ID format is correct: `com.[yourcompany].wellnesswatch`
- [ ] Xcode version ≥ 15 (required for latest watchOS SDK)
- [ ] Distribution Certificate is valid and not expired
- [ ] App Store Distribution Provisioning Profiles created for all Targets
- [ ] watchOS Target and iOS Companion Target Bundle IDs match App Store Connect

---

## B. Technical Requirements

### Platform Version Support

- [ ] watchOS deployment target set to: watchOS 7.0+ (10.0+ recommended)
- [ ] iOS deployment target set to: iOS 16.0+ (Companion App)
- [ ] App tested on a physical Apple Watch (not simulator only)

### Build & Architecture

- [ ] Release build uses Archive (not Debug)
- [ ] All third-party libraries support arm64 architecture
- [ ] No private API calls anywhere in the codebase
- [ ] No deprecated API warnings in the release build

### Privacy Permission Strings (Info.plist)

- [ ] `NSHealthShareUsageDescription` set in watchOS Target Info.plist
- [ ] `NSHealthShareUsageDescription` set in iOS Target Info.plist
- [ ] No unused privacy permission keys present in any Target
- [ ] watchOS Target has its own independent Info.plist (not inherited from iOS)

---

## C. HealthKit Compliance

- [ ] App only requests HealthKit types that are actually used:
  - [ ] `HKQuantityTypeIdentifierHeartRate` — Used? **Yes**
  - [ ] `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` — Used? **Yes**
  - [ ] `HKQuantityTypeIdentifierRestingHeartRate` — Used? **Yes**
  - [ ] Any other types — **No (none requested)**
- [ ] App does **not write** to HealthKit (`toShare` is an empty set)
- [ ] HealthKit authorization is requested at the right moment (not on first launch)
- [ ] App functions normally when HealthKit permission is denied (graceful degradation)
- [ ] HealthKit data is not used for advertising or third-party analytics
- [ ] A valid, publicly accessible Privacy Policy URL is set in App Store Connect

---

## D. App Store Connect Metadata

### Required Fields

- [ ] App name (≤ 30 characters) filled in
- [ ] Subtitle (≤ 30 characters) filled in
- [ ] App description (≤ 4,000 characters) filled in
  - [ ] No medical claims (no "treat," "diagnose," "cure," "clinical")
  - [ ] Wellness tool disclaimer included
- [ ] Keywords (≤ 100 characters) filled in; no competitor brand names
- [ ] Support URL is live and accessible
- [ ] Privacy Policy URL is live and accessible (HTTPS)
- [ ] Release notes filled in
- [ ] Copyright notice filled in (format: © 2026 [Company Name])
- [ ] Primary category: Health & Fitness
- [ ] Secondary category: Lifestyle (recommended)

### Age Rating

- [ ] Age rating questionnaire completed
- [ ] Expected result: **4+** (no violence, no sexual content, no profanity)

### App Review Information

- [ ] Review notes filled in (HealthKit explanation, AI feature explanation, test instructions)
- [ ] Test account info: **Not required — no login needed**

---

## E. Screenshots & Media Assets

### Apple Watch Screenshots (Required)

- [ ] 45mm screenshots (396 × 484 px) — minimum 1, maximum 10
- [ ] 41mm screenshots (352 × 430 px) — minimum 1, maximum 10
- [ ] Screenshots accurately represent actual app UI (no misleading content)
- [ ] Screenshots do not include unofficial Apple Watch device frames

### iOS Companion App Screenshots (Required)

- [ ] 6.7-inch screenshots (1290 × 2796 px)
- [ ] 6.5-inch screenshots (1242 × 2688 px)
- [ ] 5.5-inch screenshots (1242 × 2208 px)

### App Icon

- [ ] App Store icon uploaded to App Store Connect (1024 × 1024 px, PNG, no alpha)
- [ ] All required watchOS icon sizes included in Asset Catalog
- [ ] All required iOS icon sizes included in Asset Catalog
- [ ] Icons do not contain Apple trademarks or copyrighted imagery

---

## F. AI Feature Compliance

- [ ] AI-generated content is clearly labeled (e.g., "AI-generated suggestion")
- [ ] AI feedback UI includes a disclaimer ("not medical advice")
- [ ] Anthropic API key stored securely in Keychain (not hardcoded in binary)
- [ ] Backend API endpoint uses HTTPS
- [ ] Backend has rate limiting to prevent abuse
- [ ] AI feature is disabled by default; requires explicit user opt-in
- [ ] User data handling complies with GDPR and CCPA

---

## G. Privacy & Compliance

- [ ] App Privacy Nutrition Label filled out in App Store Connect
  - Health & Fitness data declared
  - Tracking (third-party advertising): **None**
  - Data linked to identity: complete as applicable
- [ ] AppTrackingTransparency: **Not required** — this app does not track users
- [ ] COPPA (children under 13): declared in age rating questionnaire
- [ ] GDPR compliance: EU user rights described in Privacy Policy

---

## H. Functional Testing

### Core Features

- [ ] All five breathing modes start and complete successfully
- [ ] Haptic guidance works on all supported watch models
- [ ] Breathing animation displays correctly on both 41mm and 45mm
- [ ] Digital Crown scrolling behaves as expected

### HealthKit Integration

- [ ] Authorization request flow works (allow / deny / partial allow)
- [ ] App does not crash when authorization is denied
- [ ] Heart rate monitoring works on physical device
- [ ] HRV reading works (requires existing HRV history)
- [ ] Stress level calculation returns correct values

### iOS Companion App

- [ ] WatchConnectivity communication works correctly
- [ ] Session history displays accurate data
- [ ] Dark Mode is fully supported

### AI Feature (if enabled)

- [ ] AI feedback displays correctly after session completion
- [ ] Appropriate error message shown when offline
- [ ] API timeout (5 seconds) triggers fallback message gracefully

---

## I. Performance & Stability

- [ ] App launch time < 3 seconds (watchOS system requirement)
- [ ] Memory usage within reasonable limits (< 50 MB recommended for watchOS)
- [ ] No known crashes (confirmed via Xcode Organizer or Crashlytics)
- [ ] TestFlight tested by at least 10 users over at least 2 weeks
- [ ] Xcode Instruments profiling passed (no memory leaks)

---

## J. Localization

- [ ] English (en): Complete
- [ ] Traditional Chinese (zh-Hant): Complete
- [ ] Optional additional locales: Simplified Chinese, Japanese, Korean

---

## K. Final Pre-Submission Checks

- [ ] Final Archive build produces no warnings or errors
- [ ] App passes Xcode Organizer validation ("Validate App")
- [ ] Automatic signing is configured correctly in Xcode
- [ ] Version number in build matches App Store Connect entry
- [ ] Backend API provider notified of planned launch date (prevent traffic anomalies)

---

## Milestone Timeline Reference

| Milestone | Target Week | Notes |
|-----------|------------|-------|
| Internal TestFlight | Week 8 | Core features complete |
| Public TestFlight Beta | Week 10 | 20–50 external testers |
| Screenshots & metadata | Week 12 | Including marketing assets |
| Backend deploy & load test | Week 13 | Railway / Render production env |
| App Store submission | Week 14 | Review typically 1–3 business days |
| Public launch | Week 15 | Manual release time control recommended |

---

*Last updated: 2026-03*
