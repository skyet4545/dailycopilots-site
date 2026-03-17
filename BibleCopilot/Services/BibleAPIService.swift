import Foundation

/// Service for fetching Bible text from bible-api.com.
class BibleAPIService {
    static let shared = BibleAPIService()

    private let baseURL = "https://bible-api.com"
    private let session: URLSession
    private let cache = NSCache<NSString, CachedResponse>()

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        session = URLSession(configuration: config)
        cache.countLimit = 200
    }

    /// Fetch a verse or passage by reference (e.g., "John 3:16", "Romans 8:28-30").
    func fetchVerse(_ reference: String, translation: BibleTranslation = .kjv) async throws -> BibleVerse {
        let cacheKey = "\(reference)-\(translation.rawValue)" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached.verse
        }

        let encoded = reference.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? reference
        let urlString = "\(baseURL)/\(encoded)?translation=\(translation.rawValue)"
        guard let url = URL(string: urlString) else {
            throw BibleAPIError.invalidReference
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw BibleAPIError.fetchFailed
        }

        let verse = try JSONDecoder().decode(BibleVerse.self, from: data)
        cache.setObject(CachedResponse(verse: verse), forKey: cacheKey)
        return verse
    }

    /// Fetch an entire chapter (e.g., "John 3", "Psalm 23").
    func fetchChapter(book: String, chapter: Int, translation: BibleTranslation = .kjv) async throws -> BibleVerse {
        return try await fetchVerse("\(book) \(chapter)", translation: translation)
    }

    /// Fetch the verse of the day (uses a deterministic selection based on date).
    func fetchVerseOfTheDay(translation: BibleTranslation = .kjv) async throws -> BibleVerse {
        let verses = [
            "John 3:16", "Psalm 23:1-6", "Romans 8:28", "Philippians 4:13",
            "Proverbs 3:5-6", "Isaiah 40:31", "Jeremiah 29:11", "Matthew 11:28-30",
            "Psalm 46:10", "2 Timothy 1:7", "Romans 12:2", "Psalm 119:105",
            "Hebrews 11:1", "James 1:5", "1 Corinthians 13:4-7", "Galatians 5:22-23",
            "Ephesians 2:8-9", "Psalm 37:4", "Matthew 6:33", "Joshua 1:9",
            "Isaiah 41:10", "Psalm 91:1-2", "Romans 5:8", "2 Corinthians 5:17",
            "Colossians 3:23", "Psalm 139:14", "Micah 6:8", "1 Peter 5:7",
            "Deuteronomy 31:6", "Lamentations 3:22-23", "Psalm 27:1"
        ]

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % verses.count
        return try await fetchVerse(verses[index], translation: translation)
    }
}

enum BibleAPIError: LocalizedError {
    case invalidReference
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .invalidReference: return "Invalid verse reference."
        case .fetchFailed: return "Could not load verse. Check your connection."
        }
    }
}

private class CachedResponse {
    let verse: BibleVerse
    init(verse: BibleVerse) { self.verse = verse }
}

// MARK: - Bible Book Data (Bundled)

struct BibleBook: Identifiable {
    let id: String
    let name: String
    let chapters: Int
    let testament: Testament

    enum Testament: String {
        case old = "Old Testament"
        case new = "New Testament"
    }
}

