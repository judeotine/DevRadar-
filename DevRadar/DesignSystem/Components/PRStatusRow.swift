import SwiftUI

struct PRStatusRow: View {
    @Environment(\.theme) private var theme

    let pullRequest: PullRequest

    var body: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(Color(hex: pullRequest.statusColor))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(pullRequest.title)
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .lineLimit(2)
                    .responsiveText()

                HStack(spacing: Spacing.sm) {
                    Text(pullRequest.repository.nameWithOwner)
                        .font(Typography.caption())
                        .foregroundStyle(theme.secondaryText)
                        .responsiveText()

                    Text("#\(pullRequest.number)")
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)
                        .responsiveText()

                    Spacer()

                    Text(pullRequest.updatedAt, style: .relative)
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text(pullRequest.statusText)
                    .font(Typography.caption())
                    .foregroundStyle(Color(hex: pullRequest.statusColor))

                if pullRequest.reviewerCount > 0 {
                    Label("\(pullRequest.reviewerCount)", systemImage: "person.2.fill")
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)
                }
            }
        }
        .padding(Spacing.md)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}
