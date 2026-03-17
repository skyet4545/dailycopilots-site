import Foundation

/// A Bible verse or passage with its text and metadata.
struct BibleVerse: Identifiable, Codable {
    var id: String { "\(reference)-\(translation)" }
    let reference: String
    let text: String
    let translation: String
    let verses: [VerseFragment]?

    struct VerseFragment: Identifiable, Codable {
        var id: String { "\(bookName)-\(chapter)-\(verse)" }
        let bookName: String
        let chapter: Int
        let verse: Int
        let text: String

        enum CodingKeys: String, CodingKey {
            case bookName = "book_name"
            case chapter, verse, text
        }
    }

    enum CodingKeys: String, CodingKey {
        case reference, text, translation = "translation_id", verses
    }
}

/// Supported Bible translations from bible-api.com.
enum BibleTranslation: String, CaseIterable, Identifiable {
    case kjv = "kjv"
    case web = "web"
    case bbe = "bbe"
    case asv = "asv"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kjv: return "KJV"
        case .web: return "WEB"
        case .bbe: return "BBE"
        case .asv: return "ASV"
        }
    }

    var fullName: String {
        switch self {
        case .kjv: return "King James Version"
        case .web: return "World English Bible"
        case .bbe: return "Bible in Basic English"
        case .asv: return "American Standard Version"
        }
    }
}
