import Foundation
import SwiftUI
import SwiftData

@Observable
final class StudyViewModel {
    var verse: String
    var verseText = ""
    var verseLoading = false
    var verseError: String?

    var selectedMode: StudyMode?
    var aiResponse = ""
    var aiLoading = false
    var aiError: String?

    var crossReferences: [String] = []
    var isBookmarked = false

    @ObservationIgnored
    @AppStorage("translation") private var translation: String = "asv"

    @ObservationIgnored
    private var streamTask: Task<Void, Never>?

    init(verse: String, initialMode: StudyMode? = nil) {
        self.verse = verse
        self.selectedMode = initialMode
    }

    // MARK: - Verse Fetching

    @MainActor
    func fetchVerse() async {
        verseLoading = true
        verseError = nil
        do {
            verseText = try await BibleService.shared.fetchVerse(verse, translation: translation)
            // Auto-select mode if one was passed in
            if let mode = selectedMode {
                await selectMode(mode, isPro: false, onShowPaywall: {})
            }
        } catch {
            verseError = error.localizedDescription
        }
        verseLoading = false
    }

    // MARK: - Mode Selection & AI Streaming

    @MainActor
    func selectMode(_ mode: StudyMode, isPro: Bool, onShowPaywall: @escaping () -> Void) async {
        let usageService = UsageService.shared

        // CRITICAL: Show paywall, NEVER error
        guard usageService.canAsk(isPro: isPro) else {
            onShowPaywall()
            return
        }

        selectedMode = mode
        aiResponse = ""
        aiLoading = true
        aiError = nil
        crossReferences = []

        HapticService.lightImpact()

        streamTask?.cancel()
        streamTask = Task {
            do {
                let stream = await AIService.shared.streamResponse(
                    verse: verse,
                    verseText: verseText,
                    mode: mode
                )
                for try await chunk in stream {
                    guard !Task.isCancelled else { return }
                    aiResponse += chunk
                }
                // Extract cross-references after streaming completes
                crossReferences = CrossReferenceParser.extractReferences(from: aiResponse)
                usageService.recordQuestion()
                StreakService.shared.recordStudy()
                ReviewService.shared.recordStudyAndPromptIfReady()
                HapticService.success()
            } catch {
                if !Task.isCancelled {
                    aiError = error.localizedDescription
                }
            }
            aiLoading = false
        }
    }

    // MARK: - Save Actions

    func savePassage(context: ModelContext) {
        guard !verseText.isEmpty else { return }

        let passage = SavedPassage(
            reference: verse,
            text: verseText,
            translation: translation
        )
        context.insert(passage)
        isBookmarked = true
        HapticService.success()
    }

    func saveToJournal(context: ModelContext) {
        guard !aiResponse.isEmpty, let mode = selectedMode else { return }

        let entry = JournalEntry(
            reference: verse,
            mode: mode.rawValue,
            response: aiResponse
        )
        context.insert(entry)
        HapticService.success()
    }

    // MARK: - Cleanup

    func cancelStream() {
        streamTask?.cancel()
    }
}