extension BibleAPIService {
    static let books: [BibleBook] = [
        // Old Testament
        BibleBook(id: "genesis", name: "Genesis", chapters: 50, testament: .old),
        BibleBook(id: "exodus", name: "Exodus", chapters: 40, testament: .old),
        BibleBook(id: "leviticus", name: "Leviticus", chapters: 27, testament: .old),
        BibleBook(id: "numbers", name: "Numbers", chapters: 36, testament: .old),
        BibleBook(id: "deuteronomy", name: "Deuteronomy", chapters: 34, testament: .old),
        BibleBook(id: "joshua", name: "Joshua", chapters: 24, testament: .old),
        BibleBook(id: "judges", name: "Judges", chapters: 21, testament: .old),
        BibleBook(id: "ruth", name: "Ruth", chapters: 4, testament: .old),
        BibleBook(id: "1-samuel", name: "1 Samuel", chapters: 31, testament: .old),
        BibleBook(id: "2-samuel", name: "2 Samuel", chapters: 24, testament: .old),
        BibleBook(id: "1-kings", name: "1 Kings", chapters: 22, testament: .old),
        BibleBook(id: "2-kings", name: "2 Kings", chapters: 25, testament: .old),
        BibleBook(id: "1-chronicles", name: "1 Chronicles", chapters: 29, testament: .old),
        BibleBook(id: "2-chronicles", name: "2 Chronicles", chapters: 36, testament: .old),
        BibleBook(id: "ezra", name: "Ezra", chapters: 10, testament: .old),
        BibleBook(id: "nehemiah", name: "Nehemiah", chapters: 13, testament: .old),
        BibleBook(id: "esther", name: "Esther", chapters: 10, testament: .old),
        BibleBook(id: "job", name: "Job", chapters: 42, testament: .old),
        BibleBook(id: "psalms", name: "Psalms", chapters: 150, testament: .old),
        BibleBook(id: "proverbs", name: "Proverbs", chapters: 31, testament: .old),
        BibleBook(id: "ecclesiastes", name: "Ecclesiastes", chapters: 12, testament: .old),
        BibleBook(id: "song-of-solomon", name: "Song of Solomon", chapters: 8, testament: .old),
        BibleBook(id: "isaiah", name: "Isaiah", chapters: 66, testament: .old),
        BibleBook(id: "jeremiah", name: "Jeremiah", chapters: 52, testament: .old),
        BibleBook(id: "lamentations", name: "Lamentations", chapters: 5, testament: .old),
        BibleBook(id: "ezekiel", name: "Ezekiel", chapters: 48, testament: .old),
        BibleBook(id: "daniel", name: "Daniel", chapters: 12, testament: .old),
        BibleBook(id: "hosea", name: "Hosea", chapters: 14, testament: .old),
        BibleBook(id: "joel", name: "Joel", chapters: 3, testament: .old),
        BibleBook(id: "amos", name: "Amos", chapters: 9, testament: .old),
        BibleBook(id: "obadiah", name: "Obadiah", chapters: 1, testament: .old),
        BibleBook(id: "jonah", name: "Jonah", chapters: 4, testament: .old),
        BibleBook(id: "micah", name: "Micah", chapters: 7, testament: .old),
        BibleBook(id: "nahum", name: "Nahum", chapters: 3, testament: .old),
        BibleBook(id: "habakkuk", name: "Habakkuk", chapters: 3, testament: .old),
        BibleBook(id: "zephaniah", name: "Zephaniah", chapters: 3, testament: .old),
        BibleBook(id: "haggai", name: "Haggai", chapters: 2, testament: .old),
        BibleBook(id: "zechariah", name: "Zechariah", chapters: 14, testament: .old),
        BibleBook(id: "malachi", name: "Malachi", chapters: 4, testament: .old),
        // New Testament
        BibleBook(id: "matthew", name: "Matthew", chapters: 28, testament: .new),
        BibleBook(id: "mark", name: "Mark", chapters: 16, testament: .new),
        BibleBook(id: "luke", name: "Luke", chapters: 24, testament: .new),
        BibleBook(id: "john", name: "John", chapters: 21, testament: .new),
        BibleBook(id: "acts", name: "Acts", chapters: 28, testament: .new),
        BibleBook(id: "romans", name: "Romans", chapters: 16, testament: .new),
        BibleBook(id: "1-corinthians", name: "1 Corinthians", chapters: 16, testament: .new),
        BibleBook(id: "2-corinthians", name: "2 Corinthians", chapters: 13, testament: .new),
        BibleBook(id: "galatians", name: "Galatians", chapters: 6, testament: .new),
        BibleBook(id: "ephesians", name: "Ephesians", chapters: 6, testament: .new),
        BibleBook(id: "philippians", name: "Philippians", chapters: 4, testament: .new),
        BibleBook(id: "colossians", name: "Colossians", chapters: 4, testament: .new),
        BibleBook(id: "1-thessalonians", name: "1 Thessalonians", chapters: 5, testament: .new),
        BibleBook(id: "2-thessalonians", name: "2 Thessalonians", chapters: 3, testament: .new),
        BibleBook(id: "1-timothy", name: "1 Timothy", chapters: 6, testament: .new),
        BibleBook(id: "2-timothy", name: "2 Timothy", chapters: 4, testament: .new),
        BibleBook(id: "titus", name: "Titus", chapters: 3, testament: .new),
        BibleBook(id: "philemon", name: "Philemon", chapters: 1, testament: .new),
        BibleBook(id: "hebrews", name: "Hebrews", chapters: 13, testament: .new),
        BibleBook(id: "james", name: "James", chapters: 5, testament: .new),
        BibleBook(id: "1-peter", name: "1 Peter", chapters: 5, testament: .new),
        BibleBook(id: "2-peter", name: "2 Peter", chapters: 3, testament: .new),
        BibleBook(id: "1-john", name: "1 John", chapters: 5, testament: .new),
        BibleBook(id: "2-john", name: "2 John", chapters: 1, testament: .new),
        BibleBook(id: "3-john", name: "3 John", chapters: 1, testament: .new),
        BibleBook(id: "jude", name: "Jude", chapters: 1, testament: .new),
        BibleBook(id: "revelation", name: "Revelation", chapters: 22, testament: .new),
    ]

    static var oldTestamentBooks: [BibleBook] { books.filter { $0.testament == .old } }
    static var newTestamentBooks: [BibleBook] { books.filter { $0.testament == .new } }
}
