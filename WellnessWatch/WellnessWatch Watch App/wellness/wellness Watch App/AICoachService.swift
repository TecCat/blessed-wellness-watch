// WellnessWatch Watch App/Services/AICoachService.swift
import Foundation
import Combine
import SwiftData

// MARK: - DTO models (Encodable/Decodable only – no SwiftData)

private struct HistorySummaryDTO: Encodable {
    let avg_duration_seconds:  Double
    let avg_completion_rate:   Double
    let sessions_this_week:    Int
    let sessions_last_week:    Int
    let avg_pace_label:        String
    let most_used_pattern_id:  String
}

private struct CoachRequest: Encodable {
    let pattern_id:       String
    let pattern_name:     String
    let duration_seconds: Double
    let completed_cycles: Int
    let total_cycles:     Int
    let was_completed:    Bool
    let pace_label:       String
    let heart_rate:       Double?
    let hrv:              Double?
    let history:          HistorySummaryDTO?
    let locale:           String
}

private struct CoachResponse: Decodable {
    let feedback:             String
    let next_pattern_id:      String?
    let next_pattern_reason:  String?
}

// MARK: - AICoachService

@MainActor
final class AICoachService: ObservableObject {

    // ---------------------------------------------------------------
    // Backend URL
    // Simulator  → http://localhost:8000
    // Real device (same Wi-Fi) → http://<Mac-LAN-IP>:8000
    // ---------------------------------------------------------------
    static let backendURL = "http://localhost:8000"

    @Published var feedback:      String? = nil
    @Published var nextPatternID: String? = nil
    @Published var nextReason:    String? = nil
    @Published var isLoading:     Bool    = false
    @Published var hasFailed:     Bool    = false

    // MARK: Public entry point

    func fetchFeedback(
        patternID:       String,
        patternName:     String,
        durationSeconds: Double,
        completedCycles: Int,
        totalCycles:     Int,
        wasCompleted:    Bool,
        paceLabel:       String,
        heartRate:       Double?,
        hrv:             Double?,
        pastRecords:     [SessionRecord]
    ) async {
        isLoading = true
        hasFailed = false
        feedback  = nil

        let locale  = Locale.current.language.languageCode?.identifier == "en" ? "en" : "zh-TW"
        let history = buildHistory(from: pastRecords)

        let body = CoachRequest(
            pattern_id:       patternID,
            pattern_name:     patternName,
            duration_seconds: durationSeconds,
            completed_cycles: completedCycles,
            total_cycles:     totalCycles,
            was_completed:    wasCompleted,
            pace_label:       paceLabel,
            heart_rate:       (heartRate ?? 0) > 0 ? heartRate : nil,
            hrv:              (hrv ?? 0) > 0 ? hrv : nil,
            history:          history,
            locale:           locale
        )

        guard let url = URL(string: "\(Self.backendURL)/coach/feedback") else {
            isLoading = false; hasFailed = true; return
        }

        var req = URLRequest(url: url, timeoutInterval: 12)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            req.httpBody      = try JSONEncoder().encode(body)
            let (data, _)     = try await URLSession.shared.data(for: req)
            let decoded       = try JSONDecoder().decode(CoachResponse.self, from: data)
            feedback          = decoded.feedback
            nextPatternID     = decoded.next_pattern_id
            nextReason        = decoded.next_pattern_reason
        } catch {
            AppLogger.error("AICoachService: \(error.localizedDescription)", category: "coach")
            hasFailed = true
        }

        isLoading = false
    }

    // MARK: - History builder

    private func buildHistory(from records: [SessionRecord]) -> HistorySummaryDTO? {
        guard !records.isEmpty else { return nil }

        let calendar      = Calendar.current
        let now           = Date()
        let thisWeekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!

        let thisWeek = records.filter { $0.startedAt >= thisWeekStart }
        let lastWeek = records.filter { $0.startedAt >= lastWeekStart && $0.startedAt < thisWeekStart }

        let count    = Double(records.count)
        let avgDur   = records.reduce(0.0) { $0 + $1.elapsedSeconds } / count
        let avgComp  = records.reduce(0.0) { r, rec in
            r + (rec.wasCompleted
                 ? 1.0
                 : Double(rec.completedCycles) / Double(max(rec.totalCycles, 1)))
        } / count

        let avgPace = Dictionary(grouping: records, by: \.paceLabel)
            .mapValues(\.count)
            .max(by: { $0.value < $1.value })?.key ?? "標準"

        let topPattern = Dictionary(grouping: records, by: \.patternID)
            .mapValues(\.count)
            .max(by: { $0.value < $1.value })?.key ?? ""

        return HistorySummaryDTO(
            avg_duration_seconds:  avgDur,
            avg_completion_rate:   avgComp,
            sessions_this_week:    thisWeek.count,
            sessions_last_week:    lastWeek.count,
            avg_pace_label:        avgPace,
            most_used_pattern_id:  topPattern
        )
    }
}
