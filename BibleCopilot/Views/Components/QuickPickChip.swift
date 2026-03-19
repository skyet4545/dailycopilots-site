import SwiftUI

struct QuickPickChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticService.lightImpact()
            action()
        }) {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppTheme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.accent.opacity(0.12))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
