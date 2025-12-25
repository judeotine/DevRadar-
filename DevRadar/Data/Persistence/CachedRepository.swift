import Foundation
import SwiftData

@Model
final class CachedRepository {
    @Attribute(.unique) var id: String
    var name: String
    var nameWithOwner: String
    var repositoryDescription: String?
    var url: String
    var stargazerCount: Int
    var forkCount: Int
    var primaryLanguageName: String?
    var primaryLanguageColor: String?
    var updatedAt: Date
    var pushedAt: Date?
    var isPrivate: Bool
    var isFork: Bool
    var ownerLogin: String
    var ownerAvatarUrl: String
    var cachedAt: Date

    var user: CachedUser?

    init(
        id: String,
        name: String,
        nameWithOwner: String,
        repositoryDescription: String? = nil,
        url: String,
        stargazerCount: Int = 0,
        forkCount: Int = 0,
        primaryLanguageName: String? = nil,
        primaryLanguageColor: String? = nil,
        updatedAt: Date,
        pushedAt: Date? = nil,
        isPrivate: Bool = false,
        isFork: Bool = false,
        ownerLogin: String,
        ownerAvatarUrl: String,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.nameWithOwner = nameWithOwner
        self.repositoryDescription = repositoryDescription
        self.url = url
        self.stargazerCount = stargazerCount
        self.forkCount = forkCount
        self.primaryLanguageName = primaryLanguageName
        self.primaryLanguageColor = primaryLanguageColor
        self.updatedAt = updatedAt
        self.pushedAt = pushedAt
        self.isPrivate = isPrivate
        self.isFork = isFork
        self.ownerLogin = ownerLogin
        self.ownerAvatarUrl = ownerAvatarUrl
        self.cachedAt = cachedAt
    }

    var isFresh: Bool {
        Date().timeIntervalSince(cachedAt) < 900
    }

    func update(from repository: Repository) {
        self.name = repository.name
        self.nameWithOwner = repository.nameWithOwner
        self.repositoryDescription = repository.description
        self.url = repository.url
        self.stargazerCount = repository.stargazerCount
        self.forkCount = repository.forkCount
        self.primaryLanguageName = repository.primaryLanguage?.name
        self.primaryLanguageColor = repository.primaryLanguage?.color
        self.updatedAt = repository.updatedAt
        self.pushedAt = repository.pushedAt
        self.isPrivate = repository.isPrivate
        self.isFork = repository.isFork
        self.ownerLogin = repository.owner.login
        self.ownerAvatarUrl = repository.owner.avatarUrl
        self.cachedAt = Date()
    }

    func toDomain() -> Repository {
        Repository(
            id: id,
            name: name,
            nameWithOwner: nameWithOwner,
            description: repositoryDescription,
            url: url,
            stargazerCount: stargazerCount,
            forkCount: forkCount,
            primaryLanguage: primaryLanguageName.map { Language(name: $0, color: primaryLanguageColor) },
            languages: nil,
            updatedAt: updatedAt,
            pushedAt: pushedAt,
            createdAt: nil,
            isPrivate: isPrivate,
            isFork: isFork,
            owner: RepositoryOwner(login: ownerLogin, avatarUrl: ownerAvatarUrl),
            watchers: nil,
            issues: nil,
            pullRequests: nil,
            defaultBranchRef: nil,
            refs: nil,
            collaborators: nil
        )
    }
}
