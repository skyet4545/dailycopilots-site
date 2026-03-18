import Foundation

enum CrossReferenceParser {
    private static let bookNames = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
        "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
        "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
        "Ezra", "Nehemiah", "Esther", "Job", "Psalms?", "Proverbs",
        "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah",
        "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel",
        "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
        "Zephaniah", "Haggai", "Zechariah", "Malachi",
        "Matthew", "Mark", "Luke", "John", "Acts",
        "Romans", "1 Corinthians", "2 Corinthians", "Galatians",
        "Ephesians", "Philippians", "Colossians",
        "1 Thessalonians", "2 Thessalonians",
        "1 Timothy", "2 Timothy", "Titus", "Philemon",
        "Hebrews", "James", "1 Peter", "2 Peter",
        "1 John", "2 John", "3 John", "Jude", "Revelation",
        // Abbreviations
        "Gen", "Exod?", "Lev", "Num", "Deut", "Josh", "Judg",
        "1 Sam", "2 Sam", "1 Kgs", "2 Kgs", "1 Chr", "2 Chr",
        "Neh", "Esth", "Ps", "Prov", "Eccl", "Isa", "Jer",
        "Lam", "Ezek", "Dan", "Hos", "Amos", "Obad", "Mic",
        "Nah", "Hab", "Zeph", "Hag", "Zech", "Mal",
        "Matt", "Rom", "1 Cor", "2 Cor", "Gal", "Eph",
        "Phil", "Col", "1 Thess", "2 Thess", "1 Tim", "2 Tim",
        "Heb", "Jas", "1 Pet", "2 Pet", "1 Jn", "2 Jn", "3 Jn", "Rev"
    ]

    private static var pattern: String {
        let escaped = bookNames.map { NSRegularExpression.escapedPattern(for: $0) }
        let books = escaped.joined(separator: "|")
        return "(?:\\b)(\(books))\\.?\\s+(\\d{1,3})(?::(\\d{1,3})(?:\\s*-\\s*\\d{1,3})?)?(?:\\b)"
    }

    static func extractReferences(from text: String, limit: Int = 5) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        var seen = Set<String>()
        var results: [String] = []

        for match in matches {
            guard let fullRange = Range(match.range, in: text) else { continue }
            let ref = String(text[fullRange]).trimmingCharacters(in: .whitespaces)

            if !seen.contains(ref) {
                seen.insert(ref)
                results.append(ref)
                if results.count >= limit { break }
            }
        }

        return results
    }
}
