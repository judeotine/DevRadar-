import SwiftUI

struct PullRequestsView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: PullRequestsViewModel
    @State private var hasAttemptedLoad = false
    
    private var pullRequests: [PullRequest] {
        if case .loaded(let prs) = viewModel.state {
            return prs
        }
        return []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Pull Requests")
                        .font(Typography.title())
                        .foregroundStyle(theme.text)
                        .responsiveText()
                    Spacer()
                }
                .padding(Spacing.lg)
                .background(theme.background)
                
                Group {
                    switch viewModel.state {
                    case .loading:
                        PullRequestsSkeleton()
                    case .loaded:
                        if pullRequests.isEmpty {
                            EmptyStateView(
                                icon: "arrow.triangle.branch",
                                title: "No Pull Requests",
                                message: "You don't have any pull requests yet."
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: Spacing.sm) {
                                    ForEach(pullRequests) { pr in
                                        NavigationLink(value: pr) {
                                            PRStatusRow(pullRequest: pr)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(Spacing.lg)
                            }
                            .background(theme.background)
                            .refreshable {
                                SoundManager.shared.playRefreshSound()
                                await viewModel.refresh()
                            }
                            .navigationDestination(for: PullRequest.self) { pr in
                                PullRequestDetailView(pullRequest: pr)
                            }
                        }
                    case .error(let error):
                        ErrorView(error: error) {
                            Task { await viewModel.load() }
                        }
                    }
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
