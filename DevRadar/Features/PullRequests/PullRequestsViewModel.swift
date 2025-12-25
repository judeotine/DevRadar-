import Foundation
import SwiftUI

enum PullRequestsState {
    case loading
    case loaded([PullRequest])
    case error(Error)
}

@Observable
final class PullRequestsViewModel {
    private(set) var state: PullRequestsState = .loading
    private var hasLoaded = false
    
    private let repository: GitHubRepositoryProtocol
    
    init(repository: GitHubRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() async {
        if hasLoaded, case .loaded = state {
            return
        }
        
        state = .loading
        
        do {
            let pullRequests = try await repository.fetchPullRequests(forceRefresh: false)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(pullRequests)
            }
        } catch {
            withAnimation {
                state = .error(error)
            }
        }
    }
    
    func refresh() async {
        state = .loading
        
        do {
            let pullRequests = try await repository.fetchPullRequests(forceRefresh: true)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(pullRequests)
            }
        } catch {
            withAnimation {
                state = .error(error)
            }
        }
    }
}

