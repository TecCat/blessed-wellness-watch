// WellnessWatch Watch App/Services/HealthKitService.swift
import Foundation
import HealthKit
import SwiftUI
import Combine

// MARK: - StressLevel (PRD §4.2.2)

enum StressLevel {
    case relaxed, mild, high, measuring

    var emoji: String {
        switch self {
        case .relaxed:   return "😌"
        case .mild:      return "😐"
        case .high:      return "😰"
        case .measuring: return "⏳"
        }
    }

    var label: String {
        switch self {
        case .relaxed:   return "放鬆"
        case .mild:      return "輕度緊張"
        case .high:      return "高度緊張"
        case .measuring: return "測量中..."
        }
    }

    var color: Color {
        switch self {
        case .relaxed:   return Color(red: 0.184, green: 0.737, blue: 0.698) // Teal
        case .mild:      return Color(red: 0.200, green: 0.510, blue: 0.898) // Blue
        case .high:      return Color(red: 1.000, green: 0.270, blue: 0.270) // Red
        case .measuring: return Color.gray
        }
    }
}

// MARK: - HealthKitService

final class HealthKitService: ObservableObject {

    // MARK: Published state
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var currentHeartRate: Double = 0
    @Published private(set) var currentHRV: Double = 0
    @Published private(set) var stressLevel: StressLevel = .measuring

    // MARK: Private
    private let store = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?

    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate)
    ]

    // MARK: Authorization (PRD §4.2.1 — request on first session tap, not on launch)

    func requestAuthorizationIfNeeded() async {
        // Guard 1: HealthKit must be available on this device
        guard HKHealthStore.isHealthDataAvailable() else { return }
        // Guard 2: NSHealthShareUsageDescription must exist in Info.plist
        // (missing = HealthKit capability not added → skip to avoid crash)
        guard Bundle.main.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") != nil else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: typesToRead)
            let status = store.authorizationStatus(for: HKQuantityType(.heartRate))
            await MainActor.run {
                isAuthorized = (status == .sharingAuthorized)
            }
        } catch {
            // Authorization denied or unavailable — graceful degradation
            await MainActor.run { isAuthorized = false }
        }
    }

    // MARK: Heart Rate Monitoring

    func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType(.heartRate)
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.process(heartRateSamples: samples as? [HKQuantitySample])
        }
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.process(heartRateSamples: samples as? [HKQuantitySample])
        }
        store.execute(query)
        heartRateQuery = query
    }

    func stopHeartRateMonitoring() {
        if let q = heartRateQuery { store.stop(q) }
        heartRateQuery = nil
    }

    // MARK: HRV (most recent SDNN within 7 days — PRD §4.2.1)

    func fetchLatestHRV() async {
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        let predicate = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: .now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let hrv: Double? = await withCheckedContinuation { cont in
            let q = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: HKUnit(from: "ms"))
                cont.resume(returning: value)
            }
            store.execute(q)
        }

        await MainActor.run {
            currentHRV = hrv ?? 0
            updateStressLevel()
        }
    }

    // MARK: Private helpers

    private func process(heartRateSamples: [HKQuantitySample]?) {
        guard let latest = heartRateSamples?.last else { return }
        let bpm = latest.quantity.doubleValue(
            for: HKUnit(from: "count/min")
        )
        DispatchQueue.main.async { [weak self] in
            self?.currentHeartRate = bpm
            self?.updateStressLevel()
        }
    }

    /// Simplified compound stress model (PRD §4.2.2)
    private func updateStressLevel() {
        let hr  = currentHeartRate
        let hrv = currentHRV

        guard hr > 0 else {
            stressLevel = .measuring
            return
        }

        if hr < 65 && (hrv == 0 || hrv > 50) {
            stressLevel = .relaxed
        } else if hr < 85 && (hrv == 0 || hrv >= 30) {
            stressLevel = .mild
        } else {
            stressLevel = .high
        }
    }
}
