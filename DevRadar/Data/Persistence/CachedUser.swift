import Foundation
import SwiftData

@Model
final class CachedUser {
    @Attribute(.unique) var login: String
    var name: String?
    var email: String?
    var avatarUrl: String
    var bio: String?
    var company: String?
    var location: String?
    var url: String
    var totalContributions: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalCommits: Int
    var totalPRs: Int
    var totalIssues: Int
    var totalReviews: Int
    var cachedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CachedRepository.user)
    var repositories: [CachedRepository]?

    @Relationship(deleteRule: .cascade, inverse: \CachedPullRequest.user)
    var pullRequests: [CachedPullRequest]?
    
    @Relationship(deleteRule: .cascade)
    var contributionCalendar: CachedContributionCalendar?

    init(
        login: String,
        name: String? = nil,
        email: String? = nil,
        avatarUrl: String,
        bio: String? = nil,
        company: String? = nil,
        location: String? = nil,
        url: String,
        totalContributions: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalCommits: Int = 0,
        totalPRs: Int = 0,
        totalIssues: Int = 0,
        totalReviews: Int = 0,
        cachedAt: Date = Date()
    ) {
        self.login = login
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.company = company
        self.location = location
        self.url = url
        self.totalContributions = totalContributions
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalCommits = totalCommits
        self.totalPRs = totalPRs
        self.totalIssues = totalIssues
        self.totalReviews = totalReviews
        self.cachedAt = cachedAt
    }

    var isFresh: Bool {
        Date().timeIntervalSince(cachedAt) < 900
    }

    func update(from user: User) {
        self.name = user.name
        self.email = user.email
        self.avatarUrl = user.avatarUrl
        self.bio = user.bio
        self.company = user.company
        self.location = user.location
        self.url = user.url

        if let contributions = user.contributionsCollection {
            let calendar = contributions.safeContributionCalendar
            self.totalContributions = calendar.totalContributions
            self.currentStreak = calendar.currentStreak()
            self.longestStreak = calendar.longestStreak()
            self.totalCommits = contributions.totalCommitContributions
            self.totalPRs = contributions.totalPullRequestContributions
            self.totalIssues = contributions.totalIssueContributions
            self.totalReviews = contributions.totalPullRequestReviewContributions
            
            self.contributionCalendar = CachedContributionCalendar.fromDomain(calendar)
        }

        self.cachedAt = Date()
    }
}
