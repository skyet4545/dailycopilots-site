import Foundation

actor DailyVerseService {
    static let shared = DailyVerseService()

    private let verses = [
        "John 3:16", "Psalm 23:1", "Romans 8:28", "Philippians 4:13", "Proverbs 3:5-6",
        "Isaiah 40:31", "Jeremiah 29:11", "Matthew 11:28", "2 Timothy 1:7", "Psalm 46:10",
        "Romans 12:2", "Galatians 5:22-23", "Ephesians 2:8-9", "Hebrews 11:1", "James 1:5",
        "1 John 4:8", "Psalm 119:105", "Proverbs 16:3", "Isaiah 41:10", "Matthew 6:33",
        "John 14:6", "Romans 5:8", "2 Corinthians 5:17", "Ephesians 6:10", "Philippians 4:6-7",
        "Colossians 3:23", "1 Thessalonians 5:16-18", "Hebrews 12:2", "1 Peter 5:7", "Revelation 21:4",
        "Genesis 1:1", "Exodus 14:14", "Deuteronomy 31:6", "Joshua 1:9", "Psalm 27:1",
        "Psalm 37:4", "Psalm 91:1-2", "Psalm 139:14", "Proverbs 18:10", "Isaiah 53:5",
        "Lamentations 3:22-23", "Micah 6:8", "Habakkuk 3:19", "Zephaniah 3:17", "Matthew 5:16",
        "Matthew 28:19-20", "Luke 6:31", "John 10:10", "John 15:5", "Acts 1:8",
        "Romans 6:23", "1 Corinthians 10:13", "1 Corinthians 13:4-7", "2 Corinthians 12:9", "Galatians 2:20",
        "Ephesians 3:20", "Philippians 1:6", "Colossians 3:2", "2 Timothy 3:16-17", "Hebrews 4:12",
        "James 4:7", "1 Peter 2:9", "1 John 1:9", "Psalm 34:8", "Proverbs 22:6"
    ]

    /// Returns a consistent verse for today based on the day of the year
    var todaysVerse: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        return verses[(dayOfYear - 1) % verses.count]
    }

    /// Check if the daily verse has changed since last fetch
    func hasNewVerse() -> Bool {
        let lastVerse = UserDefaults.standard.string(forKey: "lastDailyVerse") ?? ""
        let current = todaysVerse
        if lastVerse != current {
            UserDefaults.standard.set(current, forKey: "lastDailyVerse")
            return true
        }
        return false
    }
}
