import SwiftUI
import SwiftData

@MainActor
class StudyViewModel: ObservableObject {
    @Published var verseReference: String = ""
    @Published var verse: BibleVerse?
    @Published var selectedMode: StudyMode?
    @Published var aiResponse: String = ""
    @Published var isLoadingVerse = false
    @Published var isLoadingAI = false
    @Published var selectedTranslation: BibleTranslation = .kjv

    private let bibleService = BibleAPIService.shared
    private let aiService = AIService.shared

    func loadVerse(_ reference: String) async {
        verseReference = reference
        isLoadingVerse = true
        do {
            verse = try await bibleService.fetchVerse(reference, translation: selectedTranslation)
        } catch {
            print("Failed to load verse: \(error)")
        }
        isLoadingVerse = false
    }

    func selectMode(_ mode: StudyMode) {
        selectedMode = mode
        aiResponse = ""
        Task {
            await fetchAIResponse(for: mode)
        }
    }

    func fetchAIResponse(for mode: StudyMode) async {
        guard !verseReference.isEmpty else { return }
        isLoadingAI = true
        aiResponse = ""

        let question = buildPrompt(for: mode)

        do {
            for try await chunk in aiService.streamResponse(
                question: question,
                mode: mode,
                translation: selectedTranslation.displayName
            ) {
                aiResponse += chunk
            }
        } catch {
            if aiResponse.isEmpty {
                aiResponse = "Unable to load response. Please check your connection and try again."
            }
        }
        isLoadingAI = false
    }

    private func buildPrompt(for mode: StudyMode) -> String {
        let verseText = verse?.text ?? verseReference
        switch mode {
        case .observe:
            return "Observe \(verseReference): What does the text say? Analyze the key words, structure, and literary context of: \(verseText)"
        case .interpret:
            return "Interpret \(verseReference): What does it mean? Explain the meaning in its original historical and literary context: \(verseText)"
        case .theology:
            return "Theology of \(verseReference): What does this teach about God? Identify the theological truths and doctrines in: \(verseText)"
        case .apply:
            return "Apply \(verseReference): How should I respond? Give practical, life-changing application from: \(verseText)"
        case .apologetics:
            return "Apologetics for \(verseReference): How do I defend this? Address common objections and provide evidence for: \(verseText)"
        }
    }
}
