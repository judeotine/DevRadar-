import SwiftUI

struct CommitTimelineRow: View {
    @Environment(\.theme) private var theme

    let commit: Commit

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            AvatarView(
                url: commit.author.user?.avatarUrl,
                size: 32,
                fallbackInitials: String(commit.author.name.prefix(2)).uppercased()
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(commit.shortMessage)
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .lineLimit(2)

                HStack(spacing: Spacing.sm) {
                    if let login = commit.author.user?.login {
                        Text(login)
                            .font(Typography.caption())
                            .foregroundStyle(theme.primary)
                    } else {
                        Text(commit.author.name)
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                    }

                    Text("•")
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)

                    Text(commit.committedDate, style: .relative)
                        .font(Typography.caption())
                        .foregroundStyle(theme.tertiaryText)

                    if commit.changeCount > 0 {
                        Text("•")
                            .font(Typography.caption())
                            .foregroundStyle(theme.tertiaryText)

                        HStack(spacing: Spacing.xs) {
                            if commit.additions > 0 {
                                Text("+\(commit.additions)")
                                    .font(Typography.caption())
                                    .foregroundStyle(theme.success)
                            }

                            if commit.deletions > 0 {
                                Text("-\(commit.deletions)")
                                    .font(Typography.caption())
                                    .foregroundStyle(theme.error)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

