#!/bin/bash

# Optimized Build Script for Writer
# Applies safe, proven build optimizations to reduce size and improve performance

set -euo pipefail

echo "======================================"
echo "Optimized Build for Writer"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
BUILD_TYPE=${1:-"all"}

echo -e "${GREEN}Build Configuration:${NC}"
echo "  Type: $BUILD_TYPE"
echo "  Optimizations:"
echo "    • Split debug info"
echo "    • Obfuscation"
echo "    • Release mode"
echo ""

# Function to build web
build_web() {
    echo -e "${GREEN}Building optimized web bundle...${NC}"

    flutter clean
    flutter pub get

    flutter build web \
        --release \
        --web-renderer canvaskit \
        --split-debug-info=./debug-info \
        --obfuscate

    if [ -d "build/web" ]; then
        SIZE=$(du -sh build/web/ | cut -f1)
        echo ""
        echo -e "${GREEN}Web build complete!${NC}"
        echo "  Size: $SIZE"
        echo "  Location: build/web/"
        echo ""
        echo "To test locally:"
        echo "  python3 -m http.server 8080 --directory build/web"
    fi
}

# Function to build Android
build_android() {
    echo -e "${GREEN}Building optimized Android APK...${NC}"

    flutter clean
    flutter pub get

    flutter build apk \
        --release \
        --split-debug-info=./debug-info \
        --obfuscate

    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
        echo ""
        echo -e "${GREEN}Android APK build complete!${NC}"
        echo "  Size: $SIZE"
        echo "  Location: build/app/outputs/flutter-apk/app-release.apk"
        echo ""
        echo "Installing to /tmp/..."
        cp build/app/outputs/flutter-apk/app-release.apk /tmp/writer-optimized.apk
        echo "  Copied to: /tmp/writer-optimized.apk"
    fi
}

# Function to build iOS
build_ios() {
    echo -e "${GREEN}Building optimized iOS IPA...${NC}"

    flutter clean
    flutter pub get

    flutter build ipa \
        --release \
        --split-debug-info=./debug-info \
        --obfuscate

    if [ -d "build/ios/archive" ]; then
        echo ""
        echo -e "${GREEN}iOS IPA build complete!${NC}"
        echo "  Location: build/ios/archive/"
        echo ""
        echo "Note: IPA size varies by device and architecture"
    fi
}

# Function to build macOS
build_macos() {
    echo -e "${GREEN}Building optimized macOS app...${NC}"

    flutter clean
    flutter pub get

    flutter build macos \
        --release \
        --split-debug-info=./debug-info \
        --obfuscate

    if [ -d "build/macos/Build/Products/Release" ]; then
        SIZE=$(du -sh build/macos/Build/Products/Release/*.app | cut -f1)
        echo ""
        echo -e "${GREEN}macOS build complete!${NC}"
        echo "  Size: $SIZE"
        echo "  Location: build/macos/Build/Products/Release/"
        echo ""
        if [ -d "/Applications" ] && [ -z "$CI" ]; then
            echo "Copying to /Applications..."
            cp -R build/macos/Build/Products/Release/*.app /Applications/
            echo "  Installed to /Applications/"
        fi
    fi
}

# Main build logic
case $BUILD_TYPE in
    web)
        build_web
        ;;
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    macos)
        build_macos
        ;;
    all)
        echo -e "${YELLOW}Building all platforms...${NC}"
        echo ""
        build_web
        echo ""
        build_android
        echo ""
        build_macos
        ;;
    *)
        echo "Usage: $0 [web|android|ios|macos|all]"
        echo ""
        echo "Examples:"
        echo "  $0 web          # Build optimized web bundle"
        echo "  $0 android      # Build optimized Android APK"
        echo "  $0 all          # Build all platforms"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}======================================"
echo "Build Optimization Summary"
echo "======================================${NC}"
echo ""
echo "Optimizations applied:"
echo "  ✓ Split debug info (separates debugging symbols)"
echo "  ✓ Obfuscation (shrinks code size)"
echo "  ✓ Release mode (removes debug overhead)"
echo ""
echo "Expected improvements:"
echo "  • 10-20% smaller build size"
echo "  • Faster startup time"
echo "  • Better runtime performance"
echo ""
echo "Note: Keep the ./debug-info folder safe for crash symbolication"

echo ""
echo "Next steps:"
echo "1. Test the optimized build thoroughly"
echo "2. Compare size with baseline (see scripts/performance_baseline.sh)"
echo "3. Measure startup time and runtime performance"
echo "4. Update STATE.md with results"
