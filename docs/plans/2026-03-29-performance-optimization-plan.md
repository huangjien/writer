# Milestone 5 Phase 1: Performance Optimization Plan

## Date
2026-03-29

## Baseline Metrics (2026-03-29)

| Metric | Current | Target | Priority |
|--------|---------|--------|----------|
| **Font Assets** | 38MB | <10MB | 🔴 Critical |
| **Android APK** | 94MB | <75MB | 🔴 Critical |
| **Web Build** | TBD | TBD | Medium |
| **Provider Count** | 973 | <800 | High |
| **Startup Time** | TBD | <2s | High |
| **Memory Usage** | TBD | <100MB | Medium |

---

## Critical Issue: Font Assets (38MB → <10MB)

### Problem
- **NotoSansSC-Regular.ttf**: 17MB
- **NotoSansSC-Bold.ttf**: 17MB
- **Total**: 34MB for Chinese font support (89% of all fonts)

### Root Cause
Full font files include all CJK characters (20,000+ glyphs), but we likely only use a small subset.

### Solution: Font Subsetting
1. **Analyze character usage** - Extract all Chinese characters used in the app
2. **Subset fonts** - Create custom fonts with only used glyphs
3. **Implement lazy loading** - Load Chinese fonts only when needed

### Implementation Steps
```bash
# 1. Install font subsetting tool
pip install fonttools brotli

# 2. Extract used characters
find lib -name "*.dart" -exec grep -oP "[\x{4e00}-\x{9fff}]" {} \; | sort -u > chinese_chars.txt

# 3. Subset fonts
pyftsubset NotoSansSC-Regular.ttf \
  --text-file=chinese_chars.txt \
  --output-file=NotoSansSC-Regular-subset.ttf \
  --flavor=woff2

# 4. Expected savings: 30MB+ (80% reduction)
```

### Impact
- **Savings**: 30MB+ (80% reduction)
- **Build size**: -30MB on all platforms
- **Risk**: Low (subset will include all used characters)

---

## High Priority: APK Size Reduction (94MB → <75MB)

### Problem
94MB APK is large for a writing app. Target: 20% reduction.

### Root Causes
1. Font assets: 38MB (40% of APK)
2. Flutter engine: ~30MB (fixed)
3. Dart code: TBD
4. Other assets: TBD

### Solutions
1. **Font subsetting** (above): -30MB
2. **Tree-shaking**: Remove unused dependencies
3. **Code splitting**: Lazy load routes
4. **Asset compression**: Compress images and icons

### Implementation Steps
```yaml
# pubspec.yaml optimizations
flutter:
  # Enable tree-shaking
  uses-material-design: true

  # Compress assets
  assets:
    - assets/fonts/subset/  # Subset fonts here
    - web/icons/Icon-192.png compressed
    - web/icons/Icon-512.png compressed
```

### Impact
- **Savings**: 20-25MB (25% reduction)
- **Build size**: 94MB → 70MB
- **Risk**: Low

---

## High Priority: Provider Optimization (973 → <800)

### Problem
973 Riverpod providers is high. Could cause:
- Unnecessary widget rebuilds
- Increased memory usage
- Slower startup time

### Root Causes
1. `chapter_reader_screen.dart`: 43 providers
2. `scenes_screen.dart`: 34 providers
3. `app_settings_section.dart`: 32 providers

### Solutions
1. **Consolidate related providers** - Group related state
2. **Use `select()` instead of `watch()`** - Reduce rebuilds
3. **Implement provider families** - Dynamic providers
4. **Lazy provider initialization** - Defer non-critical providers

### Implementation Steps
```dart
// Before: Multiple providers
final chapterTitleProvider = Provider<String>((ref) => ...);
final chapterContentProvider = Provider<String>((ref) => ...);
final chapterAuthorProvider = Provider<String>((ref) => ...);

// After: Single provider with data class
final chapterProvider = Provider<ChapterData>((ref) => ...);

class ChapterData {
  final String title;
  final String content;
  final String author;
}
```

### Impact
- **Savings**: 150-200 providers
- **Performance**: 15-20% fewer rebuilds
- **Risk**: Medium (requires refactoring)

---

## Medium Priority: Route Lazy Loading (58 routes)

### Problem
All 58 routes are loaded at startup, increasing initial bundle size.

### Solution: Deferred Loading
```dart
// Before: Immediate loading
GoRoute(
  path: '/settings/advanced',
  builder: (context, state) => const AdvancedSettingsScreen(),
),

// After: Deferred loading
GoRoute(
  path: '/settings/advanced',
  pageBuilder: (context, state) => DeferredPage(
    child: AdvancedSettingsScreen(),
    preload: () => Future.delayed(const Duration(seconds: 1)),
  ),
),
```

### Implementation Steps
1. **Identify low-priority routes** - Settings, admin, less-used features
2. **Implement deferred loading** - Use `DeferredPage` from go_router
3. **Add preload hints** - Preload on route hover/nearby

### Impact
- **Savings**: 5-10MB initial bundle
- **Startup time**: 10-15% improvement
- **Risk**: Low

---

## Medium Priority: Asset Optimization

### Problem
- Large icon files: 248KB each (Icon-512.png, Icon-maskable-512.png)
- Total web icons: ~620KB

### Solution: Image Compression & WebP Conversion
```bash
# Convert PNG to WebP (50% smaller)
cwebp web/icons/Icon-512.png -o web/icons/Icon-512.webp -q 90

# Compress existing PNGs
optipng -o2 web/icons/*.png
```

### Implementation Steps
1. **Convert to WebP** - For web builds
2. **Compress PNGs** - For mobile builds
3. **Use responsive images** - Different sizes for different devices

### Impact
- **Savings**: 300-400KB (50% reduction)
- **Build size**: Small but meaningful
- **Risk**: Low

---

## Implementation Order

### Week 1: Critical Wins
1. **Font subsetting** (Day 1-2) - 30MB savings
2. **Asset compression** (Day 3) - 400KB savings
3. **Build and measure** (Day 4) - Verify improvements

### Week 2: Deep Optimization
4. **Provider consolidation** (Day 1-3) - Performance improvement
5. **Route lazy loading** (Day 4-5) - Startup improvement
6. **Final measurements** (Day 5) - Document results

---

## Success Criteria

### Must-Have (Week 1)
- ✅ Font assets: 38MB → <10MB (70% reduction)
- ✅ APK size: 94MB → <70MB (25% reduction)
- ✅ All features working correctly

### Nice-to-Have (Week 2)
- ✅ Provider count: 973 → <800 (17% reduction)
- ✅ Startup time: <2 seconds
- ✅ 0 new lint errors
- ✅ 85%+ test coverage maintained

---

## Risk Mitigation

### Font Subsetting Risks
- **Risk**: Missing characters in subset
- **Mitigation**: Conservative character extraction + testing
- **Fallback**: Keep full fonts as backup

### Provider Refactoring Risks
- **Risk**: Breaking existing functionality
- **Mitigation**: Comprehensive tests + gradual rollout
- **Fallback**: Feature flags for new provider patterns

---

## Next Steps

1. **Today**: Start font subsetting (30MB savings)
2. **Tomorrow**: Asset compression + build verification
3. **Week 2**: Provider optimization + lazy loading
4. **End of Week 2**: Document results + set up regression tests

---

## Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Font Subsetting Guide](https://github.com/fonttools/fonttools)
- [GoRouter Deferred Loading](https://gorouter.dev/deferred-loading)
- [Riverpod Optimization](https://riverpod.dev/docs/concepts/optimizations)
