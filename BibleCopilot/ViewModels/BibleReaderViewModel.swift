import SwiftUI

@MainActor
class BibleReaderViewModel: ObservableObject {
    @Published var selectedTestament: BibleBook.Testament? = nil
    @Published var selectedBook: BibleBook?
    @Published var selectedChapter: Int?
    @Published var chapterContent: BibleVerse?
    @Published var isLoading = false
    @Published var selectedTranslation: BibleTranslation = .kjv

    var books: [BibleBook] {
        if let testament = selectedTestament {
            return BibleAPIService.books.filter { $0.testament == testament }
        }
        return BibleAPIService.books
    }

    var oldTestamentBooks: [BibleBook] { BibleAPIService.oldTestamentBooks }
    var newTestamentBooks: [BibleBook] { BibleAPIService.newTestamentBooks }

    func loadChapter() async {
        guard let book = selectedBook, let chapter = selectedChapter else { return }
        isLoading = true
        do {
            chapterContent = try await BibleAPIService.shared.fetchChapter(
                book: book.name, chapter: chapter, translation: selectedTranslation
            )
        } catch {
            print("Failed to load chapter: \(error)")
        }
        isLoading = false
    }

    func selectBook(_ book: BibleBook) {
        selectedBook = book
        selectedChapter = nil
        chapterContent = nil
    }

    func selectChapter(_ chapter: Int) {
        selectedChapter = chapter
        Task { await loadChapter() }
    }

    func goBack() {
        if chapterContent != nil || selectedChapter != nil {
            selectedChapter = nil
            chapterContent = nil
        } else if selectedBook != nil {
            selectedBook = nil
        }
    }
}
