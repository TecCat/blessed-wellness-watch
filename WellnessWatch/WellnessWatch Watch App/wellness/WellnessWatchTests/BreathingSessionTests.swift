// BreathingSessionTests.swift — XCTest unit tests for WellnessWatch
// Module: wellness_Watch_App  (spaces → underscores)

import XCTest
@testable import wellness_Watch_App

// MARK: - BreathingPatternTests

final class BreathingPatternTests: XCTestCase {

    // MARK: Cycle duration

    func test_cycleDuration_478() {
        // 4 + 7 + 8 = 19 s
        XCTAssertEqual(BreathingPattern.breathing478.cycleDuration, 19)
    }

    func test_cycleDuration_box() {
        // 4 + 4 + 4 + 4 = 16 s
        XCTAssertEqual(BreathingPattern.box.cycleDuration, 16)
    }

    func test_cycleDuration_diaphragmatic() {
        // 5 + 5 = 10 s
        XCTAssertEqual(BreathingPattern.diaphragmatic.cycleDuration, 10)
    }

    func test_cycleDuration_physiologicalSigh() {
        // 2 + 1 + 7 = 10 s
        XCTAssertEqual(BreathingPattern.physiologicalSigh.cycleDuration, 10)
    }

    // MARK: Total cycles

    func test_totalCycles_478() {
        // 4 min = 240 s / 19 s = 12 (floor)
        XCTAssertEqual(BreathingPattern.breathing478.totalCycles, 12)
    }

    func test_totalCycles_box() {
        // 5 min = 300 s / 16 s = 18 (floor)
        XCTAssertEqual(BreathingPattern.box.totalCycles, 18)
    }

    // MARK: Static collection

    func test_allPatterns_count() {
        XCTAssertEqual(BreathingPattern.all.count, 5)
    }

    func test_allPatterns_haveUniqueIDs() {
        let ids = BreathingPattern.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate pattern IDs found: \(ids)")
    }

    // MARK: Display helpers

    func test_accentColor_notDefault() {
        // Every pattern should have a deliberate accent — none should fall through to .white
        for pattern in BreathingPattern.all {
            let color = pattern.accentColor
            // .white has RGB components (1,1,1) — verify at least one channel < 0.95
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
#if canImport(UIKit)
            UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
#endif
            // If UIKit is unavailable the assertion is skipped; on simulator it runs.
            if r != 0 || g != 0 || b != 0 {
                XCTAssertFalse(r > 0.95 && g > 0.95 && b > 0.95,
                               "Pattern '\(pattern.id)' uses near-white accent color")
            }
        }
    }

    func test_animationStyle_box() {
        XCTAssertEqual(BreathingPattern.box.animationStyle, .box)
    }

    func test_animationStyle_others() {
        let others = BreathingPattern.all.filter { $0.id != "box" }
        for pattern in others {
            XCTAssertEqual(pattern.animationStyle, .circle,
                           "Expected .circle for pattern '\(pattern.id)'")
        }
    }
}

// MARK: - BreathingSessionTests

final class BreathingSessionTests: XCTestCase {

    var sut: BreathingSession!

    override func setUp() {
        super.setUp()
        sut = BreathingSession()
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        super.tearDown()
    }

    // MARK: Initial state

    func test_initialState() {
        XCTAssertFalse(sut.isRunning)
        XCTAssertFalse(sut.isCompleted)
        XCTAssertEqual(sut.completedCycles, 0)
    }

    // MARK: start()

    func test_startSetsIsRunning() {
        sut.start(pattern: .box)
        XCTAssertTrue(sut.isRunning)
    }

    // MARK: stop()

    func test_stopCancelsTimer() {
        sut.start(pattern: .box)
        sut.stop()
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: timeRemainingText

    func test_timeRemainingText_format() {
        // Box pattern = 5 min → initial display "5:00"
        sut.start(pattern: .box)
        XCTAssertEqual(sut.timeRemainingText, "5:00")
    }

    // MARK: progress

    func test_progressStartsAtZero() {
        sut.start(pattern: .box)
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.001)
    }
}

// MARK: - StressLevelTests

final class StressLevelTests: XCTestCase {

    func test_relaxedEmoji() {
        XCTAssertEqual(StressLevel.relaxed.emoji, "😌")
    }

    func test_highColor_isRed() {
        // StressLevel.high uses Color(red: 1.0, green: 0.27, blue: 0.27)
        let color = StressLevel.high.color
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
#if canImport(UIKit)
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertGreaterThan(r, 0.9, "Expected high-stress color to be red-dominant")
#else
        // On macOS / non-UIKit builds we verify the label as a proxy
        XCTAssertEqual(StressLevel.high.label, "高度緊張")
#endif
    }

    func test_measuringLabel() {
        XCTAssertEqual(StressLevel.measuring.label, "測量中...")
    }
}
