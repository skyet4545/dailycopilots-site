import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var verseOfTheDay: BibleVerse?
    @Published var isLoadingVerse = false
    @Published var searchText = ""
    @Published var selectedTranslation: BibleTranslation = .kjv

    let quickPicks = ["John 3:16", "Psalm 23", "Romans 8:28", "Philippians 4:13"]

    private let bibleService = BibleAPIService.shared

    func loadVerseOfTheDay() async {
        guard verseOfTheDay == nil else { return }
        isLoadingVerse = true
        do {
            verseOfTheDay = try await bibleService.fetchVerseOfTheDay(translation: selectedTranslation)
        } catch {
            print("Failed to load verse of the day: \(error)")
        }
        isLoadingVerse = false
    }
}
