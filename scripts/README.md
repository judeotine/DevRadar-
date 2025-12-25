# Release Scripts

This directory contains scripts to automate the release process for DevRadar.

## Release Script

The `release.sh` script automates tag creation and release generation.

### Usage

#### Option 1: Auto-increment version
```bash
./scripts/release.sh [type]
```

Where `type` is one of:
- `major` - Increments major version (1.0.0 → 2.0.0)
- `minor` - Increments minor version (1.0.0 → 1.1.0)
- `patch` - Increments patch version (1.0.0 → 1.0.1) (default)

Examples:
```bash
# Create a patch release (1.0.0 → 1.0.1)
./scripts/release.sh patch

# Create a minor release (1.0.0 → 1.1.0)
./scripts/release.sh minor

# Create a major release (1.0.0 → 2.0.0)
./scripts/release.sh major
```

#### Option 2: Specify exact version
```bash
./scripts/release.sh [version]
```

Example:
```bash
# Create release v1.2.3
./scripts/release.sh 1.2.3
```

### What the script does

1. **Checks prerequisites**
   - Verifies you're in a git repository
   - Checks for uncommitted changes
   - Warns if not on main branch

2. **Determines version**
   - Finds the latest tag
   - Calculates new version (auto-increment or uses provided version)

3. **Generates changelog**
   - Extracts commits since the last tag
   - Shows a preview for confirmation

4. **Creates and pushes tag**
   - Creates an annotated tag with the changelog
   - Pushes the tag to remote

5. **Triggers GitHub Actions**
   - The tag push triggers the release workflow
   - GitHub Actions builds the app and creates the release

### Requirements

- Git repository
- Remote configured (origin)
- GitHub Actions workflow set up (`.github/workflows/release.yml`)

### Example Workflow

```bash
# Make sure you're on main branch and up to date
git checkout main
git pull origin main

# Create a patch release
./scripts/release.sh patch

# Or create a specific version
./scripts/release.sh 1.0.0
```

### Changelog Generation

The script automatically generates a changelog from commits since the last tag. The changelog includes:
- Commit messages
- Commit hashes (short)
- Formatted for GitHub releases

The GitHub Actions workflow also generates a changelog and includes it in the release notes automatically.

