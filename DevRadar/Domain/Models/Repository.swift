import Foundation

struct Repository: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameWithOwner: String
    let description: String?
    let url: String
    let stargazerCount: Int
    let forkCount: Int
    let primaryLanguage: Language?
    let languages: LanguageConnection?
    let updatedAt: Date
    let pushedAt: Date?
    let createdAt: Date?
    let isPrivate: Bool
    let isFork: Bool
    let owner: RepositoryOwner
    let watchers: WatcherConnection?
    let issues: IssueConnection?
    let pullRequests: PullRequestConnection?
    let defaultBranchRef: BranchRef?
    let refs: BranchConnection?
    let collaborators: CollaboratorConnection?

    var displayLanguage: String {
        primaryLanguage?.name ?? "Unknown"
    }

    var languageColor: String {
        primaryLanguage?.color ?? "#858585"
    }

    var formattedStars: String {
        formatCount(stargazerCount)
    }

    var formattedForks: String {
        formatCount(forkCount)
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
}

struct Language: Codable {
    let name: String
    let color: String?
}

struct LanguageConnection: Codable {
    let edges: [LanguageEdge]

    var totalSize: Int {
        edges.reduce(0) { $0 + $1.size }
    }

    var percentages: [(language: Language, percentage: Double)] {
        let total = Double(totalSize)
        guard total > 0 else { return [] }

        return edges.map { edge in
            let percentage = (Double(edge.size) / total) * 100
            return (edge.node, percentage)
        }
    }
}

struct LanguageEdge: Codable {
    let size: Int
    let node: Language
}

struct RepositoryOwner: Codable {
    let login: String
    let avatarUrl: String
}

struct WatcherConnection: Codable {
    let totalCount: Int
}

struct IssueConnection: Codable {
    let totalCount: Int
}

struct PullRequestConnection: Codable {
    let totalCount: Int
}

struct BranchRef: Codable {
    let name: String?
    let target: Target

    struct Target: Codable {
        let history: CommitHistory
    }
}

struct BranchConnection: Codable {
    let nodes: [Branch]
}

struct Branch: Codable, Identifiable {
    let name: String
    let target: BranchTarget

    var id: String { name }

    struct BranchTarget: Codable {
        let oid: String
    }
}

struct CollaboratorConnection: Codable {
    let nodes: [Collaborator]
}

struct Collaborator: Codable, Identifiable {
    let login: String
    let avatarUrl: String

    var id: String { login }
}

struct CommitHistory: Codable {
    let nodes: [Commit]
}

struct Commit: Codable, Identifiable {
    let oid: String
    let message: String
    let committedDate: Date
    let author: CommitAuthor
    let additions: Int
    let deletions: Int

    var id: String { oid }

    var shortMessage: String {
        message.components(separatedBy: "\n").first ?? message
    }

    var changeCount: Int {
        additions + deletions
    }
}

struct CommitAuthor: Codable {
    let name: String
    let email: String
    let user: CommitUser?
}

struct CommitUser: Codable {
    let login: String
    let avatarUrl: String
}
