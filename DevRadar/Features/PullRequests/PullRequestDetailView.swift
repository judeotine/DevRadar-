import SwiftUI

struct PullRequestDetailView: View {
    @Environment(\.theme) private var theme
    let pullRequest: PullRequest
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                PRHeader(pr: pullRequest)
                
                PRStats(pr: pullRequest)
                
                PRInfo(pr: pullRequest)
                
                if let reviews = pullRequest.reviews, !reviews.nodes.isEmpty {
                    ReviewsSection(reviews: reviews.nodes)
                }
            }
            .padding(Spacing.lg)
        }
        .background(theme.background)
        .navigationTitle("PR #\(pullRequest.number)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PRHeader: View {
    @Environment(\.theme) private var theme
    let pr: PullRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(pr.title)
                .font(Typography.title())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            HStack(spacing: Spacing.md) {
                StatusBadge(
                    text: pr.statusText,
                    color: Color(hex: pr.statusColor)
                )
                
                if pr.isDraft {
                    StatusBadge(text: "Draft", color: .gray)
                }
            }
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}

private struct PRStats: View {
    @Environment(\.theme) private var theme
    let pr: PullRequest
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            StatItem(
                icon: "plus.circle.fill",
                value: "\(pr.additions)",
                label: "Additions",
                color: .green
            )
            
            StatItem(
                icon: "minus.circle.fill",
                value: "\(pr.deletions)",
                label: "Deletions",
                color: .red
            )
            
            StatItem(
                icon: "arrow.left.arrow.right",
                value: "\(pr.changeCount)",
                label: "Changes",
                color: .blue
            )
        }
    }
}

private struct StatItem: View {
    @Environment(\.theme) private var theme
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            Text(value)
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            Text(label)
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

private struct PRInfo: View {
    @Environment(\.theme) private var theme
    let pr: PullRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Information")
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            InfoRow(label: "Repository", value: pr.repository.nameWithOwner)
            InfoRow(label: "Author", value: pr.author.login)
            InfoRow(label: "Created", value: pr.createdAt.formatted(date: .abbreviated, time: .shortened))
            InfoRow(label: "Updated", value: pr.updatedAt.formatted(date: .abbreviated, time: .shortened))
            
            if let mergedAt = pr.mergedAt {
                InfoRow(label: "Merged", value: mergedAt.formatted(date: .abbreviated, time: .shortened))
            }
            
            if let closedAt = pr.closedAt {
                InfoRow(label: "Closed", value: closedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}

private struct InfoRow: View {
    @Environment(\.theme) private var theme
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Typography.body())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
            
            Spacer()
            
            Text(value)
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
        }
    }
}

private struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(Typography.caption())
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(color)
            .clipShape(Capsule())
    }
}

private struct ReviewsSection: View {
    @Environment(\.theme) private var theme
    let reviews: [Review]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Reviews")
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            VStack(spacing: Spacing.sm) {
                ForEach(Array(reviews.enumerated()), id: \.offset) { _, review in
                    ReviewRow(review: review)
                }
            }
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}

private struct ReviewRow: View {
    @Environment(\.theme) private var theme
    let review: Review
    
    var body: some View {
        HStack {
            Text(review.author.login)
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            Spacer()
            
            StatusBadge(
                text: review.state.rawValue.capitalized,
                color: reviewColor(for: review.state)
            )
        }
        .padding(Spacing.sm)
        .background(theme.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
    
    private func reviewColor(for state: ReviewState) -> Color {
        switch state {
        case .approved:
            return .green
        case .changesRequested:
            return .red
        default:
            return .gray
        }
    }
}

