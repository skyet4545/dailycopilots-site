import Foundation

actor AIService {
    static let shared = AIService()
    private let apiURL = URL(string: "https://scripture-copilot-rust.vercel.app/api/chat")!

    func streamResponse(verse: String, verseText: String, mode: StudyMode) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let message = """
                    Study '\(verse)' using the \(mode.rawValue) method. \
                    IMPORTANT: Always include verse numbers when quoting Scripture (e.g. "16 For God so loved..."). \
                    When referencing related verses, write the full reference (e.g. Romans 8:28). \
                    Verse text: '\(verseText)'
                    """

                    var request = URLRequest(url: apiURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let body: [String: String] = [
                        "message": message,
                        "passage": verse,
                        "mode": mode.rawValue
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        continuation.finish(throwing: AIServiceError.serverError)
                        return
                    }

                    for try await line in bytes.lines {
                        guard !Task.isCancelled else {
                            continuation.finish()
                            return
                        }

                        // SSE format: lines starting with "data: "
                        guard line.hasPrefix("data: ") else { continue }
                        let data = String(line.dropFirst(6))

                        // Skip done signal
                        if data.contains("[DONE]") {
                            break
                        }

                        // Try to parse as JSON
                        if let content = parseSSEContent(data) {
                            continuation.yield(content)
                        } else if !data.isEmpty {
                            // Fallback: use raw text
                            continuation.yield(data)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func parseSSEContent(_ data: String) -> String? {
        guard let jsonData = data.data(using: .utf8) else { return nil }

        // Try format: { "content": "..." }
        if let simple = try? JSONDecoder().decode(SimpleContent.self, from: jsonData) {
            return simple.content
        }

        // Try OpenAI format: { "choices": [{ "delta": { "content": "..." } }] }
        if let openAI = try? JSONDecoder().decode(OpenAIChunk.self, from: jsonData),
           let content = openAI.choices.first?.delta.content {
            return content
        }

        return nil
    }
}

// MARK: - Response Models

private struct SimpleContent: Decodable {
    let content: String
}

private struct OpenAIChunk: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let delta: Delta
    }

    struct Delta: Decodable {
        let content: String?
    }
}

// MARK: - Errors

enum AIServiceError: LocalizedError {
    case serverError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .serverError: return "Server returned an error. Please try again."
        case .invalidResponse: return "Unable to read the response."
        }
    }
}
