import Foundation
import SwiftData

protocol GitHubRepositoryProtocol {
    func fetchUser(forceRefresh: Bool) async throws -> User
    func fetchRepositories(forceRefresh: Bool) async throws -> [Repository]
    func fetchPullRequests(forceRefresh: Bool) async throws -> [PullRequest]
    func fetchReviewRequests() async throws -> [PullRequest]
    func fetchRepositoryDetails(owner: String, name: String) async throws -> Repository
}

final class GitHubRepository: GitHubRepositoryProtocol {
    private let api: GitHubAPI
    private let modelContext: ModelContext
    private let keychainManager: KeychainManager
    private let currentAccount: String

    init(
        api: GitHubAPI,
        modelContext: ModelContext,
        keychainManager: KeychainManager = .shared,
        currentAccount: String
    ) {
        self.api = api
        self.modelContext = modelContext
        self.keychainManager = keychainManager
        self.currentAccount = currentAccount
    }

    func fetchUser(forceRefresh: Bool = false) async throws -> User {
        let descriptor = FetchDescriptor<CachedUser>(
            predicate: #Predicate { $0.login == currentAccount }
        )

        if !forceRefresh,
            let cached = try modelContext.fetch(descriptor).first,
            cached.isFresh {
            return cached.toDomain()
        }

        let token = try keychainManager.retrieve(for: currentAccount)
        let response: GraphQLResponse<ViewerResponse> = try await api.executeGraphQL(
            query: GraphQLQueries.viewer,
            token: token
        )

        let result = try response.result.get()
        print("Successfully decoded ViewerResponse")
        print("   User ID: \(result.viewer.id)")
        print("   Login: \(result.viewer.login)")
        print("   Has contributions: \(result.viewer.contributionsCollection != nil)")
        
        let user = result.viewer

        if let cached = try modelContext.fetch(descriptor).first {
            cached.update(from: user)
        } else {
            let newCached = CachedUser(
                login: user.login,
                name: user.name,
                email: user.email,
                avatarUrl: user.avatarUrl,
                bio: user.bio,
                company: user.company,
                location: user.location,
                url: user.url
            )
            newCached.update(from: user)
            modelContext.insert(newCached)
        }

        try modelContext.save()
        return user
    }

    func fetchRepositories(forceRefresh: Bool = false) async throws -> [Repository] {
        let descriptor = FetchDescriptor<CachedRepository>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        if !forceRefresh,
            let cached = try? modelContext.fetch(descriptor),
            !cached.isEmpty,
            cached.first?.isFresh == true {
            return cached.map { $0.toDomain() }
        }

        let token = try keychainManager.retrieve(for: currentAccount)
        var allRepositories: [Repository] = []
        var cursor: String? = nil
        var hasNextPage = true

        // Fetch all pages of repositories
        while hasNextPage {
            let response: GraphQLResponse<RepositoriesResponse> = try await api.executeGraphQL(
                query: GraphQLQueries.repositories,
                variables: cursor != nil ? ["cursor": cursor!] : nil,
                token: token
            )

            let result = try response.result.get()
            let repositories = result.viewer.repositories.nodes
            allRepositories.append(contentsOf: repositories)
            
            let pageInfo = result.viewer.repositories.pageInfo
            hasNextPage = pageInfo.hasNextPage
            cursor = pageInfo.endCursor
        }

        for repository in allRepositories {
            let cachedDescriptor = FetchDescriptor<CachedRepository>(
                predicate: #Predicate { $0.id == repository.id }
            )

            if let cached = try modelContext.fetch(cachedDescriptor).first {
                cached.update(from: repository)
            } else {
                let newCached = CachedRepository(
                    id: repository.id,
                    name: repository.name,
                    nameWithOwner: repository.nameWithOwner,
                    repositoryDescription: repository.description,
                    url: repository.url,
                    stargazerCount: repository.stargazerCount,
                    forkCount: repository.forkCount,
                    primaryLanguageName: repository.primaryLanguage?.name,
                    primaryLanguageColor: repository.primaryLanguage?.color,
                    updatedAt: repository.updatedAt,
                    pushedAt: repository.pushedAt,
                    isPrivate: repository.isPrivate,
                    isFork: repository.isFork,
                    ownerLogin: repository.owner.login,
                    ownerAvatarUrl: repository.owner.avatarUrl
                )
                modelContext.insert(newCached)
            }
        }

        try modelContext.save()
        return allRepositories
    }

