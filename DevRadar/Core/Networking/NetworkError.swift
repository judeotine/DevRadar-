import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case httpError(statusCode: Int, message: String?)
    case unauthorized
    case rateLimitExceeded(resetAt: Date?)
    case notFound
    case serverError
    case noConnection
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .noData:
            return "No data received from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error with status code \(statusCode)"
        case .unauthorized:
            return "Authentication required. Please sign in again"
        case .rateLimitExceeded(let resetAt):
            if let resetAt = resetAt {
                let formatter = RelativeDateTimeFormatter()
                let timeString = formatter.localizedString(for: resetAt, relativeTo: Date())
                return "Rate limit exceeded. Resets \(timeString)"
            }
            return "Rate limit exceeded. Please try again later"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later"
        case .noConnection:
            return "No internet connection. Please check your network"
        case .timeout:
            return "Request timed out. Please try again"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
