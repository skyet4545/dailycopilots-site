import SwiftUI

struct AIResponseView: View {
    let response: String
    let isLoading: Bool
    let error: String?
    let onSaveToJournal: () -> Void
    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(AppTheme.accent)
                Text("AI Study Response")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if !response.isEmpty && !isLoading {
                    // Copy button
                    Button {
                        UIPasteboard.general.string = response
                        showCopied = true
                        HapticService.success()
                        Task {
                            try? await Task.sleep(for: .seconds(1.5))
                            showCopied = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                            Text(showCopied ? "Copied!" : "Copy")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundColor(showCopied ? AppTheme.success : AppTheme.textMuted)
                    }

                    // Save button
                    Button(action: onSaveToJournal) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppTheme.accent)
                    }
                }
            }

            if let error {
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.error)
            } else if response.isEmpty && isLoading {
                HStack(spacing: 12) {
                    LoadingDotsView()
                    Text("Studying...")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.vertical, 8)
            } else {
                Text(response)
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .textSelection(.enabled)

                if isLoading {
                    LoadingDotsView()
                        .padding(.top, 4)
                }

                // AI disclaimer
                if !response.isEmpty && !isLoading {
                    Text("AI-generated study aid. Always verify with Scripture and pastoral guidance.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted.opacity(0.7))
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
    }
}
