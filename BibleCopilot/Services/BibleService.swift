import Foundation

actor BibleService {
    static let shared = BibleService()
    private let primaryURL = "https://bible-api.com"
    private let fallbackURL = "https://scripture-copilot-rust.vercel.app/api/chat"
    private var cache: [String: String] = [:]
    private let maxCacheSize = 200

    func fetchVerse(_ reference: String, translation: String = "asv") async throws -> String {
        let cacheKey = "\(reference)_\(translation)"
        if let cached = cache[cacheKey] {
            return cached
        }

        // Try primary source (bible-api.com) first
        if let text = try? await fetchFromBibleAPI(reference, translation: translation) {
            cache[cacheKey] = text
            evictCacheIfNeeded()
            return text
        }

        // Fallback: ask the AI backend to provide the verse text
        if let text = try? await fetchFromAIFallback(reference, translation: translation) {
            cache[cacheKey] = text
            evictCacheIfNeeded()
            return text
        }

        throw BibleServiceError.verseNotFound
    }

    private func evictCacheIfNeeded() {
        if cache.count > maxCacheSize {
            let keysToRemove = Array(cache.keys.prefix(cache.count / 2))
            for key in keysToRemove { cache.removeValue(forKey: key) }
        }
    }

    // MARK: - Primary: bible-api.com (free, no key)

    private func fetchFromBibleAPI(_ reference: String, translation: String) async throws -> String {
        guard let encoded = reference.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(primaryURL)/\(encoded)?translation=\(translation)") else {
            throw BibleServiceError.invalidReference
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 8 // Don't wait too long before falling back

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BibleServiceError.verseNotFound
        }

        let result = try JSONDecoder().decode(BibleAPIResponse.self, from: data)

        guard !result.verses.isEmpty else {
            throw BibleServiceError.verseNotFound
        }

        if result.verses.count == 1 {
            return result.verses[0].text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return result.verses
                .map { "\($0.verse) \($0.text.trimmingCharacters(in: .whitespacesAndNewlines))" }
                .joined(separator: " ")
        }
    }

    // MARK: - Fallback: AI backend provides verse text

    private func fetchFromAIFallback(_ reference: String, translation: String) async throws -> String {
        guard let url = URL(string: fallbackURL) else {
            throw BibleServiceError.verseNotFound
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let translationName: String
        switch translation {
        case "kjv": translationName = "King James Version"
        case "web": translationName = "World English Bible"
        case "bbe": translationName = "Bible in Basic English"
        case "asv": translationName = "American Standard Version"
        default: translationName = "King James Version"
        }

        let message = """
        Provide ONLY the exact Scripture text for \(reference) from the \(translationName). \
        Include verse numbers before each verse (e.g. "1 In the beginning..."). \
        Do NOT add any commentary, introduction, or explanation — just the verse text with numbers.
        """

        let body: [String: String] = [
            "message": message,
            "passage": reference,
            "mode": "verse_lookup"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BibleServiceError.verseNotFound
        }

        var fullText = ""

        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            let data = String(line.dropFirst(6))
            if data.contains("[DONE]") { break }

            if let jsonData = data.data(using: .utf8),
               let simple = try? JSONDecoder().decode(FallbackContent.self, from: jsonData) {
                fullText += simple.content
            }
        }

        guard !fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BibleServiceError.verseNotFound
        }

        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
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

private struct FallbackContent: Decodable {
    let content: String
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
