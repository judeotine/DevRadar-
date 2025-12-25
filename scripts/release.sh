#!/bin/bash

# Release script for DevRadar
# Usage: ./scripts/release.sh [version] [type]
# Example: ./scripts/release.sh 1.0.0 major
# Example: ./scripts/release.sh 1.0.1 patch

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "You're not on the main branch (current: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    print_info "No existing tags found. Starting from v0.0.0"
    LATEST_TAG="v0.0.0"
fi

LATEST_VERSION=${LATEST_TAG#v}

IFS='.' read -ra VERSION_PARTS <<< "$LATEST_VERSION"
MAJOR=${VERSION_PARTS[0]:-0}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

if [ -n "$1" ]; then
    NEW_VERSION=$1
    NEW_VERSION=${NEW_VERSION#v}
else
    TYPE=${2:-patch}
    
    case $TYPE in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            print_error "Invalid type: $TYPE. Use 'major', 'minor', or 'patch'"
            exit 1
            ;;
    esac
    
    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format: $NEW_VERSION. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

TAG_NAME="v$NEW_VERSION"

if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    print_error "Tag $TAG_NAME already exists"
    exit 1
fi

print_info "Current version: $LATEST_TAG"
print_info "New version: $TAG_NAME"

print_info "Generating changelog..."

if [ "$LATEST_TAG" = "v0.0.0" ]; then
    COMMITS=$(git log --pretty=format:"- %s (%h)" --reverse)
else
    COMMITS=$(git log ${LATEST_TAG}..HEAD --pretty=format:"- %s (%h)" --reverse)
fi

if [ -z "$COMMITS" ]; then
    print_warning "No new commits since $LATEST_TAG"
    read -p "Create release anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    CHANGELOG="No changes since $LATEST_TAG"
else
    CHANGELOG="$COMMITS"
fi

echo
print_info "Changelog preview:"
echo "---"
echo "$CHANGELOG"
echo "---"
echo

read -p "Create release $TAG_NAME? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Release cancelled"
    exit 0
fi

print_info "Pulling latest changes..."
git pull origin "$CURRENT_BRANCH"

print_info "Creating tag $TAG_NAME..."
git tag -a "$TAG_NAME" -m "Release $TAG_NAME

$CHANGELOG"

print_info "Pushing tag to remote..."
git push origin "$TAG_NAME"

print_success "Release $TAG_NAME created and pushed!"
print_info "GitHub Actions will now build and create the release automatically."
print_info "You can view the progress at: https://github.com/$(git config --get remote.origin.url | sed -E 's/.*github.com[:/](.*)\.git/\1/')/actions"

