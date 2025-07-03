#!/bin/bash

# GitHub Release Publisher Script
# This script creates a GitHub release and uploads the writer.apk file

set -e

# Configuration
REPO_OWNER="${GITHUB_REPO_OWNER:-$(git config user.name)}"
REPO_NAME="${GITHUB_REPO_NAME:-writer}"
APK_PATH="$HOME/temp/writer.apk"

# Read version from package.json
PACKAGE_VERSION=$(node -p "require('./package.json').version")
RELEASE_TAG="${RELEASE_TAG:-v$PACKAGE_VERSION}"
RELEASE_NAME="Writer App v$PACKAGE_VERSION"
RELEASE_BODY="Writer Android app release v$PACKAGE_VERSION\n\nGenerated on: $(date)\nAPK Size: $(ls -lh $HOME/temp/writer.apk | awk '{print $5}')"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 GitHub Release Publisher${NC}"
echo "=============================="

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ Error: APK file not found at $APK_PATH${NC}"
    echo "Please run ./buildAndroid.sh first to generate the APK"
    exit 1
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

# Get repository info
echo -e "${YELLOW}📋 Repository Info:${NC}"
echo "Owner: $REPO_OWNER"
echo "Repository: $REPO_NAME"
echo "Tag: $RELEASE_TAG"
echo "APK: $APK_PATH"

# Confirm before proceeding
read -p "Do you want to proceed with the release? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏹️  Release cancelled${NC}"
    exit 0
fi

# Create the release
echo -e "${YELLOW}📦 Creating GitHub release...${NC}"
gh release create "$RELEASE_TAG" \
    --repo "$REPO_OWNER/$REPO_NAME" \
    --title "$RELEASE_NAME" \
    --notes "$RELEASE_BODY" \
    --latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create release${NC}"
    exit 1
fi

# Upload the APK
echo -e "${YELLOW}📤 Uploading APK to release...${NC}"
gh release upload "$RELEASE_TAG" "$APK_PATH" \
    --repo "$REPO_OWNER/$REPO_NAME" \
    --clobber

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK uploaded successfully${NC}"
    echo -e "${GREEN}🎉 Release published!${NC}"
    echo
    echo "Release URL: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$RELEASE_TAG"
else
    echo -e "${RED}❌ Failed to upload APK${NC}"
    exit 1
fi

echo -e "${GREEN}✨ All done!${NC}"