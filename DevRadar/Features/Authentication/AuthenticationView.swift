import SwiftUI

struct AuthenticationView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                Text("DevRadar")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack {
                Spacer()
                
                GetStartedModal(viewModel: viewModel)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct GetStartedModal: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Get Started")
                        .font(Typography.display())
                        .foregroundStyle(theme.text)
                        .responsiveText()
                    
                    Text("Connect your GitHub account to track contributions, monitor pull requests and visualize your development activity.")
                        .font(Typography.body())
                        .foregroundStyle(theme.secondaryText)
                        .responsiveText()
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
                
                VStack(spacing: Spacing.md) {
                    Button(action: { 
                        Task { await viewModel.signIn() } 
                    }) {
                        Text("Continue with GitHub")
                            .font(Typography.headline())
                            .responsiveText()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(
                                LinearGradient(
                                    colors: [
                                        theme.primary,
                                        theme.primary.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: theme.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)
                    
                    if viewModel.isLoading {
                        HStack(spacing: Spacing.sm) {
                            ProgressView()
                                .tint(.white)
                            Text("Connecting...")
                                .font(Typography.caption())
                                .foregroundStyle(theme.secondaryText)
                        }
                        .padding(.top, Spacing.xs)
                    }
                    
                    if let error = viewModel.error {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(theme.error)
                            
                            Text(error.localizedDescription)
                                .font(Typography.caption())
                                .foregroundStyle(theme.error)
                                .multilineTextAlignment(.leading)
                                .responsiveText()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.md)
                        .background(theme.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, Spacing.sm)
                    }
                }
                .padding(.top, Spacing.sm)
            }
            .padding(Spacing.xl)
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 32,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 32
                )
            )
            .fill(.regularMaterial)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 32,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: 32
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                            .white.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20, y: -5)
            .ignoresSafeArea(edges: .bottom)
        )
        .padding(.top, Spacing.xxxl)
    }
}

@Observable
final class AuthenticationViewModel {
    private(set) var isLoading = false
    private(set) var error: Error?

    private let authManager: AuthenticationManager

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    func signIn() async {
        isLoading = true
        error = nil

        do {
            try await authManager.signIn()
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
