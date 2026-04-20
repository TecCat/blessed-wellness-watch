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
    @State private var sessionSaved = false

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

                // Encouragement
                if isCompleted {
                    Text(encouragementText)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }

                // Done button — reset showResult first, then pop to root
                Button(action: {
                    onDone()   // sets showResult = false in BreathingView
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
            guard !sessionSaved else { return }
            sessionSaved = true
            let record = SessionRecord(
                patternID: pattern.id,
                patternName: pattern.name,
                startedAt: startedAt,
                elapsedSeconds: elapsedSeconds,
                completedCycles: completedCycles,
                totalCycles: totalCycles,
                wasCompleted: isCompleted,
                paceLabel: paceLabel
            )
            modelContext.insert(record)
            AppLogger.session("Saved session: \(pattern.id), \(Int(elapsedSeconds))s, completed=\(isCompleted)")
        }
        .background(BreathingColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Helpers

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

    private var encouragementText: String {
        L.encouragement(pattern.id)
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