    func fetchPullRequests(forceRefresh: Bool = false) async throws -> [PullRequest] {
        let descriptor = FetchDescriptor<CachedPullRequest>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        if !forceRefresh,
            let cached = try? modelContext.fetch(descriptor),
            !cached.isEmpty,
            cached.first?.isFresh == true {
            return cached.map { $0.toDomain() }
        }

        let token = try keychainManager.retrieve(for: currentAccount)
        let response: GraphQLResponse<PullRequestsResponse> = try await api.executeGraphQL(
            query: GraphQLQueries.pullRequests,
            token: token
        )

        let pullRequests = try response.result.get().viewer.pullRequests.nodes

        for pr in pullRequests {
            let cachedDescriptor = FetchDescriptor<CachedPullRequest>(
                predicate: #Predicate { $0.id == pr.id }
            )

            if let cached = try modelContext.fetch(cachedDescriptor).first {
                cached.update(from: pr)
            } else {
                let newCached = CachedPullRequest(
                    id: pr.id,
                    title: pr.title,
                    number: pr.number,
                    url: pr.url,
                    state: pr.state.rawValue,
                    isDraft: pr.isDraft,
                    createdAt: pr.createdAt,
                    updatedAt: pr.updatedAt,
                    mergedAt: pr.mergedAt,
                    closedAt: pr.closedAt,
                    additions: pr.additions,
                    deletions: pr.deletions,
                    repositoryName: pr.repository.name,
                    repositoryNameWithOwner: pr.repository.nameWithOwner,
                    repositoryOwnerLogin: pr.repository.owner.login,
                    authorLogin: pr.author.login,
                    authorAvatarUrl: pr.author.avatarUrl,
                    reviewDecision: pr.reviewDecision?.rawValue
                )
                modelContext.insert(newCached)
            }
        }

        try modelContext.save()
        return pullRequests
    }

    func fetchReviewRequests() async throws -> [PullRequest] {
        let token = try keychainManager.retrieve(for: currentAccount)
        let response: GraphQLResponse<ReviewRequestsResponse> = try await api.executeGraphQL(
            query: GraphQLQueries.reviewRequests,
            token: token
        )

        return try response.result.get().search.nodes
    }

    func fetchRepositoryDetails(owner: String, name: String) async throws -> Repository {
        let token = try keychainManager.retrieve(for: currentAccount)
        let variables: [String: Any] = [
            "owner": owner,
            "name": name
        ]

        let response: GraphQLResponse<RepositoryDetailResponse> = try await api.executeGraphQL(
            query: GraphQLQueries.repositoryDetails,
            variables: variables,
            token: token
        )

        return try response.result.get().repository
    }
}

extension CachedUser {
    func toDomain() -> User {
        let contributionCalendar: ContributionCalendar?
        if let cachedCalendar = self.contributionCalendar {
            contributionCalendar = cachedCalendar.toDomain()
        } else {
            contributionCalendar = ContributionCalendar(
                totalContributions: totalContributions,
                weeks: nil
            )
        }
        
        return User(
            id: login,
            login: login,
            name: name,
            email: email,
            avatarUrl: avatarUrl,
            bio: bio,
            company: company,
            location: location,
            url: url,
            status: nil, 
            contributionsCollection: ContributionsCollection(
                contributionCalendar: contributionCalendar,
                totalCommitContributions: totalCommits,
                totalIssueContributions: totalIssues,
                totalPullRequestContributions: totalPRs,
                totalPullRequestReviewContributions: totalReviews,
                commitContributionsByRepository: nil
            )
        )
    }
}
