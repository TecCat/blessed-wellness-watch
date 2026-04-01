// WellnessWatch Watch App/Services/HapticService.swift
import WatchKit

final class HapticService {
    static let shared = HapticService()
    private init() {}

    // MARK: Phase cues (PRD §4.1.3)

    func play(for phase: BreathingPhase) {
        switch phase {
        case .inhale:
            // Double cue: .start then .click 300 ms later
            WKInterfaceDevice.current().play(.start)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                WKInterfaceDevice.current().play(.click)
            }
        case .inhale2:
            // Single sharp click — "補一口" 的短促提示，有別於第一吸的雙重震動
            WKInterfaceDevice.current().play(.click)
        case .hold:
            // Single notification at hold start; repeating every-2s handled by caller if needed
            WKInterfaceDevice.current().play(.notification)
        case .exhale:
            WKInterfaceDevice.current().play(.stop)
        case .rest:
            break
        }
    }

    func playCompletion() {
        WKInterfaceDevice.current().play(.success)
    }
}
