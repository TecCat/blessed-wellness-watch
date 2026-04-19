// AppLogger.swift — Structured OSLog logger for WellnessWatch
//
// Usage examples:
//   AppLogger.session("Started 4-7-8 session")
//   AppLogger.healthKit("HRV fetch returned \(hrv) ms")
//   AppLogger.nav("Navigating to ResultView")
//   AppLogger.ui("HomeView appeared")
//   AppLogger.error("Timer failed to fire", category: "session")

import OSLog

enum AppLogger {

    // MARK: - Subsystem

    private static let subsystem = "com.teccat.wellness"

    // MARK: - Loggers per category

    private static let sessionLogger     = Logger(subsystem: subsystem, category: "session")
    private static let healthKitLogger   = Logger(subsystem: subsystem, category: "healthkit")
    private static let navLogger         = Logger(subsystem: subsystem, category: "navigation")
    private static let uiLogger          = Logger(subsystem: subsystem, category: "ui")

    // MARK: - Public interface

    /// Log a breathing session event (BreathingSession, BreathingView)
    public static func session(_ message: String) {
        sessionLogger.log("\(message, privacy: .public)")
    }

    /// Log a HealthKit event (HealthKitService)
    public static func healthKit(_ message: String) {
        healthKitLogger.log("\(message, privacy: .public)")
    }

    /// Log a navigation event (NavigationStack pushes/pops)
    public static func nav(_ message: String) {
        navLogger.log("\(message, privacy: .public)")
    }

    /// Log a UI lifecycle event (onAppear, onDisappear, user taps)
    public static func ui(_ message: String) {
        uiLogger.log("\(message, privacy: .public)")
    }

    /// Log an error with an explicit category string
    public static func error(_ message: String, category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.error("\(message, privacy: .public)")
    }
}
