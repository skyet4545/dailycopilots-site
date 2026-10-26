import SwiftUI

struct AIResponseView: View {
    let response: String
    let isLoading: Bool
    let error: String?
    let onSaveToJournal: () -> Void
    var onShareExplanation: (() -> Void)? = nil
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

                    if let onShareExplanation {
                        Button(action: onShareExplanation) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share this explanation")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        .accessibilityLabel("Share this explanation")
                    }
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

/// Verse + short answer + App Store link for the system share sheet.
enum ExplanationShare {
    static let appStoreID = "6758913373"
    static let campaign = "app_share"
    /// App Store Connect provider token (`pt`).
    static let providerToken = "128532000"

    /// Canonical share link, including `mt=8` (iPhone).
    static let appStoreURLString = "https://apps.apple.com/app/apple-store/id\(appStoreID)?pt=\(providerToken)&ct=\(campaign)&mt=8"

    static func message(reference: String, answer: String) -> String {
        let excerpt = excerpt(from: answer)
        return """
        \(reference)

        \(excerpt)

        Studied with Bible Copilot — a Scripture study aid
        \(appStoreURLString)
        """
    }

    /// First ~280 characters, broken on a word when that still leaves a useful excerpt.
    static func excerpt(from answer: String, limit: Int = 280) -> String {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > limit else { return trimmed }
        let slice = trimmed.prefix(limit)
        if let lastSpace = slice.lastIndex(of: " "),
           slice.distance(from: slice.startIndex, to: lastSpace) > limit / 2 {
            return String(slice[..<lastSpace]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
        }
        return String(slice).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}
