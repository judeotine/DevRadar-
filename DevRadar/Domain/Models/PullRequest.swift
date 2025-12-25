import Foundation

struct PullRequest: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let number: Int
    let url: String
    let state: PRState
    let isDraft: Bool
    let createdAt: Date
    let updatedAt: Date
    let mergedAt: Date?
    let closedAt: Date?
    let additions: Int
    let deletions: Int
    let repository: PRRepository
    let author: PRAuthor
    let reviewDecision: ReviewDecision?
    let reviews: ReviewConnection?

    var statusColor: String {
        if state == .merged {
            return "#8957E5"
        }

        switch reviewDecision {
        case .approved:
            return "#3FB950"
        case .changesRequested:
            return "#F85149"
        case .reviewRequired, .none:
            return "#858585"
        }
    }

    var statusText: String {
        if state == .merged {
            return "Merged"
        } else if state == .closed {
            return "Closed"
        } else if isDraft {
            return "Draft"
        }

        switch reviewDecision {
        case .approved:
            return "Approved"
        case .changesRequested:
            return "Changes Requested"
        case .reviewRequired:
            return "Review Required"
        case .none:
            return "Open"
        }
    }

    var changeCount: Int {
        additions + deletions
    }

    var reviewerCount: Int {
        Set(reviews?.nodes.compactMap { $0.author.login } ?? []).count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PullRequest, rhs: PullRequest) -> Bool {
        lhs.id == rhs.id
    }
}

enum PRState: String, Codable {
    case open = "OPEN"
    case closed = "CLOSED"
    case merged = "MERGED"
}

enum ReviewDecision: String, Codable {
    case approved = "APPROVED"
    case changesRequested = "CHANGES_REQUESTED"
    case reviewRequired = "REVIEW_REQUIRED"
}

struct PRRepository: Codable {
    let name: String
    let nameWithOwner: String
    let owner: PROwner
}

struct PROwner: Codable {
    let login: String
}

struct PRAuthor: Codable {
    let login: String
    let avatarUrl: String
}

struct ReviewConnection: Codable {
    let nodes: [Review]
}

struct Review: Codable {
    let author: ReviewAuthor
    let state: ReviewState
}

struct ReviewAuthor: Codable {
    let login: String
}

enum ReviewState: String, Codable {
    case approved = "APPROVED"
    case changesRequested = "CHANGES_REQUESTED"
    case commented = "COMMENTED"
    case dismissed = "DISMISSED"
    case pending = "PENDING"
}
