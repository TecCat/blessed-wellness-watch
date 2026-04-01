# HealthKit Integration Guide

> **WellnessWatch — Mindful Breathing App for Apple Watch**
> Covers: permissions setup, data reading, App Store compliance, and privacy requirements
> Last updated: 2026-03

---

## 1. Overview

WellnessWatch uses HealthKit to read Heart Rate and Heart Rate Variability (HRV) data, providing a real-time stress indicator and personalized breathing guidance. This guide covers the integration architecture, App Store compliance requirements, and key development considerations.

---

## 2. Requested HealthKit Data Types

| Type | HealthKit Identifier | Purpose | Access |
|------|---------------------|---------|--------|
| Heart Rate | `HKQuantityTypeIdentifierHeartRate` | Calculate real-time stress level | **Read only** |
| HRV (SDNN) | `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` | Assess autonomic nervous system state | **Read only** |
| Resting Heart Rate | `HKQuantityTypeIdentifierRestingHeartRate` | Long-term baseline comparison | **Read only** |

> ⚠️ **Principle of Least Privilege**: Only request the HealthKit types your app actually uses. Requesting unused types will cause App Store rejection (violation of Guideline 5.1.1(iv)).

---

## 3. Info.plist Configuration

Add the usage description strings to both the **watchOS Target** and **iOS Target** `Info.plist` files:

### watchOS Target (WellnessWatch Watch App/Info.plist)

```xml
<key>NSHealthShareUsageDescription</key>
<string>WellnessWatch reads your heart rate and Heart Rate Variability (HRV)
to calculate a real-time stress indicator and provide personalized breathing
recommendations. All health data is processed on-device only and is never
transmitted to external servers.</string>
```

### iOS Target (WellnessWatch/Info.plist)

```xml
<key>NSHealthShareUsageDescription</key>
<string>WellnessWatch reads your heart rate and HRV data to display your
health trends and session history in the companion iPhone app. Data is used
locally only and is never sent externally.</string>
```

> 💡 **Quality requirement**: The description string must specifically explain *why* the data is needed. Vague descriptions like "to provide a better experience" may be flagged during review.

---

## 4. Code Architecture

### 4.1 Authorization Request

```swift
// HealthKitService.swift

func requestAuthorization() async throws {
    guard HKHealthStore.isHealthDataAvailable() else {
        // Apple Watch Simulator does not support HealthKit — graceful fallback
        throw HealthKitError.notAvailable
    }

    let typesToRead: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate)
    ]

    // Pass empty set for toShare — this app does NOT write to HealthKit
    try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
}
```

### 4.2 Best Practice: When to Request Authorization

```swift
// Request authorization when the user first attempts to use a
// HealthKit-dependent feature — NOT on app launch.

// ✅ Correct approach
struct SessionView: View {
    @StateObject var healthKit = HealthKitService()

    var body: some View {
        Button("Start Session") {
            Task {
                do {
                    try await healthKit.requestAuthorization()
                    await healthKit.startHeartRateMonitoring()
                } catch {
                    // Graceful fallback: session continues without health data
                    startSessionWithoutHealthData()
                }
            }
        }
    }
}

// ❌ Avoid requesting authorization in @main App init
```

### 4.3 Graceful Degradation (Permission Denied)

```swift
// The app must function fully when HealthKit access is denied.
// Core breathing guidance must never depend on HealthKit data.

func startSessionWithoutHealthData() {
    currentHeartRate = nil
    currentHRV = nil
    stressLevel = .unknown

    // Breathing session continues — HealthKit data is supplemental, not required
    breathingSession.start(pattern: selectedPattern)
}
```

---

## 5. Real-Time Heart Rate Monitoring

### Using HKAnchoredObjectQuery (Recommended)

```swift
func startHeartRateMonitoring() {
    let heartRateType = HKQuantityType(.heartRate)
    let unit = HKUnit(from: "count/min")

    // updateHandler is called on a background thread — dispatch UI updates to main
    let query = HKAnchoredObjectQuery(
        type: heartRateType,
        predicate: HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-300), // last 5 minutes
            end: nil
        ),
        anchor: nil,
        limit: HKObjectQueryNoLimit
    ) { [weak self] query, samples, deleted, anchor, error in
        guard let samples = samples as? [HKQuantitySample],
              let latest = samples.last else { return }

        let bpm = latest.quantity.doubleValue(for: unit)

        DispatchQueue.main.async {
            self?.currentHeartRate = bpm
            self?.updateStressLevel(heartRate: bpm)
        }
    }

    // Set the update handler to continuously receive new samples
    query.updateHandler = { [weak self] query, samples, deleted, anchor, error in
        guard let samples = samples as? [HKQuantitySample],
              let latest = samples.last else { return }

        let bpm = latest.quantity.doubleValue(for: unit)
        DispatchQueue.main.async {
            self?.currentHeartRate = bpm
        }
    }

    healthStore.execute(query)
    activeQueries.append(query)
}

// Always stop monitoring when the view disappears to preserve battery life
func stopMonitoring() {
    activeQueries.forEach { healthStore.stop($0) }
    activeQueries.removeAll()
}
```

