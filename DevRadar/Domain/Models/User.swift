import Foundation

struct User: Codable, Identifiable {
    let id: String
    let login: String
    let name: String?
    let email: String?
    let avatarUrl: String
    let bio: String?
    let company: String?
    let location: String?
    let url: String
    let status: UserStatus?
    let contributionsCollection: ContributionsCollection?

    var displayName: String {
        name ?? login
    }
}

struct UserStatus: Codable {
    let message: String?
    let emoji: String?
    
    var displayText: String {
        if let message = message, !message.isEmpty {
            return message
        }
        return "Active"
    }
}

struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar?
    let totalCommitContributions: Int
    let totalIssueContributions: Int
    let totalPullRequestContributions: Int
    let totalPullRequestReviewContributions: Int
    let commitContributionsByRepository: [RepositoryContribution]?

    var totalContributions: Int {
        totalCommitContributions +
        totalIssueContributions +
        totalPullRequestContributions +
        totalPullRequestReviewContributions
    }
    
    var safeContributionCalendar: ContributionCalendar {
        contributionCalendar ?? ContributionCalendar(totalContributions: 0, weeks: [])
    }
}

struct ContributionCalendar: Codable {
    let totalContributions: Int
    let weeks: [ContributionWeek]?
    
    init(totalContributions: Int, weeks: [ContributionWeek]?) {
        self.totalContributions = totalContributions
        self.weeks = weeks
    }

    var allDays: [ContributionDay] {
        (weeks ?? []).flatMap { $0.contributionDays }
    }

    func currentStreak() -> Int {
        let sortedDays = allDays.sorted { $0.date > $1.date }
        var streak = 0

        for day in sortedDays {
            if day.contributionCount > 0 {
                streak += 1
            } else if streak > 0 {
                break
            }
        }

        return streak
    }

    func longestStreak() -> Int {
        var maxStreak = 0
        var currentStreak = 0

        for day in allDays {
            if day.contributionCount > 0 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }
}

struct ContributionWeek: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable {
    let contributionCount: Int
    let date: String
    let color: String?

    var parsedDate: Date? {
        ISO8601DateFormatter().date(from: date)
    }
}

struct RepositoryContribution: Codable {
    let repository: RepositoryReference
    let contributions: ContributionConnection

    struct ContributionConnection: Codable {
        let nodes: [Contribution]
    }

    struct Contribution: Codable {
        let occurredAt: Date
        let commitCount: Int
    }
}

struct RepositoryReference: Codable {
    let name: String
    let nameWithOwner: String
    let owner: Owner

    struct Owner: Codable {
        let login: String
    }
}
