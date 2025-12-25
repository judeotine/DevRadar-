import SwiftUI

struct GitHubStatsCard: View {
    @Environment(\.theme) private var theme
    let data: DashboardData
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(theme.primary)
                
                Text("Your GitHub Stats")
                    .font(Typography.headline())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                
                Spacer()
            }
            
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.sm) {
                    StatItem(
                        icon: "flame.fill",
                        value: "\(data.currentStreak)",
                        label: "Day Streak",
                        color: .orange
                    )
                    
                    StatItem(
                        icon: "arrow.triangle.branch",
                        value: "\(data.openPRCount)",
                        label: "Open PRs",
                        color: .blue
                    )
                    
                    StatItem(
                        icon: "eye.fill",
                        value: "\(data.pendingReviewCount)",
                        label: "Reviews",
                        color: .purple
                    )
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(theme.border.opacity(0.5))
                
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Total Contributions")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .responsiveText()
                        
                        Text("\(data.totalContributions)")
                            .font(Typography.title())
                            .foregroundStyle(theme.text)
                            .responsiveText()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("Repositories")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .responsiveText()
                        
                        Text("\(data.repositories.count)")
                            .font(Typography.title())
                            .foregroundStyle(theme.text)
                            .responsiveText()
                    }
                }
            }
        }
        .padding(Spacing.xl)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
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
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(color)
            
            Text(value)
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

