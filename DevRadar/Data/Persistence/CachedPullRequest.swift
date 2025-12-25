import Foundation
import SwiftData

@Model
final class CachedPullRequest {
    @Attribute(.unique) var id: String
    var title: String
    var number: Int
    var url: String
    var state: String
    var isDraft: Bool
    var createdAt: Date
    var updatedAt: Date
    var mergedAt: Date?
    var closedAt: Date?
    var additions: Int
    var deletions: Int
    var repositoryName: String
    var repositoryNameWithOwner: String
    var repositoryOwnerLogin: String
    var authorLogin: String
    var authorAvatarUrl: String
    var reviewDecision: String?
    var cachedAt: Date

    var user: CachedUser?

    init(
        id: String,
        title: String,
        number: Int,
        url: String,
        state: String,
        isDraft: Bool,
        createdAt: Date,
        updatedAt: Date,
        mergedAt: Date? = nil,
        closedAt: Date? = nil,
        additions: Int,
        deletions: Int,
        repositoryName: String,
        repositoryNameWithOwner: String,
        repositoryOwnerLogin: String,
        authorLogin: String,
        authorAvatarUrl: String,
        reviewDecision: String? = nil,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.number = number
        self.url = url
        self.state = state
        self.isDraft = isDraft
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mergedAt = mergedAt
        self.closedAt = closedAt
        self.additions = additions
        self.deletions = deletions
        self.repositoryName = repositoryName
        self.repositoryNameWithOwner = repositoryNameWithOwner
        self.repositoryOwnerLogin = repositoryOwnerLogin
        self.authorLogin = authorLogin
        self.authorAvatarUrl = authorAvatarUrl
        self.reviewDecision = reviewDecision
        self.cachedAt = cachedAt
    }

    var isFresh: Bool {
        Date().timeIntervalSince(cachedAt) < 900
    }

    func update(from pr: PullRequest) {
        self.title = pr.title
        self.number = pr.number
        self.url = pr.url
        self.state = pr.state.rawValue
        self.isDraft = pr.isDraft
        self.createdAt = pr.createdAt
        self.updatedAt = pr.updatedAt
        self.mergedAt = pr.mergedAt
        self.closedAt = pr.closedAt
        self.additions = pr.additions
        self.deletions = pr.deletions
        self.repositoryName = pr.repository.name
        self.repositoryNameWithOwner = pr.repository.nameWithOwner
        self.repositoryOwnerLogin = pr.repository.owner.login
        self.authorLogin = pr.author.login
        self.authorAvatarUrl = pr.author.avatarUrl
        self.reviewDecision = pr.reviewDecision?.rawValue
        self.cachedAt = Date()
    }

    func toDomain() -> PullRequest {
        PullRequest(
            id: id,
            title: title,
            number: number,
            url: url,
            state: PRState(rawValue: state) ?? .open,
            isDraft: isDraft,
            createdAt: createdAt,
            updatedAt: updatedAt,
            mergedAt: mergedAt,
            closedAt: closedAt,
            additions: additions,
            deletions: deletions,
            repository: PRRepository(
                name: repositoryName,
                nameWithOwner: repositoryNameWithOwner,
                owner: PROwner(login: repositoryOwnerLogin)
            ),
            author: PRAuthor(login: authorLogin, avatarUrl: authorAvatarUrl),
            reviewDecision: reviewDecision.flatMap { ReviewDecision(rawValue: $0) },
            reviews: nil
        )
    }
}
