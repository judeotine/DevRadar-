import Foundation
import SwiftUI

enum RepositoriesState: Equatable {
    case loading
    case loaded([Repository])
    case error(String)
    
    static func == (lhs: RepositoriesState, rhs: RepositoriesState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsRepos), .loaded(let rhsRepos)):
            return lhsRepos.count == rhsRepos.count && lhsRepos.map(\.id) == rhsRepos.map(\.id)
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

@Observable
final class RepositoriesViewModel {
    private(set) var state: RepositoriesState = .loading
    private var hasLoaded = false
    
    let repository: GitHubRepositoryProtocol
    
    init(repository: GitHubRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() async {
        if hasLoaded, case .loaded = state {
            return
        }
        
        state = .loading
        
        do {
            let repositories = try await repository.fetchRepositories(forceRefresh: false)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(repositories)
            }
        } catch {
            withAnimation {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func refresh() async {
        state = .loading
        
        do {
            let repositories = try await repository.fetchRepositories(forceRefresh: true)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(repositories)
            }
        } catch {
            withAnimation {
                state = .error(error.localizedDescription)
            }
        }
    }
}

