import Foundation

@Observable
final class HomeViewModel {
    var searchText = ""
    var isSearching = false

    static let quickPicks = [
        "John 3:16",
        "Psalm 23",
        "Romans 8:28",
        "Philippians 4:13"
    ]

    func searchVerse() -> String? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        HapticService.lightImpact()
        return trimmed
    }
}
