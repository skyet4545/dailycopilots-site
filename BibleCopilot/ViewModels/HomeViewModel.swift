import SwiftUI
import Observation

@MainActor
@Observable
class HomeViewModel {
    var verseOfTheDay: BibleVerse?
    var isLoadingVerse = false
    var searchText = ""
    var selectedTranslation: BibleTranslation = .kjv

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
