import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textMuted.opacity(0.5))

            Text(title)
                .font(.title3.bold())
                .foregroundColor(AppTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding(40)
    }
}
