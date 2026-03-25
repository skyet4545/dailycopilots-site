import Foundation

@Observable
final class HomeViewModel {
    var searchText = ""
    var isSearching = false

    // Daily Verse
    var dailyVerseRef = ""
    var dailyVerseText = ""
    var dailyVerseLoading = false

    static let quickPicks = [
        "John 3:16",
        "Psalm 23",
        "Romans 8:28",
        "Philippians 4:13",
        "Proverbs 3:5-6",
        "Isaiah 40:31"
    ]

    static let topicQuestions = [
        "What does the Bible say about anxiety?",
        "What does the Bible say about forgiveness?",
        "What does the Bible say about purpose?",
        "What does the Bible say about suffering?",
        "What does the Bible say about love?",
        "What does the Bible say about faith?",
        "What does the Bible say about anger?",
        "What does the Bible say about money?"
    ]

    func searchVerse() -> String? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        HapticService.lightImpact()
        return trimmed
    }

    @MainActor
    func loadDailyVerse() async {
        dailyVerseLoading = true
        dailyVerseRef = await DailyVerseService.shared.todaysVerse
        do {
            dailyVerseText = try await BibleService.shared.fetchVerse(dailyVerseRef)
        } catch {
            dailyVerseText = "Unable to load verse."
        }
        dailyVerseLoading = false
    }

    /// Share text for the daily verse
    func shareText(for reference: String, text: String) -> String {
        "\(reference)\n\n\(text)\n\n— Studied with Bible Copilot"
    }
}
