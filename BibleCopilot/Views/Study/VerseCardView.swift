import SwiftUI

struct VerseCardView: View {
    let reference: String
    let text: String
    let isLoading: Bool
    let isBookmarked: Bool
    let onBookmark: () -> Void

    @AppStorage("translation") private var translation: String = "kjv"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reference)
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.gold)

                Spacer()

                Text(translation.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceLight)
                    .clipShape(Capsule())

                Button(action: onBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? AppTheme.gold : AppTheme.textMuted)
                }
            }

            if isLoading {
                ProgressView()
                    .tint(AppTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else if !text.isEmpty {
                Text(formattedVerseText)
                    .font(.body)
                    .italic()
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(6)
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

    /// Renders verse numbers in bold gold superscript style
    private var formattedVerseText: AttributedString {
        var result = AttributedString()

        // Regex to match verse numbers like "1 ", "12 " at start or after space
        let pattern = #"(?:^|\s)(\d{1,3})\s"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return AttributedString(text)
        }

        let nsText = text as NSString
        var lastEnd = 0

        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        for match in matches {
            let fullRange = match.range
            let numberRange = match.range(at: 1)

            // Add text before this match
            if fullRange.location > lastEnd {
                let before = nsText.substring(with: NSRange(location: lastEnd, length: fullRange.location - lastEnd))
                var attr = AttributedString(before)
                attr.foregroundColor = AppTheme.textSecondary
                result.append(attr)
            }

            // Add the verse number in bold gold
            let number = nsText.substring(with: numberRange)
            var numAttr = AttributedString(number + " ")
            numAttr.font = .caption.bold()
            numAttr.foregroundColor = AppTheme.gold
            numAttr.baselineOffset = 4
            result.append(numAttr)

            lastEnd = fullRange.location + fullRange.length
        }

        // Add remaining text
        if lastEnd < nsText.length {
            let remaining = nsText.substring(from: lastEnd)
            var attr = AttributedString(remaining)
            attr.foregroundColor = AppTheme.textSecondary
            result.append(attr)
        }

        // If no matches found, just return plain text
        if matches.isEmpty {
            return AttributedString(text)
        }

        return result
    }
}
