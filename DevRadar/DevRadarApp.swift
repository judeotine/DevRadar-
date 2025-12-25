//
//  DevRadarApp.swift
//  DevRadar
//
//  Created by Jude Otine on 25/12/2025.
//

import SwiftUI
import SwiftData
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

@main
struct DevRadarApp: App {
    @State private var authManager = AuthenticationManager()
    @AppStorage("themePreference") private var themePreference: String = "system"

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CachedUser.self,
            CachedRepository.self,
            CachedPullRequest.self,
            CachedContributionCalendar.self,
            CachedContributionWeek.self,
            CachedContributionDay.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ThemeWrapper {
                RootView(authManager: authManager)
                    .modelContainer(sharedModelContainer)
                    .onAppear {
                        if UserDefaults.standard.bool(forKey: "pushNotificationsEnabled") {
                            Task {
                                await requestNotificationPermissionIfNeeded()
                            }
                        }
                    }
            }
        }
    }
    
    private func requestNotificationPermissionIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                if granted {
                    #if canImport(UIKit)
                    await UIApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            } catch {
                print("Failed to request notification permission: \(error)")
            }
        }
    }
}

private struct ThemeWrapper<Content: View>: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("themePreference") private var themePreference: String = "system"
    @ViewBuilder let content: Content
    
    private var effectiveColorScheme: ColorScheme {
        switch themePreference {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return systemColorScheme
        }
    }
    
    var body: some View {
        content
            .preferredColorScheme(effectiveColorScheme)
            .environment(\.theme, (effectiveColorScheme == .dark ? DarkTheme() : LightTheme()) as Theme)
    }
}

struct RootView: View {
    @Bindable var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if authManager.isAuthenticated, let account = authManager.currentAccount {
                MainAppView(
                    selectedTab: $selectedTab,
                    repository: GitHubRepository(
                        api: GitHubAPI(),
                        modelContext: modelContext,
                        currentAccount: account
                    ),
                    authManager: authManager
                )
            } else {
                AuthenticationView(
                    viewModel: AuthenticationViewModel(authManager: authManager)
                )
            }
        }
    }
}

struct MainAppView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTab: AppTab
    let repository: GitHubRepositoryProtocol
    @Bindable var authManager: AuthenticationManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabContentView(
                    selectedTab: $selectedTab,
                    repository: repository,
                    authManager: authManager
                )
                .padding(.bottom, 80)
                
                VStack {
                    Spacer()
                    NavigationMenu(selectedTab: $selectedTab)
                }
            }
        }
    }
}

struct TabContentView: View {
    @Binding var selectedTab: AppTab
    let repository: GitHubRepositoryProtocol
    @Bindable var authManager: AuthenticationManager
    @State private var dashboardViewModel: DashboardViewModel?
    @State private var repositoriesViewModel: RepositoriesViewModel?
    @State private var pullRequestsViewModel: PullRequestsViewModel?
    @State private var activityViewModel: ActivityViewModel?
    
    init(selectedTab: Binding<AppTab>, repository: GitHubRepositoryProtocol, authManager: AuthenticationManager) {
        self._selectedTab = selectedTab
        self.repository = repository
        self.authManager = authManager
        _dashboardViewModel = State(initialValue: DashboardViewModel(repository: repository))
        _repositoriesViewModel = State(initialValue: RepositoriesViewModel(repository: repository))
        _pullRequestsViewModel = State(initialValue: PullRequestsViewModel(repository: repository))
        _activityViewModel = State(initialValue: ActivityViewModel(repository: repository))
    }

    var body: some View {
        Group {
            switch selectedTab {
            case .dashboard:
                DashboardView(
                    viewModel: dashboardViewModel ?? DashboardViewModel(repository: repository),
                    authManager: authManager,
                    selectedAppTab: $selectedTab
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            case .repositories:
                RepositoriesView(viewModel: repositoriesViewModel ?? RepositoriesViewModel(repository: repository))
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            case .pullRequests:
                PullRequestsView(viewModel: pullRequestsViewModel ?? PullRequestsViewModel(repository: repository))
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            case .activity:
                ActivityView(viewModel: activityViewModel ?? ActivityViewModel(repository: repository))
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            case .settings:
                SettingsView(authManager: authManager)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedTab)
    }
}

