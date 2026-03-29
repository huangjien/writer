#!/bin/bash

# Performance Baseline Script for Writer
# Measures current performance metrics before optimizations

set -euo pipefail

echo "======================================"
echo "Writer Performance Baseline Analysis"
echo "======================================"
echo ""

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="/tmp/writer_perf_baseline_$TIMESTAMP.txt"
exec > >(tee -a "$OUTPUT_FILE")
exec 2>&1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_section() {
    echo ""
    echo "======================================"
    echo "$1"
    echo "======================================"
}

# 1. CODEBASE METRICS
print_section "1. Codebase Metrics"

echo "Total lines of Dart code:"
find lib -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1

echo ""
echo "Total lines of test code:"
find test -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1

echo ""
echo "Number of Dart files in lib:"
find lib -name '*.dart' | wc -l

echo ""
echo "Number of test files:"
find test -name '*.dart' | wc -l

# 2. DEPENDENCY ANALYSIS
print_section "2. Dependency Analysis"

echo "Production dependencies:"
grep -A 100 "^dependencies:" pubspec.yaml | grep -E "^\s+[a-z]" | wc -l

echo ""
echo "Dev dependencies:"
grep -A 100 "^dev_dependencies:" pubspec.yaml | grep -E "^\s+[a-z]" | wc -l

echo ""
echo "Large dependencies (>500KB estimated):"
flutter pub deps | grep -E "(flutter |.* \* )" || echo "Run 'flutter pub deps' first"

# 3. ASSET ANALYSIS
print_section "3. Asset Analysis"

echo "Font files:"
find assets/fonts -name "*.ttf" -o -name "*.otf" | while read font; do
    SIZE=$(du -h "$font" | cut -f1)
    echo "  $SIZE: $font"
done | sort -h

echo ""
echo "Total font size:"
du -sh assets/fonts/

echo ""
echo "Web assets:"
find web -type f | while read asset; do
    SIZE=$(du -h "$asset" | cut -f1)
    echo "  $SIZE: $asset"
done | sort -h

# 4. BUILD SIZE ANALYSIS
print_section "4. Build Size Analysis"

echo "Checking for existing builds..."
if [ -d "build/web" ]; then
    echo ""
    echo "Web build size:"
    du -sh build/web/
    echo ""
    echo "Largest files in web build:"
    find build/web -type f -exec du -h {} + | sort -rh | head -n 10
else
    echo "No web build found. Run 'make build-web' first."
fi

if [ -d "build/macos/Build/Products/Release" ]; then
    echo ""
    echo "macOS build size:"
    du -sh build/macos/Build/Products/Release/*.app 2>/dev/null || echo "No macOS app found"
fi

if [ -d "build/app/outputs/flutter-apk" ]; then
    echo ""
    echo "Android APK size:"
    ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "No APK found"
fi

# 5. PROVIDER ANALYSIS
print_section "5. Provider/State Management Analysis"

echo "Counting Riverpod providers:"
grep -r "Provider\|NotifierProvider\|AsyncNotifierProvider" lib --include="*.dart" | wc -l

echo ""
echo "Top files with most providers:"
grep -r "Provider\|NotifierProvider\|AsyncNotifierProvider" lib --include="*.dart" | cut -d: -f1 | sort | uniq -c | sort -rn | head -n 10

# 6. ROUTE ANALYSIS
print_section "6. Route Analysis"

echo "Counting GoRouter routes:"
grep -r "GoRoute" lib --include="*.dart" | wc -l

echo ""
echo "Route files:"
find lib -name "*route*.dart" -o -name "*router*.dart"

# 7. POTENTIAL OPTIMIZATION OPPORTUNITIES
print_section "7. Potential Optimization Opportunities"

echo "Checking for common performance anti-patterns..."
echo ""

# Check for large functions
echo "Functions >100 lines:"
find lib -name '*.dart' -exec awk '/^{$/ {start=NR} /^}$/ && start {if (NR-start>100) print FILENAME":"start"-"NR" ("NR-start" lines)"; start=0}' {} \; 2>/dev/null || echo "None found"

echo ""
echo "Files >500 lines:"
find lib -name '*.dart' -exec wc -l {} + | awk '$1>500 {print $0}' | sort -rn

echo ""
echo "Deeply nested directories (potential coupling):"
find lib -type d -links 2 | while read dir; do
    DEPTH=$(echo "$dir" | tr '/' '\n' | wc -l)
    if [ $DEPTH -gt 5 ]; then
        echo "$dir (depth: $DEPTH)"
    fi
done

# 8. RECOMMENDATIONS
print_section "8. Quick Win Recommendations"

echo "Based on the analysis, consider these optimizations:"
echo ""
echo "1. Build Size:"
echo "   - Enable tree-shaking: Review unused dependencies"
echo "   - Lazy load routes: Defer non-critical route loading"
echo "   - Optimize assets: Compress images, subset fonts"
echo ""
echo "2. Startup Time:"
echo "   - Defer provider initialization: Use ProviderContainer lazily"
echo "   - Lazy load features: Load less-used features on demand"
echo "   - Optimize app initialization: Review main() startup code"
echo ""
echo "3. Runtime Performance:"
echo "   - Reduce provider rebuilds: Use select() and watch() carefully"
echo "   - Optimize list rendering: Use ListView.builder properly"
echo "   - Implement image caching: Reduce network requests"
echo ""
echo "4. Memory:"
echo "   - Implement proper disposal: Dispose controllers and listeners"
echo "   - Optimize image loading: Use cached_network_image wisely"
echo "   - Profile memory usage: Use DevTools memory profiler"

# SUMMARY
print_section "Summary"

echo "Performance baseline complete!"
echo ""
echo "Results saved to: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Build release version: make build-web"
echo "2. Profile with DevTools: flutter pub global run devtools"
echo "3. Implement quick wins from recommendations above"
echo ""
echo "Target improvements:"
echo "- Build size: Reduce by 20%"
echo "- Startup time: <2 seconds"
echo "- Memory usage: <100MB baseline"
