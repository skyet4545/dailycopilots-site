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
    var referenceVerificationNote: String?
    var isBookmarked = false

    // Conversation history for follow-up questions
    var chatHistory: [AIService.ChatMessage] = []
    var followUpText = ""
    var showFollowUp = false
    var shouldOfferDailyReminder = false
    /// Dismissible paywall after the first successful answer, for people who are not Pro.
    var shouldOfferSoftPaywall = false
    /// Daily-reminder offer waits until that soft paywall is dismissed.
    var deferDailyReminder = false

    var suggestedFollowUpQuestion: String? {
        guard let selectedMode, !aiLoading, !aiResponse.isEmpty else { return nil }

        switch selectedMode {
        case .summary:
            return "What is the main truth I should carry with me?"
        case .observe:
            return "What detail in this passage deserves a closer look?"
        case .interpret:
            return "How would the first readers have understood this?"
        case .theology:
            return "What does this reveal about God and His character?"
        case .apply:
            return "What is one faithful step I can take today?"
        case .apologetics:
            return "How could I explain this truth with grace and clarity?"
        }
    }

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
    func fetchVerse(isPro: Bool = false, onShowPaywall: @escaping () -> Void = {}) async {
        verseLoading = true
        verseError = nil
        do {
            verseText = try await BibleService.shared.fetchVerse(verse, translation: translation)
            // Auto-select mode if one was passed in
            if let mode = selectedMode {
                await selectMode(mode, isPro: isPro, onShowPaywall: onShowPaywall)
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
        referenceVerificationNote = nil
        showFollowUp = false

        HapticService.lightImpact()

        streamTask?.cancel()
        streamTask = Task {
            do {
                let stream = await AIService.shared.streamResponse(
                    verse: verse,
                    verseText: verseText,
                    mode: mode,
                    history: chatHistory
                )
                for try await chunk in stream {
                    guard !Task.isCancelled else { return }
                    aiResponse += chunk
                }
                // Add to conversation history
                chatHistory.append(AIService.ChatMessage(
                    role: "user",
                    content: "Study '\(verse)' using the \(mode.rawValue) method."
                ))
                chatHistory.append(AIService.ChatMessage(
                    role: "assistant",
                    content: aiResponse
                ))
                // Keep last 6 messages to avoid token overflow
                if chatHistory.count > 6 {
                    chatHistory = Array(chatHistory.suffix(6))
                }

                usageService.recordStudyContext(reference: verse, prompt: mode.label)
                let completedFirstQuestion = usageService.recordQuestion()
                if completedFirstQuestion {
                    offerFirstAnswerFollowUp(isPro: isPro)
                }
                StreakService.shared.recordStudy()
                ReviewService.shared.recordStudyAndPromptIfReady()
                NotificationService.shared.updateDailyReminderContext(reference: verse, mode: mode)
                let extractedReferences = CrossReferenceParser.extractReferences(from: aiResponse)
                let verification = await BibleService.shared.verifyReferences(extractedReferences, translation: translation)
                guard !Task.isCancelled else { return }
                crossReferences = verification.displayedReferences
                referenceVerificationNote = verification.note
                showFollowUp = true
                HapticService.success()
            } catch {
                if !Task.isCancelled {
                    aiError = error.localizedDescription
                }
            }
            aiLoading = false
        }
    }

    // MARK: - Follow-Up Question

    @MainActor
    func askSuggestedFollowUp(isPro: Bool, onShowPaywall: @escaping () -> Void) async {
        guard let suggestion = suggestedFollowUpQuestion else { return }
        AnalyticsService.shared.track(AnalyticsEvent.followUpSuggestionTapped, [
            "mode": selectedMode?.rawValue ?? "unknown"
        ])
        followUpText = suggestion
        await askFollowUp(isPro: isPro, onShowPaywall: onShowPaywall)
    }

    @MainActor
    func askFollowUp(isPro: Bool, onShowPaywall: @escaping () -> Void) async {
        let usageService = UsageService.shared
        guard usageService.canAsk(isPro: isPro) else {
            onShowPaywall()
            return
        }

        let question = followUpText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, let mode = selectedMode else { return }

        followUpText = ""
        aiResponse = ""
        aiLoading = true
        aiError = nil
        crossReferences = []
        referenceVerificationNote = nil

        HapticService.lightImpact()

        // Add the follow-up to history
        chatHistory.append(AIService.ChatMessage(role: "user", content: question))

        streamTask?.cancel()
        streamTask = Task {
            do {
                let stream = await AIService.shared.streamResponse(
                    verse: verse,
                    verseText: verseText,
                    mode: mode,
                    history: chatHistory
                )
                for try await chunk in stream {
                    guard !Task.isCancelled else { return }
                    aiResponse += chunk
                }
                chatHistory.append(AIService.ChatMessage(role: "assistant", content: aiResponse))
                if chatHistory.count > 6 {
                    chatHistory = Array(chatHistory.suffix(6))
                }
                usageService.recordStudyContext(reference: verse, prompt: question)
                let completedFirstQuestion = usageService.recordQuestion()
                if completedFirstQuestion {
                    offerFirstAnswerFollowUp(isPro: isPro)
                }
                ReviewService.shared.recordStudyAndPromptIfReady()
                NotificationService.shared.updateDailyReminderContext(reference: verse, mode: mode)
                let extractedReferences = CrossReferenceParser.extractReferences(from: aiResponse)
                let verification = await BibleService.shared.verifyReferences(extractedReferences, translation: translation)
                guard !Task.isCancelled else { return }
                crossReferences = verification.displayedReferences
                referenceVerificationNote = verification.note
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

        // Deduplicate — don't save same verse + translation twice
        let ref = verse
        let trans = translation
        let descriptor = FetchDescriptor<SavedPassage>(predicate: #Predicate {
            $0.reference == ref && $0.translation == trans
        })
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            isBookmarked = true
            return
        }

        let passage = SavedPassage(
            reference: verse,
            text: verseText,
            translation: translation
        )
        context.insert(passage)
        isBookmarked = true
        HapticService.success()
        ReviewService.shared.recordSavedStudyAndPromptIfReady()
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
        ReviewService.shared.recordSavedStudyAndPromptIfReady()
    }

    /// Soft paywall on the first real answer. The reminder sheet waits so the two
    /// don't stack. Pro subscribers only see the reminder.
    private func offerFirstAnswerFollowUp(isPro: Bool) {
        let decision = FirstAnswerFollowUp.decide(
            isPro: isPro,
            wantsReminder: NotificationService.shared.shouldOfferDailyReminderAfterFirstStudy()
        )
        shouldOfferSoftPaywall = decision.showSoftPaywall
        shouldOfferDailyReminder = decision.showReminder
        deferDailyReminder = decision.deferReminder
    }

    // MARK: - Cleanup

    func cancelStream() {
        streamTask?.cancel()
    }
}

/// What to present after the first successful in-app answer.
enum FirstAnswerFollowUp {
    struct Decision: Equatable {
        var showSoftPaywall: Bool
        var showReminder: Bool
        var deferReminder: Bool
    }

    static func decide(isPro: Bool, wantsReminder: Bool) -> Decision {
        if isPro {
            return Decision(showSoftPaywall: false, showReminder: wantsReminder, deferReminder: false)
        }
        return Decision(showSoftPaywall: true, showReminder: false, deferReminder: wantsReminder)
    }
}
