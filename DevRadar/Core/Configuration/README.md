# GitHub Configuration

## Setup Instructions

### Option 1: Use Environment Variables (Recommended for CI/CD)

Set these environment variables before running the app:

```bash
export GITHUB_CLIENT_ID="your_client_id"
export GITHUB_CLIENT_SECRET="your_client_secret"
```

### Option 2: Use Property List File (Current Setup)

The app is configured to use `GitHubConfig.plist` for credentials.

**Important**: The `GitHubConfig.plist` file is already created and gitignored. You need to:

1. Add `GitHubConfig.plist` to your Xcode project:
   - Right-click on the `Configuration` folder in Xcode
   - Select "Add Files to DevRadar..."
   - Select `GitHubConfig.plist`
   - ✅ Check "Copy items if needed"
   - ✅ Ensure "DevRadar" target is selected
   - Click "Add"

2. Verify the file contains your credentials:
   - `ClientID`: Your GitHub OAuth Client ID
   - `ClientSecret`: Your GitHub OAuth Client Secret

The file is automatically gitignored and will not be committed to version control.

## Security Best Practices

- ✅ `GitHubConfig.plist` is gitignored - never commit it
- Use environment variables for production deployments
- Use plist files for local development
- Never commit actual credentials to version control
- Rotate credentials if they're accidentally exposed
