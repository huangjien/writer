#!/bin/bash

# Dependency Analysis Script
# Identifies unused dependencies and optimization opportunities

set -euo pipefail

echo "======================================"
echo "Dependency Analysis for Writer"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}1. Checking for unused production dependencies...${NC}"

# Create temp file to track used packages
> /tmp/used_packages.txt

# Scan lib/ for imports
find lib -name "*.dart" -exec grep -h "^import 'package:" {} \; | \
  sed "s/import 'package://g" | sed "s/'.*//g" | \
  sort -u > /tmp/used_packages.txt

# Scan test/ for imports
find test -name "*.dart" -exec grep -h "^import 'package:" {} \; | \
  sed "s/import 'package://g" | sed "s/'.*//g" | \
  sort -u >> /tmp/used_packages.txt

# Get declared dependencies
grep -A 100 "^dependencies:" pubspec.yaml | \
  grep -E "^\s+[a-z_0-9]+:" | \
  sed 's/://g' | sed 's/^\s*//g' > /tmp/declared_deps.txt

echo "Used packages:"
wc -l < /tmp/used_packages.txt

echo ""
echo "Declared dependencies:"
wc -l < /tmp/declared_deps.txt

echo ""
echo -e "${YELLOW}Potentially unused dependencies:${NC}"

while IFS= read -r dep; do
  if ! grep -q "^$dep$" /tmp/used_packages.txt; then
    echo "  - $dep"
  fi
done < /tmp/declared_deps.txt

echo ""
echo -e "${GREEN}2. Checking for heavy dependencies...${NC}"

# Check package sizes (estimated)
echo "Large dependencies (>1MB estimated):"
flutter pub deps | grep -E "flutter |.* \* " || echo "  (Run 'flutter pub deps' first)"

echo ""
echo -e "${GREEN}3. Dependency optimization opportunities:${NC}"
echo ""
echo "Consider these optimizations:"
echo "  • Remove unused dependencies"
echo "  • Replace heavy packages with lighter alternatives"
echo "  • Enable tree-shaking in Flutter build"
echo "  • Use deferred imports for less-used features"

echo ""
echo -e "${GREEN}4. Flutter build optimizations:${NC}"
echo ""
echo "Current build suggestions:"
echo "  • Enable --split-debug-info for smaller release builds"
echo "  • Use --obfuscate for production"
echo "  • Consider --dart-define for environment-specific builds"
echo "  • Enable Dart2Wasm for web builds (faster, smaller)"

echo ""
echo "Run these commands to apply optimizations:"
echo "  flutter build apk --split-debug-info=./debug-info --obfuscate"
echo "  flutter build web --release --wasm"

echo ""
echo -e "${GREEN}Analysis complete!${NC}"
