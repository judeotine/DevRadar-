# DevRadar

A professional-grade GitHub activity dashboard for macOS and iOS. Track contributions, monitor pull requests and visualize your development activity with a native, polished interface.

## Features

- **OAuth Authentication**: Secure GitHub OAuth 2.0 flow with Keychain storage
- **Real-time Dashboard**: Live GitHub activity tracking with contribution stats
- **Smart Caching**: SwiftData-powered offline support with 15-minute TTL
- **Pull Request Management**: Monitor PRs, review requests, and status changes
- **Repository Insights**: Browse repositories with language breakdowns and stats
- **Native Design**: Follows platform conventions with pixel-perfect UI
- **Dark Mode**: Full support for light and dark themes

## Architecture

DevRadar follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Views        │  │ ViewModels   │  │ Components│ │
│  │ (SwiftUI)    │  │ (@Observable)│  │           │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────┐
│                   Domain Layer                       │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ Models       │  │ Protocols    │                │
│  │ (Codable)    │  │              │                │
│  └──────────────┘  └──────────────┘                │
└─────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────┐
│                    Data Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Repositories │  │ Persistence  │  │ Networking│ │
│  │              │  │ (SwiftData)  │  │ (GraphQL) │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────┘
```

### Layer Breakdown

**Presentation Layer**
- SwiftUI views with declarative UI
- @Observable ViewModels for state management
- Reusable design system components
- Theme protocol for light/dark modes

**Domain Layer**
- Pure Swift models (User, Repository, PullRequest)
- Protocol-based abstractions
- Business logic and data transformations

**Data Layer**
- Repository pattern for data access
- SwiftData models for local caching
- GraphQL client for GitHub API
- Keychain manager for secure token storage

## Project Structure

```
DevRadar/
├── Core/
│   ├── Networking/
│   │   ├── GitHubAPI.swift          # GraphQL client
│   │   ├── GraphQLQueries.swift     # Query definitions
│   │   └── NetworkError.swift       # Error types
│   └── Security/
│       └── KeychainManager.swift    # Secure token storage
├── Domain/
│   └── Models/
│       ├── User.swift               # User domain model
│       ├── Repository.swift         # Repository domain model
│       ├── PullRequest.swift        # PR domain model
│       └── GraphQLResponses.swift   # Response wrappers
├── Data/
│   ├── Persistence/
│   │   ├── CachedUser.swift         # SwiftData user model
│   │   ├── CachedRepository.swift   # SwiftData repo model
│   │   └── CachedPullRequest.swift  # SwiftData PR model
│   └── Repositories/
│       └── GitHubRepository.swift   # Repository layer
├── Features/
│   ├── Authentication/
│   │   ├── AuthenticationManager.swift  # OAuth flow
│   │   └── AuthenticationView.swift     # Login UI
│   └── Dashboard/
│       ├── DashboardViewModel.swift     # Dashboard state
│       └── DashboardView.swift          # Dashboard UI
├── DesignSystem/
│   ├── Theme.swift                  # Theme protocol & tokens
│   └── Components/
│       ├── StatCard.swift           # Metric display
│       ├── RepositoryCard.swift     # Repository item
│       ├── PRStatusRow.swift        # PR status row
│       ├── LoadingView.swift        # Loading states
│       ├── EmptyStateView.swift     # Empty states
│       └── ErrorView.swift          # Error states
└── DevRadarApp.swift                # App entry point
```

## Setup

### Prerequisites

- Xcode 15.0+
- macOS 14.0+ (for development)
- iOS 17.0+ (for iOS app)
- GitHub OAuth App credentials

### 1. Create GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in the details:
   - Application name: `DevRadar`
   - Homepage URL: `https://your-website.com`
   - Authorization callback URL: `devradar://oauth-callback`
4. Click "Register application"
5. Note your **Client ID** and **Client Secret**

### 2. Configure the App

Open [GitHubAPI.swift](DevRadar/Core/Networking/GitHubAPI.swift) and update the configuration:

