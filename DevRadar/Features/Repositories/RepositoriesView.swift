import SwiftUI

struct RepositoriesView: View {
    @Environment(\.theme) private var theme
    @Bindable var viewModel: RepositoriesViewModel
    @State private var filteredRepositories: [Repository] = []
    @State private var searchText: String = ""
    @State private var currentPage = 1
    @State private var hasAttemptedLoad = false
    private let itemsPerPage = 20
    
    private var repositories: [Repository] {
        if case .loaded(let repos) = viewModel.state {
            return repos
        }
        return []
    }
    
    init(viewModel: RepositoriesViewModel) {
        self.viewModel = viewModel
        _filteredRepositories = State(initialValue: [])
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    RepositoriesSkeleton()
                case .loaded:
                    if repositories.isEmpty {
                        EmptyStateView(
                            icon: "folder",
                            title: "No Repositories",
                            message: "You don't have any repositories yet."
                        )
                    } else {
                        VStack(spacing: 0) {
                            SearchBar(text: $searchText, placeholder: "Search repositories...")
                                .padding(Spacing.lg)
                            
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ],
                                        spacing: Spacing.md
                                    ) {
                                        ForEach(displayedRepositories) { repo in
                                            NavigationLink(value: repo) {
                                                RepositoryCard(repository: repo)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(Spacing.lg)
                                    .id("scrollTop")
                                }
                                .background(theme.background)
                                .refreshable {
                                    SoundManager.shared.playRefreshSound()
                                    await viewModel.refresh()
                                }
                                .onChange(of: currentPage) { _, _ in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo("scrollTop", anchor: .top)
                                    }
                                }
                            }
                            
                            if totalPages > 1 {
                                PaginationView(
                                    currentPage: $currentPage,
                                    totalPages: totalPages,
                                    totalItems: filteredRepositories.count,
                                    itemsPerPage: itemsPerPage
                                )
                                .padding(.vertical, Spacing.md)
                                .padding(.horizontal, Spacing.lg)
                            }
                        }
                    }
                case .error(let errorMessage):
                    ErrorView(error: NSError(domain: "RepositoriesError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])) {
                        Task { await viewModel.load() }
                    }
                }
            }
            .navigationDestination(for: Repository.self) { repo in
                RepositoryDetailView(
                    viewModel: RepositoryDetailViewModel(
                        repository: viewModel.repository,
                        owner: repo.owner.login,
                        name: repo.name
                    )
                )
            }
        }
        .task {
            guard !hasAttemptedLoad else { return }
            hasAttemptedLoad = true
            await viewModel.load()
        }
        .onChange(of: searchText) { _, _ in
            filterRepositories()
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .loaded(let repos) = newState {
                filteredRepositories = repos
            }
        }
    }
    
    private var displayedRepositories: [Repository] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, filteredRepositories.count)
        return Array(filteredRepositories[startIndex..<endIndex])
    }
    
    private var totalPages: Int {
        max(1, Int(ceil(Double(filteredRepositories.count) / Double(itemsPerPage))))
    }
    
    private func filterRepositories() {
        if searchText.isEmpty {
            filteredRepositories = repositories
        } else {
            let searchLower = searchText.lowercased()
            filteredRepositories = repositories.filter { repo in
                repo.name.lowercased().contains(searchLower) ||
                (repo.description?.lowercased().contains(searchLower) ?? false) ||
                repo.owner.login.lowercased().contains(searchLower)
            }
        }
        currentPage = 1
    }
}

private struct PaginationView: View {
    @Environment(\.theme) private var theme
    @Binding var currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    
    private var startItem: Int {
        (currentPage - 1) * itemsPerPage + 1
    }
    
    private var endItem: Int {
        min(currentPage * itemsPerPage, totalItems)
    }
    
    private var visiblePages: [Int] {
        let maxVisible = 5
        var pages: [Int] = []
        
        if totalPages <= maxVisible {
            pages = Array(1...totalPages)
        } else {
            if currentPage <= 3 {
                pages = Array(1...5)
            } else if currentPage >= totalPages - 2 {
                pages = Array(totalPages - 4...totalPages)
            } else {
                pages = Array(currentPage - 2...currentPage + 2)
            }
        }
        
        return pages
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Showing \(startItem)-\(endItem) of \(totalItems)")
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
            
            HStack(spacing: Spacing.sm) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if currentPage > 1 {
                            currentPage -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(currentPage > 1 ? theme.text : theme.secondaryText)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .disabled(currentPage <= 1)
                
                if currentPage > 3 && totalPages > 5 {
                    PageButton(page: 1, currentPage: $currentPage, totalPages: totalPages)
                    
                    if currentPage > 4 {
                        Text("...")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .frame(width: 24)
                    }
                }
                
                ForEach(visiblePages, id: \.self) { page in
                    PageButton(page: page, currentPage: $currentPage, totalPages: totalPages)
                }
                
                if currentPage < totalPages - 2 && totalPages > 5 {
                    if currentPage < totalPages - 3 {
                        Text("...")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .frame(width: 24)
                    }
                    
                    PageButton(page: totalPages, currentPage: $currentPage, totalPages: totalPages)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if currentPage < totalPages {
                            currentPage += 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(currentPage < totalPages ? theme.text : theme.secondaryText)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .disabled(currentPage >= totalPages)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(
                        colors: [.white.opacity(0.2), .white.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }
}

private struct PageButton: View {
    @Environment(\.theme) private var theme
    let page: Int
    @Binding var currentPage: Int
    let totalPages: Int
    
    private var isSelected: Bool {
        page == currentPage
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentPage = page
            }
        }) {
            Text("\(page)")
                .font(Typography.body())
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : theme.text)
                .frame(minWidth: 36, minHeight: 36)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.primary)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.clear)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}
