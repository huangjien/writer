#!/bin/bash

# GitHub Release Publisher Script
# This script creates a GitHub release and uploads the writer.apk file

set -e

# Configuration
# In GitHub Actions, use GITHUB_REPOSITORY environment variable
if [ -n "$GITHUB_REPOSITORY" ]; then
    REPO_OWNER="$(echo $GITHUB_REPOSITORY | cut -d'/' -f1)"
    REPO_NAME="$(echo $GITHUB_REPOSITORY | cut -d'/' -f2)"
else
    REPO_OWNER="${GITHUB_REPO_OWNER:-$(git config user.name)}"
    REPO_NAME="${GITHUB_REPO_NAME:-writer}"
fi
APK_PATH="$HOME/temp/writer.apk"

# Read version from package.json
PACKAGE_VERSION=$(node -p "require('./package.json').version")
RELEASE_TAG="${RELEASE_TAG:-v$PACKAGE_VERSION}"
RELEASE_NAME="Writer App v$PACKAGE_VERSION"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 GitHub Release Publisher${NC}"
echo "=============================="

# Check if APK exists (optional for GitHub-only releases)
APK_EXISTS=false
if [ -f "$APK_PATH" ]; then
    APK_EXISTS=true
    echo -e "${GREEN}✅ APK file found at $APK_PATH${NC}"
else
    echo -e "${YELLOW}⚠️  APK file not found at $APK_PATH${NC}"
    echo "Creating GitHub release without APK attachment"
fi

# Set release body based on APK availability
if [ "$APK_EXISTS" = true ]; then
    RELEASE_BODY="Writer Android app release v$PACKAGE_VERSION\n\nGenerated on: $(date)\nAPK Size: $(ls -lh $HOME/temp/writer.apk | awk '{print $5}')"
else
    RELEASE_BODY="Writer app release v$PACKAGE_VERSION\n\nGenerated on: $(date)\nSource code release"
fi

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ Error: GITHUB_TOKEN environment variable is not set${NC}"
    echo "Please set your GitHub personal access token:"
    echo "export GITHUB_TOKEN=your_token_here"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Error: Node.js is not installed${NC}"
    echo "Please install Node.js to read package.json version"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it with: brew install gh"
    exit 1
fi

# GitHub CLI will automatically use GITHUB_TOKEN environment variable
echo -e "${YELLOW}🔐 Using GitHub token for authentication...${NC}"

# Debug: Check environment variables
echo -e "${YELLOW}🔍 Debug Info:${NC}"
echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "GITHUB_TOKEN set: $([ -n "$GITHUB_TOKEN" ] && echo 'Yes' || echo 'No')"
echo "CI environment: $CI"

# Get repository info
echo -e "${YELLOW}📋 Repository Info:${NC}"
echo "Owner: $REPO_OWNER"
echo "Repository: $REPO_NAME"
echo "Tag: $RELEASE_TAG"
echo "APK: $APK_PATH"

# Skip confirmation in CI environment
if [ "$CI" != "true" ]; then
    read -p "Do you want to proceed with the release? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏹️  Release cancelled${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}🤖 Running in CI environment, proceeding automatically${NC}"
fi

# Create the release
echo -e "${YELLOW}📦 Creating GitHub release...${NC}"
echo "Command: gh release create $RELEASE_TAG --repo $REPO_OWNER/$REPO_NAME --title '$RELEASE_NAME' --notes '$RELEASE_BODY' --latest"

# Check if release already exists
if gh release view "$RELEASE_TAG" --repo "$REPO_OWNER/$REPO_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Release $RELEASE_TAG already exists, deleting it first...${NC}"
    gh release delete "$RELEASE_TAG" --repo "$REPO_OWNER/$REPO_NAME" --yes
fi

gh release create "$RELEASE_TAG" \
    --repo "$REPO_OWNER/$REPO_NAME" \
    --title "$RELEASE_NAME" \
    --notes "$RELEASE_BODY" \
    --latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create release${NC}"
    echo "Error details:"
    gh release create "$RELEASE_TAG" \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --title "$RELEASE_NAME" \
        --notes "$RELEASE_BODY" \
        --latest 2>&1 || true
    exit 1
fi

# Upload the APK if it exists
if [ "$APK_EXISTS" = true ]; then
    echo -e "${YELLOW}📤 Uploading APK to release...${NC}"
    gh release upload "$RELEASE_TAG" "$APK_PATH" \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --clobber
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ APK uploaded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to upload APK${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}📝 No APK to upload, source-only release${NC}"
fi

echo -e "${GREEN}🎉 Release published!${NC}"
echo
echo "Release URL: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$RELEASE_TAG"

echo -e "${GREEN}✨ All done!${NC}"