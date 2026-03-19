import Foundation

enum CrossReferenceParser {
    // All 66 books of the Bible (ordered longest first to avoid partial matches)
    private static let bookNames = [
        "1 Thessalonians", "2 Thessalonians", "1 Corinthians", "2 Corinthians",
        "1 Chronicles", "2 Chronicles", "Song of Solomon", "1 Samuel", "2 Samuel",
        "1 Timothy", "2 Timothy", "1 Kings", "2 Kings", "1 Peter", "2 Peter",
        "1 John", "2 John", "3 John", "Deuteronomy", "Ecclesiastes", "Lamentations",
        "Philippians", "Colossians", "Revelation", "Zephaniah", "Zechariah",
        "Nehemiah", "Habakkuk", "Leviticus", "Proverbs", "Ephesians", "Galatians",
        "Malachi", "Matthew", "Genesis", "Exodus", "Numbers", "Joshua", "Judges",
        "Ezekiel", "Daniel", "Hebrews", "Obadiah", "Haggai", "Romans", "Psalms",
        "Psalm", "Isaiah", "Esther", "Micah", "Nahum", "James", "Hosea", "Jonah",
        "Titus", "Amos", "Joel", "Ruth", "Ezra", "Luke", "Mark", "John", "Acts",
        "Jude", "Job", "Phil", "Col", "Rom", "Gen", "Exo", "Rev", "Heb", "Isa",
        "Jer", "Eze", "Dan", "Mat", "Gal", "Eph", "Tim"
    ]

    private static let pattern: String = {
        let escaped = bookNames.map { NSRegularExpression.escapedPattern(for: $0) }
        let booksPattern = escaped.joined(separator: "|")
        return "(?:\(booksPattern))\\s+\\d+(?::\\d+(?:\\s*[-–]\\s*\\d+)?)?"
    }()

    private static let regex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    /// Extract unique Bible references from text, up to `limit` results
    static func extractReferences(from text: String, limit: Int = 5) -> [String] {
        guard let regex = regex else { return [] }

        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))

        var seen = Set<String>()
        var references: [String] = []

        for match in results {
            let ref = nsString.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)

            if !seen.contains(ref.lowercased()) {
                seen.insert(ref.lowercased())
                references.append(ref)
            }

            if references.count >= limit { break }
        }

        return references
    }
}
