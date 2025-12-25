import SwiftUI

struct DashboardView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: DashboardViewModel
    @Bindable var authManager: AuthenticationManager
    @Binding var selectedAppTab: AppTab
    @State private var hasAttemptedLoad = false

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                DashboardSkeleton()

            case .loaded(let data):
                LoadedContent(
                    data: data,
                    onRefresh: {
                        Task { await viewModel.refresh() }
                    },
                    authManager: authManager,
                    selectedAppTab: $selectedAppTab
                )

            case .error(let error):
                ErrorViewWithSignOut(error: error, onRetry: {
                    Task { await viewModel.load() }
                }, onSignOut: {
                    authManager.signOut()
                })
            }
        }
        .task {
            guard !hasAttemptedLoad else { return }
            hasAttemptedLoad = true
            await viewModel.load()
        }
    }
}

private struct LoadedContent: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    let data: DashboardData
    let onRefresh: () -> Void
    @Bindable var authManager: AuthenticationManager
    @State private var selectedTab: DashboardTab = .overview
    @Binding var selectedAppTab: AppTab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        ProfileHeaderSection(
                            user: data.user,
                            contributionPercentage: min(Int((Double(data.totalContributions) / 1000.0) * 100), 100)
                        )
                        
                        if let calendar = data.user.contributionsCollection?.contributionCalendar {
                            ContributionGraph(calendar: calendar)
                        }
                        
                        DashboardTabs(selectedTab: $selectedTab)
                        
                        Group {
                            switch selectedTab {
                            case .overview:
                                OverviewContent(data: data)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                            case .activity:
                                ActivityContent(data: data, selectedAppTab: $selectedAppTab)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                }
                .background(theme.background)
                .refreshable {
                    SoundManager.shared.playRefreshSound()
                    onRefresh()
                }
            }
            .navigationDestination(for: PullRequest.self) { pr in
                PullRequestDetailView(pullRequest: pr)
            }
            .navigationDestination(for: Repository.self) { repo in
                RepositoryDetailView(
                    viewModel: RepositoryDetailViewModel(
                        repository: data.repository,
                        owner: repo.owner.login,
                        name: repo.name
                    )
                )
            }
        }
        .navigationBarHidden(true)
    }
}

enum DashboardTab: String, CaseIterable {
    case overview = "Overview"
    case activity = "Activity"
    
    var title: String {
        rawValue
    }
}

private struct ProfileHeaderSection: View {
    @Environment(\.theme) private var theme
    let user: User
    let contributionPercentage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(Greeting.greeting(for: user.displayName))
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            ProfileHeader(user: user, contributionPercentage: contributionPercentage)
        }
    }
}

private struct DashboardTabs: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTab: DashboardTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: Spacing.xs) {
                        Text(tab.title)
                            .font(Typography.body())
                            .foregroundStyle(selectedTab == tab ? theme.text : theme.secondaryText)
                            .responsiveText()
                        
                        Rectangle()
                            .fill(selectedTab == tab ? theme.primary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct OverviewContent: View {
    let data: DashboardData
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            InfoCardsRow(data: data)
            
            if !data.reviewRequests.isEmpty {
                ReviewRequestsCard(pullRequests: data.reviewRequests)
            }
            
            GitHubStatsCard(data: data)
        }
    }
}

private struct ActivityContent: View {
    @Environment(\.theme) private var theme
    let data: DashboardData
    @Binding var selectedAppTab: AppTab
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            RecentRepositoriesSection(
                repositories: Array(data.repositories.prefix(6)),
                repository: data.repository,
                selectedAppTab: $selectedAppTab
            )
            
            RecentPullRequestsSection(
                selectedAppTab: $selectedAppTab,
                pullRequests: Array(data.pullRequests.prefix(5))
            )
        }
    }
}

private struct InfoCardsRow: View {
    let data: DashboardData
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            InfoCard(
                icon: "gauge.high",
                iconColor: .green,
                title: "Your activity",
                value: data.totalContributions > 1000 ? "High" : data.totalContributions > 500 ? "Medium" : "Low"
            )
            .frame(minWidth: 0, maxWidth: .infinity)
            
            InfoCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Current Streak",
                value: "\(data.currentStreak) days"
            )
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

private struct RecentRepositoriesSection: View {
    @Environment(\.theme) private var theme

    let repositories: [Repository]
    let repository: GitHubRepositoryProtocol
    @Binding var selectedAppTab: AppTab

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Repositories")
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)
                    .responsiveText()

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedAppTab = .repositories
                    }
                }) {
                    Text("View All")
                        .font(Typography.caption())
                        .foregroundStyle(theme.primary)
                }
                .buttonStyle(.plain)
            }

            if repositories.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "folder")
                        .font(.system(size: 40))
                        .foregroundStyle(theme.secondaryText)
                    
                    Text("No repositories")
                        .font(Typography.body())
                        .foregroundStyle(theme.secondaryText)
                        .responsiveText()
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.xl)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: Spacing.md
                ) {
                    ForEach(repositories) { repo in
                        NavigationLink(value: repo) {
                            RepositoryCard(repository: repo)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct RecentPullRequestsSection: View {
    @Environment(\.theme) private var theme
    @Binding var selectedAppTab: AppTab

    let pullRequests: [PullRequest]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Pull Requests")
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)
                    .responsiveText()

                Spacer()

                Button(action: {
                    selectedAppTab = .pullRequests
                }) {
                    Text("View All")
                        .font(Typography.caption())
                        .foregroundStyle(theme.primary)
                }
                .buttonStyle(.plain)
            }

            if pullRequests.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 40))
                        .foregroundStyle(theme.secondaryText)
                    
                    Text("No pull requests")
                        .font(Typography.body())
                        .foregroundStyle(theme.secondaryText)
                        .responsiveText()
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.xl)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(pullRequests) { pr in
                        NavigationLink(value: pr) {
                            PRStatusRow(pullRequest: pr)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct ReviewRequestsCard: View {
    @Environment(\.theme) private var theme
    let pullRequests: [PullRequest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Review Requests")
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                
                Spacer()
                
                Text("\(pullRequests.count)")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(theme.tertiaryBackground)
                    .clipShape(Capsule())
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(Array(pullRequests.prefix(3))) { pr in
                    NavigationLink(value: pr) {
                        PRStatusRow(pullRequest: pr)
                    }
                    .buttonStyle(.plain)
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


private struct ErrorViewWithSignOut: View {
    @Environment(\.theme) private var theme

    let error: Error
    let onRetry: () -> Void
    let onSignOut: () -> Void

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

            VStack(spacing: Spacing.md) {
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(Typography.body())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }
                .buttonStyle(.plain)

                Button(action: onSignOut) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(Typography.body())
                        .foregroundStyle(theme.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(theme.tertiaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
        .background(theme.background)
    }
}
