import Foundation
import SwiftUI

enum DashboardState {
    case loading
    case loaded(DashboardData)
    case error(Error)
}

struct DashboardData {
    let user: User
    let repositories: [Repository]
    let pullRequests: [PullRequest]
    let reviewRequests: [PullRequest]
    let repository: GitHubRepositoryProtocol

    var currentStreak: Int {
        user.contributionsCollection?.safeContributionCalendar.currentStreak() ?? 0
    }

    var longestStreak: Int {
        user.contributionsCollection?.safeContributionCalendar.longestStreak() ?? 0
    }

    var totalContributions: Int {
        user.contributionsCollection?.safeContributionCalendar.totalContributions ?? 0
    }

    var openPRCount: Int {
        pullRequests.filter { $0.state == .open }.count
    }

    var pendingReviewCount: Int {
        reviewRequests.count
    }

    var totalCommits: Int {
        user.contributionsCollection?.totalCommitContributions ?? 0
    }
}

@Observable
final class DashboardViewModel {
    private(set) var state: DashboardState = .loading
    private var hasLoaded = false

    private let repository: GitHubRepositoryProtocol

    init(repository: GitHubRepositoryProtocol) {
        self.repository = repository
    }

    func load() async {
        if hasLoaded {
            return
        }
        
        hasLoaded = true
        state = .loading

        do {
            async let userTask = repository.fetchUser(forceRefresh: false)
            async let repositoriesTask = repository.fetchRepositories(forceRefresh: false)
            async let pullRequestsTask = repository.fetchPullRequests(forceRefresh: false)
            async let reviewRequestsTask = repository.fetchReviewRequests()

            let (user, repositories, pullRequests, reviewRequests) = try await (
                userTask,
                repositoriesTask,
                pullRequestsTask,
                reviewRequestsTask
            )

            let data = DashboardData(
                user: user,
                repositories: repositories,
                pullRequests: pullRequests,
                reviewRequests: reviewRequests,
                repository: repository
            )

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(data)
            }
        } catch {
            withAnimation {
                state = .error(error)
            }
        }
    }

    func refresh() async {
        guard case .loaded = state else { return }

        do {
            async let userTask = repository.fetchUser(forceRefresh: true)
            async let repositoriesTask = repository.fetchRepositories(forceRefresh: true)
            async let pullRequestsTask = repository.fetchPullRequests(forceRefresh: true)
            async let reviewRequestsTask = repository.fetchReviewRequests()

            let (user, repositories, pullRequests, reviewRequests) = try await (
                userTask,
                repositoriesTask,
                pullRequestsTask,
                reviewRequestsTask
            )

            let data = DashboardData(
                user: user,
                repositories: repositories,
                pullRequests: pullRequests,
                reviewRequests: reviewRequests,
                repository: repository
            )

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(data)
            }
        } catch {
            withAnimation {
                state = .error(error)
            }
        }
    }
}
