import Foundation
import Observation

@Observable
final class RepositoryDetailViewModel {
    enum State {
        case loading
        case loaded(Repository)
        case error(Error)
    }

    var state: State = .loading
    private let repository: GitHubRepositoryProtocol
    private let owner: String
    private let name: String

    init(repository: GitHubRepositoryProtocol, owner: String, name: String) {
        self.repository = repository
        self.owner = owner
        self.name = name
    }

    func load() async {
        state = .loading

        do {
            let repositoryDetail = try await repository.fetchRepositoryDetails(
                owner: owner,
                name: name
            )
            state = .loaded(repositoryDetail)
        } catch {
            state = .error(error)
        }
    }

    func refresh() async {
        do {
            let repositoryDetail = try await repository.fetchRepositoryDetails(
                owner: owner,
                name: name
            )
            state = .loaded(repositoryDetail)
        } catch {
            state = .error(error)
        }
    }
}

