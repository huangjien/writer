#!/bin/bash

# Build the Android APK for converted basic Android app
echo "Building Android APK..."

# Navigate to android directory and build
cd android

# Clean previous build
./gradlew clean

# Build release APK
./gradlew assembleRelease

# Return to root directory
cd ..

# Verify and move the APK
echo "Checking for generated APK..."
ls -al android/app/build/outputs/apk/release/app-release.apk

# Create temp directory if it doesn't exist
mkdir -p ~/temp

# Move the APK
cp android/app/build/outputs/apk/release/app-release.apk ~/temp/writer.apk
echo "APK copied to ~/temp/writer.apk"