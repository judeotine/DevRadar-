import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct RepositoryDetailView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: RepositoryDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                RepositoryDetailSkeleton()

            case .loaded(let repository):
                LoadedRepositoryContent(
                    repository: repository,
                    onRefresh: {
                        Task { await viewModel.refresh() }
                    }
                )

            case .error(let error):
                ErrorView(error: error) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle("Repository")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}

private struct LoadedRepositoryContent: View {
    @Environment(\.theme) private var theme

    let repository: Repository
    let onRefresh: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                RepositoryHeader(repository: repository)

                QuickStatsBar(repository: repository)

                if let languages = repository.languages, !languages.percentages.isEmpty {
                    LanguageBreakdownChart(languages: languages.percentages)
                        .padding(Spacing.lg)
                        .background(theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.large)
                                .stroke(theme.border, lineWidth: 0.5)
                        )
                }

                if let commits = repository.defaultBranchRef?.target.history.nodes, !commits.isEmpty {
                    CommitTimelineSection(commits: commits)
                }

                if let branches = repository.refs?.nodes, !branches.isEmpty {
                    BranchesSection(branches: branches)
                }

                if let collaborators = repository.collaborators?.nodes, !collaborators.isEmpty {
                    ContributorsSection(collaborators: collaborators)
                }

                QuickActionsToolbar(repository: repository)
            }
            .padding(Spacing.lg)
        }
        .background(theme.background)
        .refreshable {
            SoundManager.shared.playRefreshSound()
            onRefresh()
        }
    }
}

private struct RepositoryHeader: View {
    @Environment(\.theme) private var theme

    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Text(repository.name)
                            .font(Typography.display())
                            .foregroundStyle(theme.text)

                        if repository.isPrivate {
                            Label("Private", systemImage: "lock.fill")
                                .font(Typography.caption())
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(theme.tertiaryBackground)
                                .clipShape(Capsule())
                        }

                        if repository.isFork {
                            Label("Fork", systemImage: "tuningfork")
                                .font(Typography.caption())
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(theme.tertiaryBackground)
                                .clipShape(Capsule())
                        }
                    }

                    Text(repository.nameWithOwner)
                        .font(Typography.body())
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()
            }

            if let description = repository.description {
                Text(description)
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .lineLimit(nil)
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

private struct QuickStatsBar: View {
    @Environment(\.theme) private var theme

    let repository: Repository

    var body: some View {
        HStack(spacing: Spacing.lg) {
            StatItem(
                icon: "star.fill",
                value: repository.formattedStars,
                label: "Stars"
            )

            StatItem(
                icon: "tuningfork",
                value: repository.formattedForks,
                label: "Forks"
            )

            if let watchers = repository.watchers {
                StatItem(
                    icon: "eye.fill",
                    value: formatCount(watchers.totalCount),
                    label: "Watchers"
                )
            }

            if let issues = repository.issues {
                StatItem(
                    icon: "exclamationmark.circle.fill",
                    value: formatCount(issues.totalCount),
                    label: "Open Issues"
                )
            }

            if let pullRequests = repository.pullRequests {
                StatItem(
                    icon: "arrow.triangle.branch",
                    value: formatCount(pullRequests.totalCount),
                    label: "Open PRs"
                )
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

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}

private struct StatItem: View {
    @Environment(\.theme) private var theme

    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Label(value, systemImage: icon)
                .font(Typography.headline())
                .foregroundStyle(theme.text)

            Text(label)
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CommitTimelineSection: View {
    @Environment(\.theme) private var theme

    let commits: [Commit]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Activity")
                .font(Typography.headline())
                .foregroundStyle(theme.text)

            VStack(spacing: Spacing.sm) {
                ForEach(commits) { commit in
                    CommitTimelineRow(commit: commit)
                }
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

private struct BranchesSection: View {
    @Environment(\.theme) private var theme

    let branches: [Branch]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Branches")
                .font(Typography.headline())
                .foregroundStyle(theme.text)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(branches) { branch in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .frame(width: 16)

                        Text(branch.name)
                            .font(Typography.body())
                            .foregroundStyle(theme.text)

                        Spacer()

                        Text(branch.target.oid.prefix(7))
                            .font(Typography.code())
                            .foregroundStyle(theme.tertiaryText)
                    }
                    .padding(Spacing.sm)
                    .background(theme.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                }
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

private struct ContributorsSection: View {
    @Environment(\.theme) private var theme

    let collaborators: [Collaborator]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Contributors")
                .font(Typography.headline())
                .foregroundStyle(theme.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(collaborators) { collaborator in
                        VStack(spacing: Spacing.xs) {
                            AvatarView(
                                url: collaborator.avatarUrl,
                                size: 48,
                                fallbackInitials: String(collaborator.login.prefix(2)).uppercased()
                            )

                            Text(collaborator.login)
                                .font(Typography.caption())
                                .foregroundStyle(theme.text)
                                .lineLimit(1)
                                .frame(width: 60)
                        }
                    }
                }
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

private struct QuickActionsToolbar: View {
    @Environment(\.theme) private var theme

    let repository: Repository

    var body: some View {
        HStack(spacing: Spacing.md) {
            Button(action: {
                if let url = URL(string: repository.url) {
                    #if os(macOS)
                    NSWorkspace.shared.open(url)
                    #else
                    UIApplication.shared.open(url)
                    #endif
                }
            }) {
                Label("Open in Browser", systemImage: "safari")
                    .font(Typography.body())
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
            .buttonStyle(.plain)

            Button(action: {
                #if os(macOS)
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(repository.url, forType: .string)
                #else
                UIPasteboard.general.string = repository.url
                #endif
            }) {
                Label("Copy URL", systemImage: "doc.on.doc")
                    .font(Typography.body())
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(theme.secondaryBackground)
                    .foregroundStyle(theme.text)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(theme.border, lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

