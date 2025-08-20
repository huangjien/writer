#!/bin/bash

# Build the Android APK using native Gradle
echo "Building Android APK with Gradle..."

# Check if Android directory exists (should exist after ejecting)
if [ ! -d "android" ]; then
  echo "Error: Android directory not found. Make sure to eject from Expo first."
  exit 1
fi

# Navigate to android directory
cd android

# Make gradlew executable
chmod +x gradlew

# Clean previous builds
echo "Cleaning previous builds..."
./gradlew clean

# Build release APK
echo "Building release APK..."
./gradlew assembleRelease

# Check if build was successful
if [ $? -ne 0 ]; then
  echo "Error: Gradle build failed"
  exit 1
fi

# Go back to root directory
cd ..

# Verify APK exists
APK_PATH="android/app/build/outputs/apk/release/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "Error: APK not found at $APK_PATH"
  exit 1
fi

echo "APK found at $APK_PATH"

# Create temp directory if it doesn't exist
mkdir -p "$HOME/temp"

# Copy APK to temp directory
cp "$APK_PATH" "$HOME/temp/writer.apk"

if [ $? -eq 0 ]; then
  echo "APK built successfully and saved to $HOME/temp/writer.apk"
  ls -la "$HOME/temp/writer.apk"
else
  echo "Error: Failed to copy APK to temp directory"
  exit 1
fi