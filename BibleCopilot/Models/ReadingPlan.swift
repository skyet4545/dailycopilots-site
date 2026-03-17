import Foundation
import SwiftData

/// A reading plan definition (bundled, not persisted).
struct ReadingPlanDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let days: [ReadingDay]
    let icon: String

    struct ReadingDay: Identifiable, Codable {
        let day: Int
        let reference: String
        let title: String

        var id: Int { day }
    }
}

/// User's progress through a reading plan (persisted via SwiftData).
@Model
final class ReadingPlanProgress {
    var id: UUID
    var planId: String
    var completedDays: [Int]
    var startedAt: Date
    var lastReadAt: Date

    init(planId: String) {
        self.id = UUID()
        self.planId = planId
        self.completedDays = []
        self.startedAt = Date()
        self.lastReadAt = Date()
    }

    var totalCompleted: Int { completedDays.count }

    func isCompleted(day: Int) -> Bool {
        completedDays.contains(day)
    }

    func toggleDay(_ day: Int) {
        if completedDays.contains(day) {
            completedDays.removeAll { $0 == day }
        } else {
            completedDays.append(day)
            lastReadAt = Date()
        }
    }
}

/// Bundled reading plans.
enum ReadingPlans {
    static let all: [ReadingPlanDefinition] = [
        ReadingPlanDefinition(
            id: "romans-30",
            name: "Romans in 30 Days",
            description: "Journey through Paul's greatest theological letter.",
            days: (1...16).map { chapter in
                ReadingPlanDefinition.ReadingDay(
                    day: chapter,
                    reference: "Romans \(chapter)",
                    title: "Romans \(chapter)"
                )
            },
            icon: "book.closed.fill"
        ),
        ReadingPlanDefinition(
            id: "gospel-john",
            name: "Gospel of John",
            description: "Discover the beloved disciple's account of Jesus.",
            days: (1...21).map { chapter in
                ReadingPlanDefinition.ReadingDay(
                    day: chapter,
                    reference: "John \(chapter)",
                    title: "John \(chapter)"
                )
            },
            icon: "text.book.closed.fill"
        ),
        ReadingPlanDefinition(
            id: "psalms-praise",
            name: "Psalms of Praise",
            description: "30 days of worship through the Psalms.",
            days: [
                ReadingPlanDefinition.ReadingDay(day: 1, reference: "Psalm 1", title: "The Blessed Life"),
                ReadingPlanDefinition.ReadingDay(day: 2, reference: "Psalm 8", title: "God's Majesty"),
                ReadingPlanDefinition.ReadingDay(day: 3, reference: "Psalm 19", title: "God's Glory in Creation"),
                ReadingPlanDefinition.ReadingDay(day: 4, reference: "Psalm 23", title: "The Good Shepherd"),
                ReadingPlanDefinition.ReadingDay(day: 5, reference: "Psalm 27", title: "The Lord is My Light"),
                ReadingPlanDefinition.ReadingDay(day: 6, reference: "Psalm 34", title: "Taste and See"),
                ReadingPlanDefinition.ReadingDay(day: 7, reference: "Psalm 37", title: "Trust in the Lord"),
                ReadingPlanDefinition.ReadingDay(day: 8, reference: "Psalm 42", title: "Longing for God"),
                ReadingPlanDefinition.ReadingDay(day: 9, reference: "Psalm 46", title: "God is Our Refuge"),
                ReadingPlanDefinition.ReadingDay(day: 10, reference: "Psalm 51", title: "A Prayer of Repentance"),
                ReadingPlanDefinition.ReadingDay(day: 11, reference: "Psalm 63", title: "Thirsting for God"),
                ReadingPlanDefinition.ReadingDay(day: 12, reference: "Psalm 84", title: "Dwelling with God"),
                ReadingPlanDefinition.ReadingDay(day: 13, reference: "Psalm 90", title: "The Eternal God"),
                ReadingPlanDefinition.ReadingDay(day: 14, reference: "Psalm 91", title: "Under His Wings"),
                ReadingPlanDefinition.ReadingDay(day: 15, reference: "Psalm 95", title: "Come, Let Us Worship"),
                ReadingPlanDefinition.ReadingDay(day: 16, reference: "Psalm 100", title: "Joyful Praise"),
                ReadingPlanDefinition.ReadingDay(day: 17, reference: "Psalm 103", title: "Bless the Lord"),
                ReadingPlanDefinition.ReadingDay(day: 18, reference: "Psalm 104", title: "God the Creator"),
                ReadingPlanDefinition.ReadingDay(day: 19, reference: "Psalm 107", title: "Give Thanks"),
                ReadingPlanDefinition.ReadingDay(day: 20, reference: "Psalm 111", title: "Great Are His Works"),
                ReadingPlanDefinition.ReadingDay(day: 21, reference: "Psalm 119:1-48", title: "The Word of God (Part 1)"),
                ReadingPlanDefinition.ReadingDay(day: 22, reference: "Psalm 119:49-112", title: "The Word of God (Part 2)"),
                ReadingPlanDefinition.ReadingDay(day: 23, reference: "Psalm 119:113-176", title: "The Word of God (Part 3)"),
                ReadingPlanDefinition.ReadingDay(day: 24, reference: "Psalm 121", title: "The Lord Watches Over You"),
                ReadingPlanDefinition.ReadingDay(day: 25, reference: "Psalm 136", title: "His Love Endures Forever"),
                ReadingPlanDefinition.ReadingDay(day: 26, reference: "Psalm 139", title: "Wonderfully Made"),
                ReadingPlanDefinition.ReadingDay(day: 27, reference: "Psalm 145", title: "The Greatness of God"),
                ReadingPlanDefinition.ReadingDay(day: 28, reference: "Psalm 146", title: "Praise the Lord"),
                ReadingPlanDefinition.ReadingDay(day: 29, reference: "Psalm 148", title: "Let All Creation Praise"),
                ReadingPlanDefinition.ReadingDay(day: 30, reference: "Psalm 150", title: "Let Everything Praise"),
            ],
            icon: "music.note"
        ),
    ]
}
