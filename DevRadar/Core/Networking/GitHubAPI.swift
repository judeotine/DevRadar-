import Foundation

struct GitHubAPIConfiguration {
    let baseURL: String
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let scopes: [String]

    static let production = GitHubAPIConfiguration(
        baseURL: "https://api.github.com",
        clientID: GitHubConfig.clientID,
        clientSecret: GitHubConfig.clientSecret,
        redirectURI: "devradar://oauth-callback",
        scopes: ["repo", "read:user", "user:email", "notifications"]
    )
}

final class GitHubAPI {
    private let session: URLSession
    private let configuration: GitHubAPIConfiguration
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(
        configuration: GitHubAPIConfiguration = .production,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .iso8601

        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        self.jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func executeGraphQL<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil,
        token: String
    ) async throws -> T {
        guard let url = URL(string: "\(configuration.baseURL)/graphql") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "query": query,
            "variables": variables ?? [:]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await execute(request: request)
    }

    func executeREST<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        token: String
    ) async throws -> T {
        guard let url = URL(string: "\(configuration.baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try jsonEncoder.encode(body)
        }

        return try await execute(request: request)
    }

    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
        }

        try handleHTTPErrors(response: httpResponse, data: data)

        guard !data.isEmpty else {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            throw NetworkError.noData
        }

        do {
            if T.self == GraphQLResponse<ViewerResponse>.self {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("GraphQL Response (first 2000 chars):")
                    print(String(jsonString.prefix(2000)))
                }
            }
            
            return try jsonDecoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            var errorMessage = "Failed to decode \(T.self)"
            
            switch decodingError {
            case .keyNotFound(let key, let context):
                errorMessage = "Missing key '\(key.stringValue)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch for '\(type)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found for '\(type)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). \(context.debugDescription)"
            @unknown default:
                errorMessage = decodingError.localizedDescription
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Full Response JSON:")
                print(jsonString)
            }
            
            print("Decoding Error Details: \(errorMessage)")
            
            throw NetworkError.decodingFailed(NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    private func handleHTTPErrors(response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            if let resetTime = response.value(forHTTPHeaderField: "X-RateLimit-Reset"),
                let timestamp = TimeInterval(resetTime) {
                let resetDate = Date(timeIntervalSince1970: timestamp)
                throw NetworkError.rateLimitExceeded(resetAt: resetDate)
            }
            throw NetworkError.rateLimitExceeded(resetAt: nil)
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            let message = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data).message
            throw NetworkError.httpError(statusCode: response.statusCode, message: message)
        }
    }
}

struct EmptyResponse: Decodable {}

struct GitHubErrorResponse: Decodable {
    let message: String
    let documentationUrl: String?
}
