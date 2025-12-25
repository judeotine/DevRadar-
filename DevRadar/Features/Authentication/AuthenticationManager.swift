import Foundation
import AuthenticationServices

enum AuthenticationError: Error, LocalizedError {
    case cancelled
    case invalidState
    case noCode
    case tokenExchangeFailed
    case noAccount

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Authentication was cancelled"
        case .invalidState:
            return "Invalid authentication state. Please try again"
        case .noCode:
            return "No authorization code received"
        case .tokenExchangeFailed:
            return "Failed to exchange code for access token"
        case .noAccount:
            return "No account found. Please sign in"
        }
    }
}

@Observable
final class AuthenticationManager: NSObject {
    private(set) var isAuthenticated = false
    private(set) var currentAccount: String?
    private(set) var error: Error?

    private let keychainManager: KeychainManager
    private let configuration: GitHubAPIConfiguration
    private var authenticationSession: ASWebAuthenticationSession?
    private var expectedState: String?

    init(
        keychainManager: KeychainManager = .shared,
        configuration: GitHubAPIConfiguration = .production
    ) {
        self.keychainManager = keychainManager
        self.configuration = configuration
        super.init()
        checkAuthenticationStatus()
    }

    func signIn() async throws {
        let state = generateState()
        expectedState = state

        let scope = configuration.scopes.joined(separator: " ")
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: state)
        ]

        guard let authURL = components?.url else {
            throw AuthenticationError.invalidState
        }

        let callbackURLScheme = "devradar"

        return try await withCheckedThrowingContinuation { continuation in
            authenticationSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackURLScheme
            ) { [weak self] callbackURL, error in
                guard let self = self else { return }

                if let error = error {
                    if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
                        continuation.resume(throwing: AuthenticationError.cancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }

                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: AuthenticationError.noCode)
                    return
                }

                Task {
                    do {
                        try await self.handleCallback(url: callbackURL)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            authenticationSession?.presentationContextProvider = self
            authenticationSession?.prefersEphemeralWebBrowserSession = false
            authenticationSession?.start()
        }
    }

    func signOut() {
        if let account = currentAccount {
            try? keychainManager.delete(for: account)
        }
        currentAccount = nil
        isAuthenticated = false
    }

    func switchAccount(to account: String) {
        currentAccount = account
        isAuthenticated = true
    }

    func listAccounts() -> [String] {
        (try? keychainManager.listAccounts()) ?? []
    }

    private func handleCallback(url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
            throw AuthenticationError.noCode
        }

        guard let state = queryItems.first(where: { $0.name == "state" })?.value,
            state == expectedState else {
            throw AuthenticationError.invalidState
        }

        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            throw AuthenticationError.noCode
        }

        let token = try await exchangeCodeForToken(code: code)
        let username = try await fetchUsername(token: token)

        try keychainManager.save(token: token, for: username)
        currentAccount = username
        isAuthenticated = true
    }

    private func exchangeCodeForToken(code: String) async throws -> String {
        var components = URLComponents(string: "https://github.com/login/oauth/access_token")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "client_secret", value: configuration.clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI)
        ]

        guard let url = components?.url else {
            throw AuthenticationError.tokenExchangeFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)

        guard let token = response.accessToken else {
            throw AuthenticationError.tokenExchangeFailed
        }

        return token
    }

    private func fetchUsername(token: String) async throws -> String {
        guard let url = URL(string: "\(configuration.baseURL)/user") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let user = try JSONDecoder().decode(BasicUser.self, from: data)

        return user.login
    }

    private func checkAuthenticationStatus() {
        let accounts = listAccounts()
        if let firstAccount = accounts.first {
            currentAccount = firstAccount
            isAuthenticated = true
        }
    }

    private func generateState() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<32).map { _ in letters.randomElement()! })
    }
}

extension AuthenticationManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

struct TokenResponse: Decodable {
    let accessToken: String?
    let tokenType: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}

struct BasicUser: Decodable {
    let login: String
    let id: Int
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
}
