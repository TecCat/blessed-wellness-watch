import Foundation
import SwiftData

@Model
final class SessionRecord {
    var patternID: String        // e.g. "box", "4-7-8"
    var patternName: String      // e.g. "Box Breathing"
    var startedAt: Date
    var elapsedSeconds: Double
    var completedCycles: Int
    var totalCycles: Int
    var wasCompleted: Bool       // true = natural finish, false = stopped early
    var paceLabel: String        // "慢速" / "標準" / "快速"

    init(patternID: String, patternName: String, startedAt: Date,
         elapsedSeconds: Double, completedCycles: Int, totalCycles: Int,
         wasCompleted: Bool, paceLabel: String) {
        self.patternID = patternID
        self.patternName = patternName
        self.startedAt = startedAt
        self.elapsedSeconds = elapsedSeconds
        self.completedCycles = completedCycles
        self.totalCycles = totalCycles
        self.wasCompleted = wasCompleted
        self.paceLabel = paceLabel
    }
}
