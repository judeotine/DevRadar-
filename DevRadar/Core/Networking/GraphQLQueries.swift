import Foundation

enum GraphQLQueries {
    static let viewer = """
    query {
      viewer {
        id
        login
        name
        email
        avatarUrl
        bio
        company
        location
        url
        status {
          message
          emoji
        }
        contributionsCollection {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                contributionCount
                date
              }
            }
          }
          totalCommitContributions
          totalIssueContributions
          totalPullRequestContributions
          totalPullRequestReviewContributions
        }
      }
    }
    """

    static let repositories = """
    query($cursor: String) {
      viewer {
        repositories(first: 30, after: $cursor, orderBy: {field: UPDATED_AT, direction: DESC}, ownerAffiliations: [OWNER, COLLABORATOR]) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            id
            name
            nameWithOwner
            description
            url
            stargazerCount
            forkCount
            primaryLanguage {
              name
              color
            }
            updatedAt
            pushedAt
            isPrivate
            isFork
            owner {
              login
              avatarUrl
            }
          }
        }
      }
    }
    """

    static let pullRequests = """
    query($cursor: String) {
      viewer {
        pullRequests(first: 20, after: $cursor, orderBy: {field: UPDATED_AT, direction: DESC}) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            id
            title
            number
            url
            state
            isDraft
            createdAt
            updatedAt
            mergedAt
            closedAt
            additions
            deletions
            repository {
              name
              nameWithOwner
              owner {
                login
              }
            }
            author {
              login
              avatarUrl
            }
            reviewDecision
            reviews(first: 5) {
              nodes {
                author {
                  login
                }
                state
              }
            }
          }
        }
      }
    }
    """

    static let reviewRequests = """
    query {
      search(query: "is:pr is:open review-requested:@me", type: ISSUE, first: 20) {
        nodes {
          ... on PullRequest {
            id
            title
            number
            url
            state
            isDraft
            createdAt
            updatedAt
            mergedAt
            closedAt
            additions
            deletions
            repository {
              name
              nameWithOwner
              owner {
                login
              }
            }
            author {
              login
              avatarUrl
            }
            reviewDecision
            reviews(first: 5) {
              nodes {
                author {
                  login
                }
                state
              }
            }
          }
        }
      }
    }
    """

    static let repositoryDetails = """
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        id
        name
        nameWithOwner
        description
        url
        stargazerCount
        forkCount
        watchers {
          totalCount
        }
        issues(states: OPEN) {
          totalCount
        }
        pullRequests(states: OPEN) {
          totalCount
        }
        primaryLanguage {
          name
          color
        }
        languages(first: 10, orderBy: {field: SIZE, direction: DESC}) {
          edges {
            size
            node {
              name
              color
            }
          }
        }
        defaultBranchRef {
          name
          target {
            ... on Commit {
              history(first: 30) {
                nodes {
                  oid
                  message
                  committedDate
                  author {
                    name
                    email
                    user {
                      login
                      avatarUrl
                    }
                  }
                  additions
                  deletions
                }
              }
            }
          }
        }
        refs(first: 5, refPrefix: "refs/heads/", orderBy: {field: ALPHABETICAL, direction: ASC}) {
          nodes {
            name
            target {
              ... on Commit {
                oid
              }
            }
          }
        }
        collaborators(first: 10) {
          nodes {
            login
            avatarUrl
          }
        }
        createdAt
        updatedAt
        pushedAt
        isPrivate
        isFork
        owner {
          login
          avatarUrl
        }
      }
    }
    """

    static let contributionActivity = """
    query($from: DateTime!, $to: DateTime!) {
      viewer {
        contributionsCollection(from: $from, to: $to) {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                contributionCount
                date
                color
              }
            }
          }
          totalCommitContributions
          totalIssueContributions
          totalPullRequestContributions
          totalPullRequestReviewContributions
          commitContributionsByRepository(maxRepositories: 10) {
            repository {
              name
              nameWithOwner
              owner {
                login
              }
            }
            contributions(first: 100) {
              nodes {
                occurredAt
                commitCount
              }
            }
          }
        }
      }
    }
    """
}
