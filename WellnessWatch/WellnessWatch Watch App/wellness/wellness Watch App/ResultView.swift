// WellnessWatch Watch App/Views/ResultView.swift
import SwiftUI
import SwiftData

struct ResultView: View {

    let pattern: BreathingPattern
    let completedCycles: Int
    let totalCycles: Int
    let isCompleted: Bool
    let elapsedSeconds: Double
    let onDone: () -> Void
    let paceLabel: String
    let startedAt: Date

    @EnvironmentObject private var nav: AppNav
    @Environment(\.modelContext) private var modelContext

    // Past sessions for history summary (newest first)
    @Query(sort: \SessionRecord.startedAt, order: .reverse) private var allRecords: [SessionRecord]

    @StateObject private var coach   = AICoachService()
    @StateObject private var healthKit = HealthKitService()
    @State private var sessionSaved  = false

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Header emoji + title
                VStack(spacing: 4) {
                    Text(isCompleted ? "🎉" : "⏹️")
                        .font(.system(size: 38))
                    Text(isCompleted ? L.sessionDone : L.sessionStopped)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 4)

                // Stats row
                HStack(spacing: 0) {
                    statItem(value: elapsedFormatted, label: L.statDuration)
                    Rectangle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 1, height: 28)
                    statItem(value: "\(completedCycles)", label: L.statCycles)
                    Rectangle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 1, height: 28)
                    statItem(value: pattern.name.components(separatedBy: " ").first ?? "", label: L.statMode)
                }
                .padding(.vertical, 10)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))

                // Encouragement (built-in, always shown)
                if isCompleted {
                    Text(L.encouragement(pattern.id))
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }

                // AI Coach feedback card
                coachCard

                // Done button — reset showResult first, then pop to root
                Button(action: {
                    onDone()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        nav.popToRoot()
                    }
                }) {
                    Text(L.doneButton)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            pattern.accentColor,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .onAppear {
            saveSessionIfNeeded()
        }
        .task {
            // Brief delay so the record is committed before querying history
            try? await Task.sleep(nanoseconds: 150_000_000)

            // Read latest HealthKit values (session just ended, still current)
            await healthKit.requestAuthorizationIfNeeded()
            if healthKit.isAuthorized {
                await healthKit.fetchLatestHRV()
            }

            // Past records = everything except the one we just saved
            // allRecords is sorted newest-first, so index 0 is the current session
            let past = Array(allRecords.dropFirst().prefix(50))

            await coach.fetchFeedback(
                patternID:       pattern.id,
                patternName:     pattern.name,
                durationSeconds: elapsedSeconds,
                completedCycles: completedCycles,
                totalCycles:     totalCycles,
                wasCompleted:    isCompleted,
                paceLabel:       paceLabel,
                heartRate:       healthKit.isAuthorized ? healthKit.currentHeartRate : nil,
                hrv:             healthKit.isAuthorized ? healthKit.currentHRV : nil,
                pastRecords:     past
            )
        }
        .background(BreathingColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - AI Coach Card

    @ViewBuilder
    private var coachCard: some View {
        Group {
            if coach.isLoading {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white.opacity(0.5))
                    Text(L.isEnglish ? "Coach thinking…" : "教練思考中…")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))

            } else if let text = coach.feedback {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundStyle(pattern.accentColor.opacity(0.8))
                        Text(L.isEnglish ? "Coach" : "教練回饋")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(pattern.accentColor.opacity(0.8))
                    }
                    Text(text)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)

                    // Next pattern suggestion (if any)
                    if let next = coach.nextSuggestion, !next.reason.isEmpty {
                        Divider().overlay(.white.opacity(0.1))
                        Text(next.reason)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.45))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Achievement badge (if any)
                    if let badge = coach.achievement, !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.yellow.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(pattern.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(pattern.accentColor.opacity(0.2), lineWidth: 1)
                )

            }
            // hasFailed → silently omit card (never show error to user)
        }
    }

    // MARK: Helpers

    private func saveSessionIfNeeded() {
        guard !sessionSaved else { return }
        sessionSaved = true
        let record = SessionRecord(
            patternID:       pattern.id,
            patternName:     pattern.name,
            startedAt:       startedAt,
            elapsedSeconds:  elapsedSeconds,
            completedCycles: completedCycles,
            totalCycles:     totalCycles,
            wasCompleted:    isCompleted,
            paceLabel:       paceLabel
        )
        modelContext.insert(record)
        AppLogger.session("Saved session: \(pattern.id), \(Int(elapsedSeconds))s, completed=\(isCompleted)")
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }

    private var elapsedFormatted: String {
        let mins = Int(elapsedSeconds) / 60
        let secs = Int(elapsedSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Preview

#Preview("Completed") {
    NavigationStack {
        ResultView(
            pattern: .box,
            completedCycles: 8,
            totalCycles: 8,
            isCompleted: true,
            elapsedSeconds: 300,
            onDone: {},
            paceLabel: "標準",
            startedAt: Date()
        )
    }
    .environmentObject(AppNav())
    .modelContainer(for: SessionRecord.self, inMemory: true)
}

#Preview("Stopped Early") {
    NavigationStack {
        ResultView(
            pattern: .breathing478,
            completedCycles: 3,
            totalCycles: 10,
            isCompleted: false,
            elapsedSeconds: 57,
            onDone: {},
            paceLabel: "標準",
            startedAt: Date()
        )
    }
    .environmentObject(AppNav())
    .modelContainer(for: SessionRecord.self, inMemory: true)
}
