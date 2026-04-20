// WellnessWatch Watch App/Views/PreviewView.swift
import SwiftUI

// MARK: - PaceOption

enum PaceOption: CaseIterable, Equatable {
    case slow, standard, fast

    var label: String {
        switch self {
        case .slow:     return L.isEnglish ? "Slow" : "慢"
        case .standard: return L.isEnglish ? "Normal" : "標準"
        case .fast:     return L.isEnglish ? "Fast" : "快"
        }
    }

    var icon: String {
        switch self {
        case .slow:     return "🐢"
        case .standard: return "◎"
        case .fast:     return "🐇"
        }
    }

    var multiplier: Double {
        switch self {
        case .slow:     return 1.5
        case .standard: return 1.0
        case .fast:     return 0.75
        }
    }

    static func recommend(from hr: Double) -> PaceOption {
        if hr > 80 { return .slow }
        if hr < 65 { return .fast }
        return .standard
    }
}

// MARK: - PreviewView

struct PreviewView: View {

    let pattern: BreathingPattern

    @EnvironmentObject private var nav: AppNav
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKit = HealthKitService()
    @State private var selectedMinutes: Int
    @State private var selectedPace: PaceOption = .standard
    @State private var assessmentPicked: Bool = false

    init(pattern: BreathingPattern) {
        self.pattern = pattern
        _selectedMinutes = State(initialValue: pattern.totalDurationMinutes)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                // Effect label
                HStack(spacing: 5) {
                    Circle()
                        .fill(pattern.accentColor)
                        .frame(width: 7, height: 7)
                    Text(pattern.effectLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                }

                // Phase rhythm (scaled)
                rhythmRow

                Divider().overlay(.white.opacity(0.1))

                // Pace section
                paceSection

                Divider().overlay(.white.opacity(0.1))

                // Duration picker
                VStack(spacing: 3) {
                    Text(L.durationLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                    Picker("", selection: $selectedMinutes) {
                        ForEach([2, 3, 4, 5, 7, 10, 15, 20], id: \.self) { min in
                            Text("\(min) 分鐘").tag(min)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }

                // Start button
                NavigationLink {
                    BreathingView(pattern: adjustedPattern, selectedPace: selectedPace)
                } label: {
                    Text(L.startButton)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(pattern.accentColor,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .onChange(of: nav.shouldPopToRoot) { _, should in
            if should { dismiss() }
        }
        .navigationTitle(pattern.name)
        .task {
            await healthKit.requestAuthorizationIfNeeded()
            if healthKit.isAuthorized {
                healthKit.startHeartRateMonitoring()
                await healthKit.fetchLatestHRV()
                // Auto-set pace from HR once data arrives
                if healthKit.currentHeartRate > 0 && !assessmentPicked {
                    selectedPace = PaceOption.recommend(from: healthKit.currentHeartRate)
                }
            }
        }
    }

    // MARK: Pace Section

    @ViewBuilder
    private var paceSection: some View {
        VStack(spacing: 6) {
            if healthKit.isAuthorized && healthKit.currentHeartRate > 0 {
                // HealthKit mode: show HR source + auto recommendation
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.red.opacity(0.8))
                    Text("\(Int(healthKit.currentHeartRate)) bpm → \(selectedPace.label)節奏")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
            } else if !assessmentPicked {
                // Fallback: self-assessment
                Text(L.howAreYou)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 8) {
                    assessmentButton("😰", pace: .slow,  label: L.feelTense)
                    assessmentButton("😐", pace: .standard, label: L.feelNeutral)
                    assessmentButton("😊", pace: .fast,  label: L.feelCalm)
                }
            } else {
                Text("節奏已設定")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }

            // Always-visible pace override buttons
            paceOverrideRow
        }
    }

    private func assessmentButton(_ emoji: String, pace: PaceOption, label: String) -> some View {
        Button {
            selectedPace = pace
            assessmentPicked = true
        } label: {
            VStack(spacing: 2) {
                Text(emoji).font(.title3)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background(
                selectedPace == pace && assessmentPicked
                    ? pattern.accentColor.opacity(0.25)
                    : Color.white.opacity(0.07),
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }

    private var paceOverrideRow: some View {
        HStack(spacing: 5) {
            ForEach(PaceOption.allCases, id: \.self) { pace in
                Button {
                    selectedPace = pace
                    assessmentPicked = true
                } label: {
                    HStack(spacing: 3) {
                        Text(pace.icon).font(.system(size: 10))
                        Text(pace.label)
                            .font(.system(size: 10, weight: selectedPace == pace ? .semibold : .regular))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(
                        selectedPace == pace
                            ? pattern.accentColor.opacity(0.3)
                            : Color.white.opacity(0.07),
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                selectedPace == pace
                                    ? pattern.accentColor.opacity(0.6)
                                    : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Rhythm Row (scaled durations)

    private var rhythmRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(scaledSteps.enumerated()), id: \.offset) { _, step in
                VStack(spacing: 2) {
                    Text(step.phase.label)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                    Text(String(format: "%.0fs", step.duration))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 7)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.2), value: selectedPace)
    }

    // MARK: Helpers

    private var scaledSteps: [PhaseStep] {
        pattern.steps.map {
            PhaseStep(phase: $0.phase, duration: ($0.duration * selectedPace.multiplier).rounded())
        }
    }

    private var adjustedPattern: BreathingPattern {
        BreathingPattern(
            id: pattern.id,
            name: pattern.name,
            steps: scaledSteps,
            totalDurationMinutes: selectedMinutes
        )
    }
}

// MARK: - Preview

#Preview("4-7-8 Standard") {
    NavigationStack { PreviewView(pattern: .breathing478) }
        .environmentObject(AppNav())
}

#Preview("Box Breathing") {
    NavigationStack { PreviewView(pattern: .box) }
        .environmentObject(AppNav())
}
