import Foundation

struct ReadingPlan: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let dayCount: Int
    let verses: [String]

    static let allPlans: [ReadingPlan] = [
        ReadingPlan(
            id: "gospel-of-john",
            title: "Gospel of John",
            description: "Walk through the entire Gospel of John in 21 days",
            icon: "book.fill",
            dayCount: 21,
            verses: [
                "John 1:1-18", "John 1:19-51", "John 2", "John 3:1-21",
                "John 3:22-36", "John 4:1-26", "John 4:27-54", "John 5:1-24",
                "John 5:25-47", "John 6:1-29", "John 6:30-71", "John 7:1-24",
                "John 7:25-52", "John 8:1-30", "John 8:31-59", "John 9",
                "John 10:1-21", "John 10:22-42", "John 11:1-44", "John 11:45-57",
                "John 12"
            ]
        ),
        ReadingPlan(
            id: "30-days-of-psalms",
            title: "30 Days of Psalms",
            description: "A month of comfort, praise, and wisdom from the Psalms",
            icon: "music.note",
            dayCount: 30,
            verses: [
                "Psalm 1", "Psalm 8", "Psalm 16", "Psalm 19", "Psalm 23",
                "Psalm 24", "Psalm 27", "Psalm 30", "Psalm 32", "Psalm 34",
                "Psalm 37:1-11", "Psalm 40", "Psalm 42", "Psalm 46", "Psalm 51",
                "Psalm 63", "Psalm 84", "Psalm 86", "Psalm 90", "Psalm 91",
                "Psalm 100", "Psalm 103", "Psalm 107:1-16", "Psalm 116", "Psalm 119:1-16",
                "Psalm 121", "Psalm 136:1-9", "Psalm 139", "Psalm 145", "Psalm 150"
            ]
        ),
        ReadingPlan(
            id: "romans-deep-dive",
            title: "Romans Deep Dive",
            description: "Study the theology of Paul's letter to the Romans",
            icon: "text.book.closed.fill",
            dayCount: 16,
            verses: [
                "Romans 1:1-17", "Romans 1:18-32", "Romans 2:1-16", "Romans 2:17-3:8",
                "Romans 3:9-31", "Romans 4", "Romans 5:1-11", "Romans 5:12-21",
                "Romans 6:1-14", "Romans 6:15-7:6", "Romans 7:7-25", "Romans 8:1-17",
                "Romans 8:18-39", "Romans 9:1-29", "Romans 10", "Romans 11:1-36"
            ]
        ),
        ReadingPlan(
            id: "proverbs-31",
            title: "Proverbs 31",
            description: "One chapter of Proverbs each day for a full month",
            icon: "lightbulb.fill",
            dayCount: 31,
            verses: (1...31).map { "Proverbs \($0)" }
        ),
        ReadingPlan(
            id: "sermon-on-the-mount",
            title: "Sermon on the Mount",
            description: "Jesus' most famous teaching in 7 focused days",
            icon: "mountain.2.fill",
            dayCount: 7,
            verses: [
                "Matthew 5:1-16", "Matthew 5:17-32", "Matthew 5:33-48",
                "Matthew 6:1-18", "Matthew 6:19-34", "Matthew 7:1-14",
                "Matthew 7:15-29"
            ]
        )
    ]
}
