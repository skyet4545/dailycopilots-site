import Foundation
import SwiftData

@Model
final class ReadingPlanProgress {
    var id: UUID
    var planId: String
    var completedDays: [Int]
    var startedAt: Date
    var lastReadAt: Date?

    init(
        id: UUID = UUID(),
        planId: String,
        completedDays: [Int] = [],
        startedAt: Date = .now,
        lastReadAt: Date? = nil
    ) {
        self.id = id
        self.planId = planId
        self.completedDays = completedDays
        self.startedAt = startedAt
        self.lastReadAt = lastReadAt
    }

    var completedCount: Int { completedDays.count }

    func isCompleted(day: Int) -> Bool {
        completedDays.contains(day)
    }
}
