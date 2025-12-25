import SwiftUI

struct RepositoryCard: View {
    @Environment(\.theme) private var theme

    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(Color(hex: repository.languageColor))
                    .frame(width: 10, height: 10)

                Text(repository.displayLanguage)
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()

                Spacer()

                if repository.isPrivate {
                    Label("Private", systemImage: "lock.fill")
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(repository.name)
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .responsiveText()

                if let description = repository.description {
                    Text(description)
                        .font(Typography.caption())
                        .foregroundStyle(theme.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .responsiveText()
                }
            }

            HStack(spacing: Spacing.lg) {
                Label(repository.formattedStars, systemImage: "star.fill")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()

                Label(repository.formattedForks, systemImage: "tuningfork")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()

                Spacer()

                Text(repository.updatedAt, style: .relative)
                    .font(Typography.caption())
                    .foregroundStyle(theme.tertiaryText)
                    .responsiveText()
            }
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}