```swift
static let production = GitHubAPIConfiguration(
    baseURL: "https://api.github.com",
    clientID: "YOUR_CLIENT_ID",        // Add your Client ID
    clientSecret: "YOUR_CLIENT_SECRET", // Add your Client Secret
    redirectURI: "devradar://oauth-callback",
    scopes: ["repo", "read:user", "user:email", "notifications"]
)
```

### 3. Add URL Scheme

1. Open `DevRadar.xcodeproj` in Xcode
2. Select the DevRadar target
3. Go to Info tab
4. Expand "URL Types"
5. Add a new URL Type:
   - Identifier: `com.devradar.oauth`
   - URL Schemes: `devradar`

### 4. Build and Run

```bash
# Open in Xcode
open DevRadar.xcodeproj

# Or build from command line
xcodebuild -scheme DevRadar -configuration Debug
```

## Technical Implementation

### Authentication Flow

1. User clicks "Sign in with GitHub"
2. `ASWebAuthenticationSession` opens GitHub OAuth page
3. User authorizes the app
4. GitHub redirects to `devradar://oauth-callback?code=...`
5. App exchanges code for access token
6. Token stored securely in Keychain
7. User info fetched to get username
8. Dashboard loads with authenticated user

### Data Flow

```
UI Request → ViewModel → Repository → API/Cache
                ↓
          Update State
                ↓
           UI Updates
```

**Cache Strategy:**
- Cache-first approach: Load from SwiftData immediately
- Background refresh: Fetch from API if cache is stale (>15 min)
- Optimistic updates: UI updates before network confirmation
- Error recovery: Fall back to cache on network errors

### GraphQL Queries

All GitHub data is fetched using GraphQL for efficiency:

- **Viewer Query**: User profile + contribution stats
- **Repositories Query**: User's repos with pagination
- **Pull Requests Query**: User's PRs with review state
- **Review Requests Query**: PRs awaiting user review
- **Repository Details Query**: Detailed repo info + commits

### Design System

**Semantic Colors:**
- Primary: GitHub blue (#0969DA light, #4493F8 dark)
- Success: Green for approved/merged states
- Warning: Yellow for pending states
- Error: Red for failed/rejected states

**Typography Scale:**
- Display: 34pt bold (page titles)
- Title: 28pt semibold (section headers)
- Headline: 17pt semibold (card titles)
- Body: 15pt regular (content)
- Caption: 13pt regular (metadata)
- Code: 14pt monospaced (code snippets)

**Spacing System:** 4pt grid (4, 8, 12, 16, 24, 32, 48, 64)

**Animations:**
- Spring transitions: response 0.3, damping 0.7
- Content transitions: numericText() for counters
- Skeleton loading with shimmer effect

## Next Steps

This foundation is ready for:

1. **Additional Features**
   - Repository details view with commit timeline
   - Contribution heatmap (365-day calendar)
   - Streak tracking with milestone celebrations
   - Settings screen for preferences
   - Pull request actions (approve, comment, merge)

2. **Platform Expansion**
   - macOS MenuBar app with NSStatusItem
   - iOS widgets for Home Screen
   - Background sync with BackgroundTasks
   - Notifications for review requests

3. **Polish**
   - Skeleton loading states
   - Pull-to-refresh interactions
   - Error retry with exponential backoff
   - Accessibility improvements
   - Unit tests for business logic

## Key Design Decisions

**Why Clean Architecture?**
- Clear separation makes testing easier
- Presentation layer is fully decoupled from data sources
- Easy to swap implementations (mock vs real API)

**Why @Observable over @StateObject?**
- Modern Swift concurrency support
- Better performance with fine-grained updates
- Cleaner syntax without property wrappers

**Why SwiftData over CoreData?**
- Type-safe Swift-native API
- Automatic migration support
- Better SwiftUI integration
- Less boilerplate code

**Why GraphQL over REST?**
- Single request for complex data
- Exact fields needed (no over-fetching)
- Strongly typed schema
- Built-in pagination support

## License

This is a portfolio project. Feel free to use as inspiration for your own projects.

## Contributing

This is currently a solo project, but suggestions and feedback are welcome via issues.
