import SwiftUI
import SwiftData

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entry: JournalEntry?

    @State private var verseReference: String = ""
    @State private var title: String = ""
    @State private var content: String = ""

    var isEditing: Bool { entry != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // Verse Reference
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text("Verse Reference")
                        .font(AppTheme.labelFont)
                        .foregroundColor(AppTheme.textMuted)

                    TextField("e.g., John 3:16", text: $verseReference)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(AppTheme.spacingMD)
                        .background(AppTheme.surfaceLight)
                        .cornerRadius(AppTheme.cornerRadiusSM)
                }

                // Title
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text("Title")
                        .font(AppTheme.labelFont)
                        .foregroundColor(AppTheme.textMuted)

                    TextField("Entry title...", text: $title)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(AppTheme.spacingMD)
                        .background(AppTheme.surfaceLight)
                        .cornerRadius(AppTheme.cornerRadiusSM)
                }

                // Content
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text("Reflections")
                        .font(AppTheme.labelFont)
                        .foregroundColor(AppTheme.textMuted)

                    TextEditor(text: $content)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .padding(AppTheme.spacingMD)
                        .background(AppTheme.surfaceLight)
                        .cornerRadius(AppTheme.cornerRadiusSM)
                }
            }
            .padding(AppTheme.spacingLG)
        }
        .background(AppTheme.background)
        .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    save()
                    dismiss()
                }
                .foregroundColor(AppTheme.accent)
                .disabled(verseReference.isEmpty || title.isEmpty)
            }
        }
        .onAppear {
            if let entry = entry {
                verseReference = entry.verseReference
                title = entry.title
                content = entry.content
            }
        }
    }

    private func save() {
        if let entry = entry {
            entry.verseReference = verseReference
            entry.title = title
            entry.content = content
            entry.updatedAt = Date()
        } else {
            let newEntry = JournalEntry(
                verseReference: verseReference,
                title: title,
                content: content
            )
            modelContext.insert(newEntry)
        }
    }
}
