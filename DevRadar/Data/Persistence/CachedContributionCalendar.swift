import Foundation
import SwiftData

@Model
final class CachedContributionCalendar {
    var totalContributions: Int
    var cachedAt: Date
    
    @Relationship(deleteRule: .cascade)
    var weeks: [CachedContributionWeek]?
    
    init(totalContributions: Int, weeks: [CachedContributionWeek]? = nil, cachedAt: Date = Date()) {
        self.totalContributions = totalContributions
        self.weeks = weeks
        self.cachedAt = cachedAt
    }
    
    func toDomain() -> ContributionCalendar {
        ContributionCalendar(
            totalContributions: totalContributions,
            weeks: weeks?.map { $0.toDomain() }
        )
    }
    
    static func fromDomain(_ calendar: ContributionCalendar) -> CachedContributionCalendar {
        let cached = CachedContributionCalendar(totalContributions: calendar.totalContributions)
        cached.weeks = calendar.weeks?.map { CachedContributionWeek.fromDomain($0, calendar: cached) }
        return cached
    }
}

@Model
final class CachedContributionWeek {
    var calendar: CachedContributionCalendar?
    
    @Relationship(deleteRule: .cascade)
    var contributionDays: [CachedContributionDay]?
    
    init(contributionDays: [CachedContributionDay]? = nil) {
        self.contributionDays = contributionDays
    }
    
    func toDomain() -> ContributionWeek {
        ContributionWeek(
            contributionDays: contributionDays?.map { $0.toDomain() } ?? []
        )
    }
    
    static func fromDomain(_ week: ContributionWeek, calendar: CachedContributionCalendar) -> CachedContributionWeek {
        let cached = CachedContributionWeek()
        cached.calendar = calendar
        cached.contributionDays = week.contributionDays.map { CachedContributionDay.fromDomain($0, week: cached) }
        return cached
    }
}

@Model
final class CachedContributionDay {
    var contributionCount: Int
    var date: String
    var color: String?
    
    var week: CachedContributionWeek?
    
    init(contributionCount: Int, date: String, color: String? = nil) {
        self.contributionCount = contributionCount
        self.date = date
        self.color = color
    }
    
    func toDomain() -> ContributionDay {
        ContributionDay(
            contributionCount: contributionCount,
            date: date,
            color: color
        )
    }
    
    static func fromDomain(_ day: ContributionDay, week: CachedContributionWeek) -> CachedContributionDay {
        let cached = CachedContributionDay(
            contributionCount: day.contributionCount,
            date: day.date,
            color: day.color
        )
        cached.week = week
        return cached
    }
}

