// WellnessWatch Watch App/Models/BreathingSession.swift
import Foundation
import Combine

// MARK: - BreathingPhase

enum BreathingPhase: Equatable {
    case inhale, inhale2, hold, exhale, rest

    var label: String {
        switch self {
        case .inhale:  return "吸氣"
        case .inhale2: return "再吸！"
        case .hold:    return "屏氣"
        case .exhale:  return "吐氣"
        case .rest:    return "放鬆"
        }
    }
}

// MARK: - PhaseStep

struct PhaseStep {
    let phase: BreathingPhase
    let duration: Double  // seconds
}

// MARK: - BreathingPattern

struct BreathingPattern: Identifiable {
    let id: String
    let name: String
    let steps: [PhaseStep]
    let totalDurationMinutes: Int

    var cycleDuration: Double {
        steps.reduce(0) { $0 + $1.duration }
    }

    var totalCycles: Int {
        let total = Double(totalDurationMinutes * 60)
        return max(1, Int(total / cycleDuration))
    }

    // MARK: Static definitions (PRD §4.1.1)

    static let breathing478 = BreathingPattern(
        id: "4-7-8",
        name: "4-7-8 呼吸法",
        steps: [
            PhaseStep(phase: .inhale, duration: 4),
            PhaseStep(phase: .hold,   duration: 7),
            PhaseStep(phase: .exhale, duration: 8),
        ],
        totalDurationMinutes: 4
    )

    static let box = BreathingPattern(
        id: "box",
        name: "Box Breathing",
        steps: [
            PhaseStep(phase: .inhale, duration: 4),
            PhaseStep(phase: .hold,   duration: 4),
            PhaseStep(phase: .exhale, duration: 4),
        ],
        totalDurationMinutes: 5
    )

    static let diaphragmatic = BreathingPattern(
        id: "diaphragmatic",
        name: "腹式呼吸",
        steps: [
            PhaseStep(phase: .inhale, duration: 5),
            PhaseStep(phase: .exhale, duration: 5),
        ],
        totalDurationMinutes: 5
    )

    static let resonance = BreathingPattern(
        id: "resonance",
        name: "共鳴呼吸",
        steps: [
            PhaseStep(phase: .inhale, duration: 5),
            PhaseStep(phase: .exhale, duration: 5),
        ],
        totalDurationMinutes: 10
    )

    /// 生理式嘆息（Physiological Sigh）
    /// 節奏：快吸 2s → 補吸 1s → 長吐 7s（共 10s/輪）
    /// 科學依據：雙次吸氣可重新打開塌陷的肺泡，長吐氣快速啟動副交感神經。
    static let physiologicalSigh = BreathingPattern(
        id: "physiological-sigh",
        name: "生理式嘆息",
        steps: [
            PhaseStep(phase: .inhale,  duration: 2),   // 深吸（鼻）
            PhaseStep(phase: .inhale2, duration: 1),   // 補吸一口（鼻）
            PhaseStep(phase: .exhale,  duration: 7),   // 緩慢長吐（嘴）
        ],
        totalDurationMinutes: 5
    )

    static let all: [BreathingPattern] = [
        .breathing478, .box, .diaphragmatic, .resonance, .physiologicalSigh
    ]
}

// MARK: - BreathingSession

final class BreathingSession: ObservableObject {

    // MARK: Published state (read-only outside)
    @Published private(set) var currentPhase: BreathingPhase = .inhale
    @Published private(set) var currentPhaseDuration: Double = 4
    @Published private(set) var countdownText: String = "4"
    @Published private(set) var progress: Double = 0       // 0.0 – 1.0 overall
    @Published private(set) var completedCycles: Int = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isCompleted: Bool = false  // true = natural finish

    // MARK: Pattern info
    private(set) var pattern: BreathingPattern = .box
    var totalCycles: Int { pattern.totalCycles }

    // MARK: Private timer state
    private var timer: AnyCancellable?
    private var stepIndex: Int = 0
    private var phaseSecondsRemaining: Double = 0
    private var totalSecondsElapsed: Double = 0
    private var totalSessionSeconds: Double { Double(pattern.totalDurationMinutes * 60) }

    // MARK: Control

    func start(pattern: BreathingPattern) {
        self.pattern = pattern
        stepIndex = 0
        completedCycles = 0
        totalSecondsElapsed = 0
        isCompleted = false

        let first = pattern.steps[0]
        applyStep(first)
        progress = 0
        isRunning = true

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }

    // MARK: Private

    private func tick() {
        totalSecondsElapsed += 1
        phaseSecondsRemaining -= 1
        progress = min(totalSecondsElapsed / totalSessionSeconds, 1.0)

        if phaseSecondsRemaining <= 0 {
            // Advance to next step
            stepIndex = (stepIndex + 1) % pattern.steps.count

            if stepIndex == 0 {
                completedCycles += 1
                if completedCycles >= totalCycles {
                    stop()
                    isCompleted = true
                    progress = 1.0
                    return
                }
            }

            applyStep(pattern.steps[stepIndex])
            return  // countdownText already set in applyStep
        }

        countdownText = formatted(phaseSecondsRemaining)
    }

    private func applyStep(_ step: PhaseStep) {
        currentPhase = step.phase
        currentPhaseDuration = step.duration
        phaseSecondsRemaining = step.duration
        countdownText = formatted(step.duration)
    }

    private func formatted(_ seconds: Double) -> String {
        String(max(0, Int(ceil(seconds))))
    }
}
