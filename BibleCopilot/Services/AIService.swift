import Foundation

/// AI service that streams responses from the Vercel backend via SSE.
class AIService {
    static let shared = AIService()

    private let apiURL = "https://scripture-copilot-rust.vercel.app/api/chat"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }

    /// Stream an AI response for the given question and optional study mode.
    func streamResponse(
        question: String,
        mode: StudyMode? = nil,
        translation: String = "KJV"
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: URL(string: apiURL)!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    var body: [String: Any] = ["message": question]
                    if let mode = mode {
                        body["mode"] = mode.rawValue
                    }
                    body["translation"] = translation
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw AIServiceError.invalidResponse
                    }

                    guard httpResponse.statusCode == 200 else {
                        throw AIServiceError.httpError(httpResponse.statusCode)
                    }

                    // Check if this is an SSE stream
                    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
                    let isSSE = contentType.contains("text/event-stream")

                    if isSSE {
                        // Parse SSE stream
                        var buffer = ""
                        for try await byte in bytes {
                            let char = String(UnicodeScalar(byte))
                            buffer += char

                            if buffer.hasSuffix("\n\n") || buffer.hasSuffix("\n") {
                                let lines = buffer.components(separatedBy: "\n")
                                for line in lines {
                                    if line.hasPrefix("data: ") {
                                        let data = String(line.dropFirst(6))
                                        if data == "[DONE]" {
                                            continuation.finish()
                                            return
                                        }
                                        // Try to parse as JSON chunk
                                        if let jsonData = data.data(using: .utf8),
                                           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                            if let content = json["content"] as? String {
                                                continuation.yield(content)
                                            } else if let choices = json["choices"] as? [[String: Any]],
                                                      let delta = choices.first?["delta"] as? [String: Any],
                                                      let content = delta["content"] as? String {
                                                continuation.yield(content)
                                            }
                                        } else {
                                            // Plain text SSE
                                            continuation.yield(data)
                                        }
                                    }
                                }
                                buffer = ""
                            }
                        }
                    } else {
                        // Non-SSE: accumulate full response
                        var fullResponse = Data()
                        for try await byte in bytes {
                            fullResponse.append(byte)
                        }
                        if let text = String(data: fullResponse, encoding: .utf8) {
                            // Try JSON first
                            if let json = try? JSONSerialization.jsonObject(with: fullResponse) as? [String: Any],
                               let content = json["content"] as? String {
                                continuation.yield(content)
                            } else if let json = try? JSONSerialization.jsonObject(with: fullResponse) as? [String: Any],
                                      let choices = json["choices"] as? [[String: Any]],
                                      let message = choices.first?["message"] as? [String: Any],
                                      let content = message["content"] as? String {
                                continuation.yield(content)
                            } else {
                                continuation.yield(text)
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    // Fallback to offline responses if network fails
                    let fallback = Self.offlineResponse(for: question)
                    continuation.yield(fallback)
                    continuation.finish()
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Simple non-streaming question (convenience).
    func askQuestion(_ question: String, mode: StudyMode? = nil) async -> String {
        var result = ""
        do {
            for try await chunk in streamResponse(question: question, mode: mode) {
                result += chunk
            }
        } catch {
            result = Self.offlineResponse(for: question)
        }
        return result
    }

    /// Offline fallback responses when there's no network connectivity.
    private static func offlineResponse(for question: String) -> String {
        let lowerQ = question.lowercased()

        if lowerQ.contains("john 3:16") || lowerQ.contains("john 3") {
            return "John 3:16 says: \"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.\" This verse is often called the Gospel in miniature. It reveals God's motivation (love), His action (giving His Son), the scope (the whole world), the condition (belief), and the promise (eternal life)."
        } else if lowerQ.contains("faith") {
            return "Hebrews 11:1 defines faith as \"confidence in what we hope for and assurance about what we do not see.\" Faith is not blind - it's trust based on God's character and His revealed Word. Romans 10:17 tells us that \"faith comes from hearing the message, and the message is heard through the word about Christ.\""
        } else if lowerQ.contains("prayer") || lowerQ.contains("pray") {
            return "Jesus taught us to pray in Matthew 6:9-13 with what we call the Lord's Prayer. Prayer is conversation with God - bring your requests (Philippians 4:6), confess your sins (1 John 1:9), give thanks (1 Thessalonians 5:18), and intercede for others (James 5:16). The key is approaching God with faith and humility."
        } else if lowerQ.contains("salvation") || lowerQ.contains("saved") || lowerQ.contains("save") {
            return "Ephesians 2:8-9 tells us: \"For it is by grace you have been saved, through faith - and this is not from yourselves, it is the gift of God - not by works, so that no one can boast.\" Salvation comes through repentance and faith in Jesus Christ, who died for our sins and rose again (Romans 10:9-10)."
        } else if lowerQ.contains("love") {
            return "1 Corinthians 13 is the great \"love chapter\" of the Bible. John 3:16 shows God's love for us, and 1 John 4:19 says \"We love because he first loved us.\" Jesus said the greatest commandments are to love God and love your neighbor (Matthew 22:37-39)."
        } else {
            return "That's a meaningful Bible question! Scripture has much to say on this topic. I'd encourage you to search using a concordance or Bible app for key words related to your question. Reading the surrounding context of any verse is essential for proper interpretation. Would you like to ask a more specific question so I can point you to relevant passages?"
        }
    }
}

enum AIServiceError: LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "Server error (HTTP \(code)). Please try again."
        }
    }
}
