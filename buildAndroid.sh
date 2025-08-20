#!/bin/bash

# Build the Android APK for Expo project
echo "Building Android APK with Expo..."

# Check if this is an Expo project
if [ ! -f "app.json" ] && [ ! -f "app.config.js" ]; then
  echo "Error: This doesn't appear to be an Expo project (no app.json or app.config.js found)"
  exit 1
fi

# Create temp directory if it doesn't exist
mkdir -p "$HOME/temp"

# Build APK using EAS Build local
echo "Building APK using EAS Build..."
eas build --platform android --profile production --local --output "$HOME/temp/writer.apk" --non-interactive

if [ $? -eq 0 ]; then
  echo "APK built successfully and saved to $HOME/temp/writer.apk"
else
  echo "Error: APK build failed"
  exit 1
fi