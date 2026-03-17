import SwiftUI

struct BibleReaderView: View {
    @StateObject private var viewModel = BibleReaderViewModel()
    @State private var navigateToStudy = false
    @State private var selectedVerseRef = ""

    var body: some View {
        NavigationStack {
            Group {
                if let book = viewModel.selectedBook {
                    if let chapter = viewModel.selectedChapter {
                        chapterContentView(book: book, chapter: chapter)
                    } else {
                        chapterListView(book: book)
                    }
                } else {
                    bookListView
                }
            }
            .background(AppTheme.background)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.selectedBook != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: viewModel.goBack) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(BibleTranslation.allCases) { translation in
                            Button(translation.displayName) {
                                viewModel.selectedTranslation = translation
                                if viewModel.selectedChapter != nil {
                                    Task { await viewModel.loadChapter() }
                                }
                            }
                        }
                    } label: {
                        Text(viewModel.selectedTranslation.displayName)
                            .font(AppTheme.labelFont)
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToStudy) {
                StudyView(initialReference: selectedVerseRef, initialMode: nil)
            }
        }
    }

    private var navigationTitle: String {
        if let book = viewModel.selectedBook {
            if let chapter = viewModel.selectedChapter {
                return "\(book.name) \(chapter)"
            }
            return book.name
        }
        return "Bible"
    }

    // MARK: - Book List

    private var bookListView: some View {
        List {
            Section {
                ForEach(viewModel.oldTestamentBooks) { book in
                    bookRow(book)
                }
            } header: {
                Text("Old Testament")
                    .font(AppTheme.labelFont)
                    .foregroundColor(AppTheme.gold)
            }

            Section {
                ForEach(viewModel.newTestamentBooks) { book in
                    bookRow(book)
                }
            } header: {
                Text("New Testament")
                    .font(AppTheme.labelFont)
                    .foregroundColor(AppTheme.gold)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func bookRow(_ book: BibleBook) -> some View {
        Button {
            viewModel.selectBook(book)
        } label: {
            HStack {
                Text(book.name)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(book.chapters) ch")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textMuted)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .listRowBackground(AppTheme.background)
    }

    // MARK: - Chapter List

    private func chapterListView(book: BibleBook) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingMD), count: 5), spacing: AppTheme.spacingMD) {
                ForEach(1...book.chapters, id: \.self) { chapter in
                    Button {
                        viewModel.selectChapter(chapter)
                    } label: {
                        Text("\(chapter)")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.surface)
                            .cornerRadius(AppTheme.cornerRadiusSM)
                    }
                }
            }
            .padding(AppTheme.spacingLG)
        }
    }

    // MARK: - Chapter Content

    private func chapterContentView(book: BibleBook, chapter: Int) -> some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.accent)
                    .padding(AppTheme.spacing3XL)
            } else if let content = viewModel.chapterContent {
                VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                    if let verses = content.verses {
                        ForEach(verses) { verse in
                            Button {
                                selectedVerseRef = "\(book.name) \(chapter):\(verse.verse)"
                                navigateToStudy = true
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("\(verse.verse)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 24, alignment: .trailing)

                                    Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                                        .font(AppTheme.scriptureFont)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineSpacing(8)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    } else {
                        Text(content.text)
                            .font(AppTheme.scriptureFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(8)
                    }
                }
                .padding(AppTheme.spacingLG)
            }
        }
    }
}
