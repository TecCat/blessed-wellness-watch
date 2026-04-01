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

// MARK: - BreathingView

struct BreathingView: View {

    let pattern: BreathingPattern

    /// Invoked when the session ends (natural completion OR early stop).
    /// - Parameters:
    ///   - completedCycles: how many full cycles finished
    ///   - isCompleted: true = finished all cycles naturally
    var onSessionEnd: ((Int, Bool) -> Void)? = nil

    @StateObject private var session = BreathingSession()

    @State private var circleScale: CGFloat = 0.6
    @State private var circleColor: Color = BreathingColors.inhale
    @State private var showStopAlert = false

    @Environment(\.dismiss) private var dismiss

    // MARK: Body

    var body: some View {
        ZStack {
            BreathingColors.background.ignoresSafeArea()

            VStack(spacing: 10) {
                breathingCircle
                phaseLabel
                progressSection
                stopButton
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            startSession()
        }
        .onChange(of: session.currentPhase) { _, phase in
            applyPhaseAnimation(phase)
        }
        .onChange(of: session.isRunning) { _, running in
            guard !running else { return }
            if session.isCompleted { HapticService.shared.playCompletion() }
            onSessionEnd?(session.completedCycles, session.isCompleted)
            dismiss()
        }
        .alert("確定要結束練習？", isPresented: $showStopAlert) {
            Button("繼續", role: .cancel) { }
            Button("結束", role: .destructive) { session.stop() }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Subviews

    private var breathingCircle: some View {
        ZStack {
            // Filled glow
            Circle()
                .fill(circleColor.opacity(0.18))
                .frame(width: 110, height: 110)
                .scaleEffect(circleScale)

            // Stroke ring
            Circle()
                .strokeBorder(circleColor, lineWidth: 2.5)
                .frame(width: 110, height: 110)
                .scaleEffect(circleScale)

            // Countdown number (PRD §7.3: 28 pt light rounded)
            Text(session.countdownText)
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: session.countdownText)
        }
        // Circle scale+color animate over the full phase duration
        .animation(.easeInOut(duration: session.currentPhaseDuration), value: circleScale)
        .animation(.easeInOut(duration: 0.5), value: circleColor)
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

            Text("完成 \(session.completedCycles) / \(session.totalCycles) 輪")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
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
        BreathingView(pattern: .box)
    }
}

#Preview("4-7-8") {
    NavigationStack {
        BreathingView(pattern: .breathing478)
    }
}

#Preview("生理式嘆息") {
    NavigationStack {
        BreathingView(pattern: .physiologicalSigh)
    }
}
