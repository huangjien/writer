# GitHub Release Publisher

This document explains how to use the `publishRelease.sh` script to publish your Writer Android APK to GitHub releases.

## Prerequisites

1. **GitHub CLI**: Install the GitHub CLI tool
   ```bash
   brew install gh
   ```

2. **GitHub Personal Access Token**: Create a token with `repo` permissions
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate a new token with `repo` scope
   - Copy the token

3. **Built APK**: Ensure you have built the Android APK
   ```bash
   ./buildAndroid.sh
   ```

## Usage

### Basic Usage

1. Set your GitHub token:
   ```bash
   export GITHUB_TOKEN=your_github_token_here
   ```

2. Run the release script:
   ```bash
   ./publishRelease.sh
   ```

### Advanced Usage

You can customize the release by setting environment variables:

```bash
# Set custom repository owner (defaults to git config user.name)
export GITHUB_REPO_OWNER=your-username

# Set custom repository name (defaults to 'writer')
export GITHUB_REPO_NAME=your-repo-name

# Set custom release tag (defaults to timestamp)
export RELEASE_TAG=v1.0.0

# Run the script
./publishRelease.sh
```

## What the Script Does

1. **Validates Prerequisites**: Checks for APK file, GitHub token, and GitHub CLI
2. **Authenticates**: Logs into GitHub using your token
3. **Creates Release**: Creates a new GitHub release with auto-generated tag
4. **Uploads APK**: Attaches the `writer.apk` file to the release
5. **Provides URL**: Shows the direct link to your new release

## Example Output

```
🚀 GitHub Release Publisher
==============================
🔐 Authenticating with GitHub...
📋 Repository Info:
Owner: your-username
Repository: writer
Tag: v20240702-231500
APK: ~/temp/writer.apk

Do you want to proceed with the release? (y/N): y
📦 Creating GitHub release...
✅ Release created successfully
📤 Uploading APK to release...
✅ APK uploaded successfully
🎉 Release published!

Release URL: https://github.com/your-username/writer/releases/tag/v20240702-231500
✨ All done!
```

## Troubleshooting

- **APK not found**: Run `./buildAndroid.sh` first
- **GitHub token error**: Ensure `GITHUB_TOKEN` is set and has `repo` permissions
- **GitHub CLI not found**: Install with `brew install gh`
- **Authentication failed**: Check your token permissions and validity

## Security Notes

- Never commit your GitHub token to the repository
- Use environment variables or secure credential storage
- The token should have minimal required permissions (`repo` scope only)