---

## 6. HRV Reading

HRV (SDNN) is recorded by Apple Watch automatically during periods of rest. It is not a continuous real-time stream — fetch the most recent available sample:

```swift
func fetchLatestHRV() async -> Double? {
    let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
    let unit = HKUnit.secondUnit(with: .milli) // milliseconds

    return await withCheckedContinuation { continuation in
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: HKQuery.predicateForSamples(
                withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
                end: Date()
            ),
            limit: 1,
            sortDescriptors: [
                NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            ]
        ) { _, samples, _ in
            let hrv = (samples?.first as? HKQuantitySample)?
                .quantity.doubleValue(for: unit)
            continuation.resume(returning: hrv)
        }

        healthStore.execute(query)
    }
}
```

> 💡 If no HRV sample exists in the past 7 days, this returns `nil`. The app must handle this gracefully (display "Data unavailable" rather than crashing).

---

## 7. Stress Level Calculation

```swift
// Simplified model for MVP — v1.1 will introduce a machine learning model

enum StressLevel: String {
    case relaxed = "Relaxed"
    case mild    = "Mildly Stressed"
    case high    = "Highly Stressed"
    case unknown = "Measuring..."
}

func calculateStressLevel(heartRate: Double, hrv: Double?) -> StressLevel {
    guard heartRate > 0 else { return .unknown }

    // Compound assessment when HRV data is available
    if let hrv = hrv {
        switch (heartRate, hrv) {
        case (..<65, 50...):   return .relaxed
        case (65..<85, 30...): return .mild
        case (85..., ..<30):   return .high
        default:               return .mild
        }
    }

    // Heart-rate-only fallback
    switch heartRate {
    case ..<65:  return .relaxed
    case 65..<85: return .mild
    default:     return .high
    }
}
```

---

## 8. App Store Compliance Checklist

- [ ] `NSHealthShareUsageDescription` provides a specific, accurate explanation (watchOS + iOS)
- [ ] No unused HealthKit types are requested
- [ ] `toShare` is an empty set — app does not write to HealthKit
- [ ] Privacy Policy clearly explains HealthKit data usage
- [ ] App works correctly when authorization is denied (graceful degradation tested)
- [ ] HealthKit data is **not** used for advertising targeting
- [ ] HealthKit data is **not** shared with third-party advertising services

### Reviewer FAQ

**Q: Why do you need heart rate access?**
A: To show users a before/after stress comparison, quantifying the effect of each breathing session.

**Q: Where does this data go?**
A: Health data is processed on-device only. The optional AI feature sends only anonymous delta statistics (e.g., "heart rate decreased 8 bpm"), never raw HealthKit samples.

**Q: Why do you need HRV access?**
A: HRV is a scientifically validated indicator of autonomic nervous system state. We use it to recommend the most appropriate breathing pattern for the user's current condition.

---

## 9. Testing Notes

### Simulator Limitations

The Apple Watch Simulator **does not support HealthKit**. The following require a physical device:
- Real-time heart rate monitoring
- HRV data reading (requires existing HRV history from daily wear)
- Authorization request UI flow

### Building Test Data

Use a test device that has been worn daily for several weeks to ensure a realistic HRV history is available for all test scenarios.

### Testing Permission Denial

Navigate to iPhone Settings → Privacy & Security → Health → WellnessWatch, disable all permissions, and verify the app's graceful degradation mode works correctly.

---

## 10. Reference Resources

- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [App Review Guideline 5.1.3 — Health & Health Research Apps](https://developer.apple.com/app-store/review/guidelines/#health-and-health-research)
- [WWDC: What's New in HealthKit](https://developer.apple.com/videos/frameworks/health-and-fitness)
- [Human Interface Guidelines — HealthKit](https://developer.apple.com/design/human-interface-guidelines/healthkit)
