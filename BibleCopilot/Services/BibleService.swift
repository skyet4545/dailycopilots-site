import Foundation

actor BibleService {
    static let shared = BibleService()
    private let baseURL = "https://bible-api.com"
    private var cache: [String: String] = [:]

    func fetchVerse(_ reference: String, translation: String = "kjv") async throws -> String {
        let cacheKey = "\(reference)_\(translation)"
        if let cached = cache[cacheKey] {
            return cached
        }

        guard let encoded = reference.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/\(encoded)?translation=\(translation)") else {
            throw BibleServiceError.invalidReference
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BibleServiceError.verseNotFound
        }

        let result = try JSONDecoder().decode(BibleAPIResponse.self, from: data)

        let verseText = result.verses
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")

        cache[cacheKey] = verseText
        return verseText
    }
}

// MARK: - Response Models

private struct BibleAPIResponse: Decodable {
    let verses: [Verse]

    struct Verse: Decodable {
        let verse: Int
        let text: String
    }
}

// MARK: - Errors

enum BibleServiceError: LocalizedError {
    case invalidReference
    case verseNotFound

    var errorDescription: String? {
        switch self {
        case .invalidReference: return "Invalid verse reference."
        case .verseNotFound: return "Verse not found. Please check the reference."
        }
    }
}
