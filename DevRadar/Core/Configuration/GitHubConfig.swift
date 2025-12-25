import Foundation

enum GitHubConfig {
    static var clientID: String {
        if let id = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"], !id.isEmpty {
            return id
        }
        
        guard let path = Bundle.main.path(forResource: "GitHubConfig", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let id = plist["ClientID"] as? String, !id.isEmpty else {
            fatalError("GitHub Client ID not found. Please set GITHUB_CLIENT_ID environment variable or add GitHubConfig.plist to the project.")
        }
        
        return id
    }
    
    static var clientSecret: String {
        if let secret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"], !secret.isEmpty {
            return secret
        }
        
        guard let path = Bundle.main.path(forResource: "GitHubConfig", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let secret = plist["ClientSecret"] as? String, !secret.isEmpty else {
            fatalError("GitHub Client Secret not found. Please set GITHUB_CLIENT_SECRET environment variable or add GitHubConfig.plist to the project.")
        }
        
        return secret
    }
}

