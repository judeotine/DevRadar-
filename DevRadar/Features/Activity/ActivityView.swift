import SwiftUI

struct ActivityView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: ActivityViewModel
    @State private var hasAttemptedLoad = false
    
    private var user: User? {
        if case .loaded(let u) = viewModel.state {
            return u
        }
        return nil
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ActivitySkeleton()
            case .loaded(let user):
                if let contributions = user.contributionsCollection {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            if let calendar = contributions.contributionCalendar {
                                ContributionGraph(calendar: calendar)
                            }
                            
                            ContributionStatsView(contributions: contributions)
                            
                            DetailedStatsView(contributions: contributions)
                            
                            if let repoContributions = contributions.commitContributionsByRepository, !repoContributions.isEmpty {
                                RepositoryContributionsSection(contributions: repoContributions)
                            }
                        }
                        .padding(Spacing.lg)
                    }
                    .background(theme.background)
                    .refreshable {
                        SoundManager.shared.playRefreshSound()
                        await viewModel.refresh()
                    }
                }
            case .error(let error):
                ErrorView(error: error) {
                    Task { await viewModel.load() }
                }
            }
        }
        .task {
            guard !hasAttemptedLoad else { return }
            hasAttemptedLoad = true
            await viewModel.load()
        }
    }
}

private struct ContributionStatsView: View {
    @Environment(\.theme) private var theme
    let contributions: ContributionsCollection

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Contribution Statistics")
                .font(Typography.title())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.md
            ) {
                StatCard(
                    icon: "flame.fill",
                    label: "Current Streak",
                    value: "\(contributions.safeContributionCalendar.currentStreak()) days"
                )

                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Total Contributions",
                    value: "\(contributions.totalContributions)"
                )

                StatCard(
                    icon: "arrow.up.circle.fill",
                    label: "Commits",
                    value: "\(contributions.totalCommitContributions)"
                )

                StatCard(
                    icon: "arrow.triangle.branch",
                    label: "Pull Requests",
                    value: "\(contributions.totalPullRequestContributions)"
                )
                
                StatCard(
                    icon: "exclamationmark.circle.fill",
                    label: "Issues",
                    value: "\(contributions.totalIssueContributions)"
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    label: "Reviews",
                    value: "\(contributions.totalPullRequestReviewContributions)"
                )
            }
        }
    }
}

private struct DetailedStatsView: View {
    @Environment(\.theme) private var theme
    let contributions: ContributionsCollection
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Detailed Breakdown")
                .font(Typography.title())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            VStack(spacing: Spacing.md) {
                StatRow(
                    icon: "arrow.up.circle.fill",
                    label: "Total Commits",
                    value: "\(contributions.totalCommitContributions)",
                    color: .blue
                )
                
                StatRow(
                    icon: "arrow.triangle.branch",
                    label: "Pull Requests",
                    value: "\(contributions.totalPullRequestContributions)",
                    color: .purple
                )
                
                StatRow(
                    icon: "exclamationmark.circle.fill",
                    label: "Issues",
                    value: "\(contributions.totalIssueContributions)",
                    color: .orange
                )
                
                StatRow(
                    icon: "checkmark.circle.fill",
                    label: "Code Reviews",
                    value: "\(contributions.totalPullRequestReviewContributions)",
                    color: .green
                )
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
}

private struct StatRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(label)
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            Spacer()
            
            Text(value)
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
        }
    }
}

private struct RepositoryContributionsSection: View {
    @Environment(\.theme) private var theme
    let contributions: [RepositoryContribution]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Top Repositories")
                .font(Typography.title())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            VStack(spacing: Spacing.sm) {
                ForEach(Array(contributions.prefix(10).enumerated()), id: \.offset) { index, contribution in
                    RepositoryContributionRow(
                        rank: index + 1,
                        contribution: contribution
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
    }
}

private struct RepositoryContributionRow: View {
    @Environment(\.theme) private var theme
    let rank: Int
    let contribution: RepositoryContribution
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(contribution.repository.nameWithOwner)
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                
                Text("\(contribution.contributions.nodes.count) contributions")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
            }
            
            Spacer()
        }
        .padding(Spacing.sm)
        .background(theme.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}
