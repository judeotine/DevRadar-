import Foundation
import SwiftUI

enum ActivityState {
    case loading
    case loaded(User)
    case error(Error)
}

@Observable
final class ActivityViewModel {
    private(set) var state: ActivityState = .loading
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
            let user = try await repository.fetchUser(forceRefresh: false)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(user)
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
            let user = try await repository.fetchUser(forceRefresh: true)
            hasLoaded = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state = .loaded(user)
            }
        } catch {
            withAnimation {
                state = .error(error)
            }
        }
    }
}

