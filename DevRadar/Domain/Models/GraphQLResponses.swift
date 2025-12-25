import Foundation

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?

    var result: Result<T, Error> {
        if let errors = errors, !errors.isEmpty {
            return .failure(GraphQLResponseError.graphQLErrors(errors))
        }

        guard let data = data else {
            return .failure(GraphQLResponseError.noData)
        }

        return .success(data)
    }
}

struct GraphQLError: Decodable {
    let message: String
    let locations: [Location]?
    let path: [String]?

    struct Location: Decodable {
        let line: Int
        let column: Int
    }
}

enum GraphQLResponseError: Error, LocalizedError {
    case graphQLErrors([GraphQLError])
    case noData

    var errorDescription: String? {
        switch self {
        case .graphQLErrors(let errors):
            return errors.map { $0.message }.joined(separator: "\n")
        case .noData:
            return "No data received from GraphQL query"
        }
    }
}

struct ViewerResponse: Decodable {
    let viewer: User
}

struct RepositoriesResponse: Decodable {
    let viewer: ViewerRepositories

    struct ViewerRepositories: Decodable {
        let repositories: RepositoryConnection
    }

    struct RepositoryConnection: Decodable {
        let pageInfo: PageInfo
        let nodes: [Repository]
    }
}

struct PullRequestsResponse: Decodable {
    let viewer: ViewerPullRequests

    struct ViewerPullRequests: Decodable {
        let pullRequests: PullRequestConnection

        struct PullRequestConnection: Decodable {
            let pageInfo: PageInfo
            let nodes: [PullRequest]
        }
    }
}

struct ReviewRequestsResponse: Decodable {
    let search: SearchConnection

    struct SearchConnection: Decodable {
        let nodes: [PullRequest]
    }
}

struct RepositoryDetailResponse: Decodable {
    let repository: Repository
}

struct ContributionActivityResponse: Decodable {
    let viewer: ViewerContributions

    struct ViewerContributions: Decodable {
        let contributionsCollection: ContributionsCollection
    }
}

struct PageInfo: Decodable {
    let hasNextPage: Bool
    let endCursor: String?
}
