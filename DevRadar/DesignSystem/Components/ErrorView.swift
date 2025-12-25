import SwiftUI

struct ErrorView: View {
    @Environment(\.theme) private var theme

    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(theme.error)

            VStack(spacing: Spacing.sm) {
                Text("Something went wrong")
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)

                Text(error.localizedDescription)
                    .font(Typography.body())
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: retry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(Typography.body())
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
        .background(theme.background)
    }
}
