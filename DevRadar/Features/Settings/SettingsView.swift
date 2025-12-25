import SwiftUI
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @Bindable var authManager: AuthenticationManager
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled = true
    @AppStorage("themePreference") private var themePreference: String = "system"
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Text("Settings")
                    .font(Typography.title())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Spacing.md) {
                    SettingsSection(title: "Appearance") {
                        ThemePicker(themePreference: $themePreference)
                    }
                    
                    SettingsSection(title: "Notifications") {
                        NotificationToggle(
                            isOn: $pushNotificationsEnabled,
                            notificationManager: notificationManager
                        )
                    }
                    
                    SettingsSection(title: "Preferences") {
                        VStack(spacing: Spacing.sm) {
                            ToggleRow(
                                title: "Haptic Feedback",
                                icon: "hand.tap.fill",
                                isOn: $hapticFeedbackEnabled
                            )
                            
                            ToggleRow(
                                title: "Auto Refresh",
                                icon: "arrow.clockwise",
                                isOn: $autoRefreshEnabled
                            )
                        }
                    }
                    
                    SettingsSection(title: "Account") {
                        SignOutButton {
                            authManager.signOut()
                        }
                    }
                    
                    SettingsSection(title: "About") {
                        GitHubRepoLink()
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .background(theme.background)
    }
    
}

private struct NotificationToggle: View {
    @Environment(\.theme) private var theme
    @Binding var isOn: Bool
    @ObservedObject var notificationManager: NotificationManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Label("Push Notifications", systemImage: "bell.fill")
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .onChange(of: isOn) { oldValue, newValue in
                        Task {
                            await handleToggleChange(newValue)
                        }
                    }
            }
            .padding(Spacing.md)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if notificationManager.authorizationStatus == .denied {
                Text("Notifications are disabled. Enable them in Settings.")
                    .font(Typography.caption())
                    .foregroundStyle(theme.error)
                    .responsiveText()
                    .padding(.horizontal, Spacing.md)
            } else if notificationManager.authorizationStatus == .authorized {
                Text("Notifications enabled")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
                    .padding(.horizontal, Spacing.md)
            }
        }
        .alert("Notification Permission", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleToggleChange(_ enabled: Bool) async {
        if enabled {
            do {
                let granted = try await notificationManager.requestAuthorization()
                if !granted {
                    await MainActor.run {
                        isOn = false
                        alertMessage = "Notification permission was denied. Please enable it in Settings."
                        showingAlert = true
                    }
                } else {
                    // Test notification
                    notificationManager.scheduleLocalNotification(
                        title: "Notifications Enabled",
                        body: "You'll now receive push notifications from DevRadar"
                    )
                }
            } catch {
                await MainActor.run {
                    isOn = false
                    alertMessage = "Failed to request notification permission: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}

private struct SignOutButton: View {
    @Environment(\.theme) private var theme
    let action: () -> Void
    @State private var showConfirmation = false
    
    var body: some View {
        Button(action: {
            showConfirmation = true
        }) {
            HStack {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(Typography.body())
                    .foregroundStyle(theme.error)
                    .responsiveText()
                Spacer()
            }
            .padding(Spacing.md)
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(.plain)
        .confirmationDialog(
            "Sign Out",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                action()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

private struct ThemePicker: View {
    @Environment(\.theme) private var theme
    @Binding var themePreference: String
    
    var body: some View {
        HStack {
            Label("Appearance", systemImage: "paintbrush.fill")
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            Spacer()
            
            Picker("Theme", selection: $themePreference) {
                Label("System", systemImage: "circle.lefthalf.filled")
                    .tag("system")
                Label("Light", systemImage: "sun.max.fill")
                    .tag("light")
                Label("Dark", systemImage: "moon.fill")
                    .tag("dark")
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ToggleRow: View {
    @Environment(\.theme) private var theme
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct SettingsRow: View {
    @Environment(\.theme) private var theme
    let title: String
    let icon: String
    var subtitle: String? = nil
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(Typography.body())
                .foregroundStyle(color)
                .responsiveText()
            
            Spacer()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(theme.tertiaryText)
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct SettingsSection<Content: View>: View {
    @Environment(\.theme) private var theme

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()

            content
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

private struct GitHubRepoLink: View {
    @Environment(\.theme) private var theme
    
    private let repoURL = "https://github.com/judeotine/DevRadar"
    
    var body: some View {
        Link(destination: URL(string: repoURL)!) {
            HStack {
                Label("View on GitHub", systemImage: "arrow.up.right.square")
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.secondaryText)
            }
            .padding(Spacing.md)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
