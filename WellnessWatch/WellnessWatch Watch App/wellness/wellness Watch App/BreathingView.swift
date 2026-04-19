// WellnessWatch Watch App/Views/BreathingView.swift
import SwiftUI

// MARK: - Color constants (PRD §7.2)

enum BreathingColors {
    static let inhale     = Color(red: 0.200, green: 0.510, blue: 0.898)  // #3382E5
    static let hold       = Color(red: 0.482, green: 0.310, blue: 0.796)  // #7B4FCB
    static let exhale     = Color(red: 0.184, green: 0.737, blue: 0.698)  // #2FBCB2
    static let rest       = Color(red: 0.290, green: 0.290, blue: 0.416)  // #4A4A6A
    static let background = Color(red: 0.051, green: 0.051, blue: 0.102)  // #0D0D1A
}

// MARK: - BoxAnimationView

struct BoxAnimationView: View {
    let phase: BreathingPhase
    let phaseProgress: Double   // 0.0 – 1.0 within current phase
    let countdownText: String

    private let size: CGFloat = 100
    private let lineWidth: CGFloat = 5
    private let corner: CGFloat = 18

    var body: some View {
        ZStack {
            // Background track
            RoundedRectangle(cornerRadius: corner)
                .stroke(Color.white.opacity(0.10), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Completed segments (dim)
            if phaseSegmentStart > 0 {
                RoundedRectangle(cornerRadius: corner)
                    .trim(from: 0, to: phaseSegmentStart)
                    .stroke(
                        Color.white.opacity(0.22),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
            }

            // Current phase animated segment
            RoundedRectangle(cornerRadius: corner)
                .trim(from: phaseSegmentStart,
                      to: phaseSegmentStart + 0.25 * phaseProgress)
                .stroke(
                    phaseColor,
                    style: StrokeStyle(lineWidth: lineWidth + 1.5, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: phaseProgress)

            // Countdown number
            Text(countdownText)
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: countdownText)
        }
    }

    private var phaseIndex: Int {
        switch phase {
        case .inhale:  return 0
        case .hold:    return 1
        case .exhale:  return 2
        case .rest:    return 3
        default:       return 0
        }
    }

    private var phaseSegmentStart: Double { Double(phaseIndex) * 0.25 }

    private var phaseColor: Color {
        switch phase {
        case .inhale:  return BreathingColors.inhale
        case .hold:    return BreathingColors.hold
        case .exhale:  return BreathingColors.exhale
        case .rest:    return BreathingColors.hold
        default:       return .white
        }
    }
}

// MARK: - BreathingView

struct BreathingView: View {

    let pattern: BreathingPattern
    let selectedPace: PaceOption

    /// Invoked when the session ends (natural completion OR early stop).
    /// - Parameters:
    ///   - completedCycles: how many full cycles finished
    ///   - isCompleted: true = finished all cycles naturally
    var onSessionEnd: ((Int, Bool) -> Void)? = nil

    private let startedAt = Date()

    @StateObject private var session = BreathingSession()

    @State private var hasStarted = false          // guard against re-start on re-appear
    @State private var circleScale: CGFloat = 0.6
    @State private var circleColor: Color = BreathingColors.inhale
    @State private var showStopAlert = false
    @State private var showResult = false

    @Environment(\.dismiss) private var dismiss

    // MARK: Body

    var body: some View {
        ZStack {
            BreathingColors.background.ignoresSafeArea()

            VStack(spacing: 10) {
                breathingAnimation
                phaseLabel
                progressSection
                stopButton
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            startSession()
        }
        .onChange(of: session.currentPhase) { _, phase in
            applyPhaseAnimation(phase)
        }
        .onChange(of: session.isRunning) { _, running in
            guard !running else { return }
            HapticService.shared.playCompletion()
            showResult = true
        }
        .alert("確定要結束練習？", isPresented: $showStopAlert) {
            Button("繼續", role: .cancel) { }
            Button("結束", role: .destructive) { session.stop() }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showResult) {
            ResultView(
                pattern: pattern,
                completedCycles: session.completedCycles,
                totalCycles: session.totalCycles,
                isCompleted: session.isCompleted,
                elapsedSeconds: session.totalSecondsElapsed,
                onDone: {
                    showResult = false
                    dismiss()
                },
                paceLabel: selectedPace.label,
                startedAt: startedAt
            )
        }
    }

    // MARK: Subviews

    @ViewBuilder
    private var breathingAnimation: some View {
        if pattern.animationStyle == .box {
            BoxAnimationView(
                phase: session.currentPhase,
                phaseProgress: session.phaseProgress,
                countdownText: session.countdownText
            )
        } else {
            // 原有圓圈 UI
            ZStack {
                Circle()
                    .fill(circleColor.opacity(0.18))
                    .frame(width: 110, height: 110)
                    .scaleEffect(circleScale)
                Circle()
                    .strokeBorder(circleColor, lineWidth: 2.5)
                    .frame(width: 110, height: 110)
                    .scaleEffect(circleScale)
                Text(session.countdownText)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: session.countdownText)
            }
            .animation(.easeInOut(duration: session.currentPhaseDuration), value: circleScale)
            .animation(.easeInOut(duration: 0.5), value: circleColor)
        }
    }

    private var phaseLabel: some View {
        Text(session.currentPhase.label)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white.opacity(0.85))
            .animation(.easeInOut(duration: 0.3), value: session.currentPhase)
    }

    private var progressSection: some View {
        VStack(spacing: 4) {
            ProgressView(value: session.progress)
                .progressViewStyle(.linear)
                .tint(circleColor)
                .frame(width: 130)
                .animation(.linear(duration: 1), value: session.progress)

            Text("剩餘 \(session.timeRemainingText)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
                .contentTransition(.numericText())
                .animation(.linear(duration: 1), value: session.timeRemainingText)
        }
    }

    private var stopButton: some View {
        Button {
            showStopAlert = true
        } label: {
            Text("停止")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .padding(.vertical, 4)
                .padding(.horizontal, 18)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private func startSession() {
        session.start(pattern: pattern)
        // Kick off the initial animation without waiting for onChange
        applyPhaseAnimation(.inhale)
    }

    private func applyPhaseAnimation(_ phase: BreathingPhase) {
        HapticService.shared.play(for: phase)
        withAnimation(.easeInOut(duration: session.currentPhaseDuration)) {
            switch phase {
            case .inhale:
                circleScale = 1.0
                circleColor = BreathingColors.inhale
            case .inhale2:
                // 圓圈已撐大，維持 1.0；顏色保持吸氣藍。
                // 視覺變化極小是刻意的——使用者靠 label「再吸！」與 haptic .click 感知此 phase。
                circleScale = 1.0
                circleColor = BreathingColors.inhale
            case .hold:
                circleScale = 1.0  // stays expanded
                circleColor = BreathingColors.hold
            case .exhale:
                circleScale = 0.6
                circleColor = BreathingColors.exhale
            case .rest:
                circleScale = 0.6
                circleColor = BreathingColors.rest
            }
        }
    }
}

// MARK: - Preview

#Preview("Box Breathing") {
    NavigationStack {
        BreathingView(pattern: .box, selectedPace: .standard)
    }
}

#Preview("4-7-8") {
    NavigationStack {
        BreathingView(pattern: .breathing478, selectedPace: .standard)
    }
}

#Preview("生理式嘆息") {
    NavigationStack {
        BreathingView(pattern: .physiologicalSigh, selectedPace: .standard)
    }
}
