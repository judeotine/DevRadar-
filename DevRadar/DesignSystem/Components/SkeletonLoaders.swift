import SwiftUI

struct DashboardSkeleton: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SkeletonRectangle(width: 180, height: 20)
                    SkeletonProfileHeader()
                }
                
                SkeletonContributionGraph()
                
                HStack(spacing: 0) {
                    ForEach(0..<2) { _ in
                        VStack(spacing: Spacing.xs) {
                            SkeletonRectangle(width: 80, height: 16)
                            SkeletonRectangle(width: nil, height: 2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                HStack(spacing: Spacing.md) {
                    ForEach(0..<2) { _ in
                        SkeletonInfoCard()
                            .frame(maxWidth: .infinity)
                    }
                }
                
                SkeletonStatsCard()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(theme.background)
    }
}

private struct SkeletonProfileHeader: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            SkeletonCircle(size: 80)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonRectangle(width: 120, height: 16)
                SkeletonRectangle(width: 100, height: 12)
                SkeletonRectangle(width: 80, height: 24, cornerRadius: 12)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
    }
}

private struct SkeletonContributionGraph: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SkeletonRectangle(width: 200, height: 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 0) {
                        SkeletonRectangle(width: 30, height: 10)
                        HStack(spacing: 0) {
                            ForEach(0..<12) { _ in
                                SkeletonRectangle(width: 14, height: 10)
                            }
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 3) {
                        VStack(spacing: 3) {
                            ForEach(0..<7) { _ in
                                SkeletonRectangle(width: 11, height: 11, cornerRadius: 2)
                            }
                        }
                        .frame(width: 30)
                        
                        HStack(alignment: .top, spacing: 3) {
                            ForEach(0..<52) { _ in
                                VStack(spacing: 3) {
                                    ForEach(0..<7) { _ in
                                        SkeletonRectangle(width: 11, height: 11, cornerRadius: 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            HStack {
                SkeletonRectangle(width: 150, height: 12)
                Spacer()
                HStack(spacing: 4) {
                    SkeletonRectangle(width: 30, height: 12)
                    ForEach(0..<5) { _ in
                        SkeletonRectangle(width: 11, height: 11, cornerRadius: 2)
                    }
                    SkeletonRectangle(width: 30, height: 12)
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

private struct SkeletonInfoCard: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            SkeletonCircle(size: 24)
            SkeletonRectangle(width: 60, height: 12)
            SkeletonRectangle(width: 40, height: 16)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}

private struct SkeletonStatsCard: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SkeletonRectangle(width: 120, height: 18)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.md
            ) {
                ForEach(0..<4) { _ in
                    HStack(spacing: Spacing.sm) {
                        SkeletonCircle(size: 16)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            SkeletonRectangle(width: 60, height: 10)
                            SkeletonRectangle(width: 40, height: 14)
                        }
                    }
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

// MARK: - Repositories Skeleton
struct RepositoriesSkeleton: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar skeleton
            SkeletonRectangle(width: nil, height: 44, cornerRadius: 16)
                .padding(Spacing.lg)
            
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: Spacing.md
                ) {
                    ForEach(0..<6) { _ in
                        SkeletonRepositoryCard()
                    }
                }
                .padding(Spacing.lg)
            }
            .background(theme.background)
        }
    }
}

private struct SkeletonRepositoryCard: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SkeletonCircle(size: 10)
                SkeletonRectangle(width: 60, height: 10)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonRectangle(width: nil, height: 14)
                SkeletonRectangle(width: nil, height: 10)
            }
            
            HStack {
                SkeletonRectangle(width: 40, height: 10)
                SkeletonRectangle(width: 40, height: 10)
                Spacer()
                SkeletonRectangle(width: 50, height: 10)
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

// MARK: - Pull Requests Skeleton
struct PullRequestsSkeleton: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SkeletonRectangle(width: 120, height: 24)
                Spacer()
            }
            .padding(Spacing.lg)
            .background(theme.background)
            
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(0..<5) { _ in
                        SkeletonPRRow()
                    }
                }
                .padding(Spacing.lg)
            }
            .background(theme.background)
        }
    }
}

private struct SkeletonPRRow: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            SkeletonCircle(size: 40)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonRectangle(width: 200, height: 14)
                SkeletonRectangle(width: 150, height: 12)
                HStack {
                    SkeletonRectangle(width: 60, height: 20, cornerRadius: 10)
                    SkeletonRectangle(width: 80, height: 10)
                }
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Activity Skeleton
struct ActivitySkeleton: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                SkeletonContributionGraph()
                
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SkeletonRectangle(width: 180, height: 20)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: Spacing.md
                    ) {
                        ForEach(0..<6) { _ in
                            SkeletonInfoCard()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SkeletonRectangle(width: 150, height: 20)
                    
                    VStack(spacing: Spacing.md) {
                        ForEach(0..<4) { _ in
                            HStack {
                                SkeletonCircle(size: 20)
                                SkeletonRectangle(width: 100, height: 14)
                                Spacer()
                                SkeletonRectangle(width: 50, height: 16)
                            }
                            .padding(Spacing.md)
                            .background(theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        }
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .background(theme.background)
    }
}

// MARK: - Repository Detail Skeleton
struct RepositoryDetailSkeleton: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header skeleton
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        SkeletonRectangle(width: 150, height: 20)
                        SkeletonRectangle(width: 60, height: 20, cornerRadius: 10)
                    }
                    SkeletonRectangle(width: 200, height: 14)
                    SkeletonRectangle(width: nil, height: 60)
                }
                .padding(Spacing.lg)
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Stats bar skeleton
                HStack(spacing: Spacing.lg) {
                    ForEach(0..<4) { _ in
                        VStack {
                            SkeletonCircle(size: 20)
                            SkeletonRectangle(width: 40, height: 12)
                            SkeletonRectangle(width: 50, height: 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Spacing.lg)
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Language breakdown skeleton
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SkeletonRectangle(width: 100, height: 18)
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                SkeletonRectangle(width: 16, height: 16, cornerRadius: 3)
                                SkeletonRectangle(width: 80, height: 14)
                                Spacer()
                                SkeletonRectangle(width: 40, height: 14)
                            }
                            SkeletonRectangle(width: nil, height: 8, cornerRadius: 4)
                        }
                        .padding(Spacing.md)
                        .background(theme.tertiaryBackground.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                }
                .padding(Spacing.lg)
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            }
            .padding(Spacing.lg)
        }
        .background(theme.background)
    }
}

