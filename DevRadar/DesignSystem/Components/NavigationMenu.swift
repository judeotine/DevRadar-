import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct NavigationMenu: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    
                    #if canImport(UIKit)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    #endif
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? theme.primary : theme.secondaryText)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }
}

enum AppTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case repositories = "Repositories"
    case pullRequests = "Pull Requests"
    case activity = "Activity"
    case settings = "Settings"
    
    var title: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .dashboard:
            return "chart.xyaxis.line"
        case .repositories:
            return "folder.fill"
        case .pullRequests:
            return "arrow.triangle.branch"
        case .activity:
            return "flame.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

