import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/strings.dart';

/// Optional font packs for reader UI.
enum ReaderFontPack { system, inter, merriweather }

/// Monospace fallbacks per UI mockups for graceful degradation.
const List<String> _monoFallback = <String>[
  'Consolas',
  'Menlo',
  'Monaco',
  'SF Mono',
  'Roboto Mono',
  'ui-monospace',
  'monospace',
];

const String embeddedChineseSansFamily = 'Noto Sans SC';

const List<String> _systemChineseFontsApple = <String>[
  'PingFang SC',
  'Hiragino Sans GB',
  'Heiti SC',
  'Songti SC',
];

const List<String> _systemChineseFontsWindows = <String>[
  'Microsoft YaHei',
  'Microsoft YaHei UI',
  'Microsoft JhengHei',
  'SimSun',
  'SimHei',
];

const List<String> _systemChineseFontsLinux = <String>[
  'Noto Sans CJK SC',
  'Noto Sans CJK',
  'WenQuanYi Micro Hei',
  'AR PL UMing CN',
  'AR PL UKai CN',
];

const List<String> _embeddedChineseFonts = <String>[
  'Noto Sans SC',
  'NotoSansSC',
];

const List<String> _genericTextFallback = <String>[
  'Noto Sans',
  'Roboto',
  'Arial Unicode MS',
  'sans-serif',
];

List<String> chineseTextFallback() {
  final ordered = <String>[];
  if (kIsWeb) {
    ordered.add('system-ui');
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      ordered.addAll(_systemChineseFontsApple);
      break;
    case TargetPlatform.windows:
      ordered.addAll(_systemChineseFontsWindows);
      break;
    case TargetPlatform.linux:
      ordered.addAll(_systemChineseFontsLinux);
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      ordered.addAll(_systemChineseFontsLinux);
      break;
  }
  ordered.addAll(_embeddedChineseFonts);
  // Add Google Fonts fallback just in case
  final gf = GoogleFonts.notoSansSc().fontFamily;
  if (gf != null) ordered.add(gf);

  ordered.addAll(_genericTextFallback);

  final deduped = <String>[];
  final seen = <String>{};
  for (final f in ordered) {
    if (seen.add(f)) deduped.add(f);
  }
  return deduped;
}

List<String> supportedChineseFontFamilies() {
  final families = <String>[];
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      families.addAll(_systemChineseFontsApple);
      break;
    case TargetPlatform.windows:
      families.addAll(_systemChineseFontsWindows);
      break;
    case TargetPlatform.linux:
      families.addAll(_systemChineseFontsLinux);
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      families.addAll(_systemChineseFontsLinux);
      break;
  }
  families.addAll(_embeddedChineseFonts);

  final deduped = <String>[];
  final seen = <String>{};
  for (final f in families) {
    if (seen.add(f)) deduped.add(f);
  }
  return deduped;
}

TextTheme _applyFallbackOnly(TextTheme base, List<String> fallback) {
  TextStyle? withStyle(TextStyle? s) =>
      s?.copyWith(fontFamilyFallback: fallback);
  return base.copyWith(
    displayLarge: withStyle(base.displayLarge),
    displayMedium: withStyle(base.displayMedium),
    displaySmall: withStyle(base.displaySmall),
    headlineLarge: withStyle(base.headlineLarge),
    headlineMedium: withStyle(base.headlineMedium),
    headlineSmall: withStyle(base.headlineSmall),
    titleLarge: withStyle(base.titleLarge),
    titleMedium: withStyle(base.titleMedium),
    titleSmall: withStyle(base.titleSmall),
    bodyLarge: withStyle(base.bodyLarge),
    bodyMedium: withStyle(base.bodyMedium),
    bodySmall: withStyle(base.bodySmall),
    labelLarge: withStyle(base.labelLarge),
    labelMedium: withStyle(base.labelMedium),
    labelSmall: withStyle(base.labelSmall),
  );
}

TextTheme _applyFamilyWithFallback(
  TextTheme base,
  String family,
  List<String> fallback,
) {
  final withMonoFallback = <String>[...fallback, ..._monoFallback];
  TextStyle? withStyle(TextStyle? s) =>
      s?.copyWith(fontFamily: family, fontFamilyFallback: withMonoFallback);
  return base.copyWith(
    displayLarge: withStyle(base.displayLarge),
    displayMedium: withStyle(base.displayMedium),
    displaySmall: withStyle(base.displaySmall),
    headlineLarge: withStyle(base.headlineLarge),
    headlineMedium: withStyle(base.headlineMedium),
    headlineSmall: withStyle(base.headlineSmall),
    titleLarge: withStyle(base.titleLarge),
    titleMedium: withStyle(base.titleMedium),
    titleSmall: withStyle(base.titleSmall),
    bodyLarge: withStyle(base.bodyLarge),
    bodyMedium: withStyle(base.bodyMedium),
    bodySmall: withStyle(base.bodySmall),
    labelLarge: withStyle(base.labelLarge),
    labelMedium: withStyle(base.labelMedium),
    labelSmall: withStyle(base.labelSmall),
  );
}

TextTheme _applyFamily(TextTheme base, String family, List<String> fallback) {
  TextStyle? withStyle(TextStyle? s) =>
      s?.copyWith(fontFamily: family, fontFamilyFallback: fallback);
  return base.copyWith(
    displayLarge: withStyle(base.displayLarge),
    displayMedium: withStyle(base.displayMedium),
    displaySmall: withStyle(base.displaySmall),
    headlineLarge: withStyle(base.headlineLarge),
    headlineMedium: withStyle(base.headlineMedium),
    headlineSmall: withStyle(base.headlineSmall),
    titleLarge: withStyle(base.titleLarge),
    titleMedium: withStyle(base.titleMedium),
    titleSmall: withStyle(base.titleSmall),
    bodyLarge: withStyle(base.bodyLarge),
    bodyMedium: withStyle(base.bodyMedium),
    bodySmall: withStyle(base.bodySmall),
    labelLarge: withStyle(base.labelLarge),
    labelMedium: withStyle(base.labelMedium),
    labelSmall: withStyle(base.labelSmall),
  );
}

ThemeData applyFontPack(ThemeData base, ReaderFontPack pack) {
  final fallback = chineseTextFallback();
  switch (pack) {
    case ReaderFontPack.system:
      return base.copyWith(
        textTheme: _applyFallbackOnly(base.textTheme, fallback),
        primaryTextTheme: _applyFallbackOnly(base.primaryTextTheme, fallback),
      );
    case ReaderFontPack.inter:
      return base.copyWith(
        textTheme: _applyFamily(base.textTheme, 'Inter', fallback),
        primaryTextTheme: _applyFamily(
          base.primaryTextTheme,
          'Inter',
          fallback,
        ),
      );
    case ReaderFontPack.merriweather:
      return base.copyWith(
        textTheme: _applyFamily(base.textTheme, 'Merriweather', fallback),
        primaryTextTheme: _applyFamily(
          base.primaryTextTheme,
          'Merriweather',
          fallback,
        ),
      );
  }
}

/// Applies a custom font family override if provided; otherwise uses the selected font pack.
ThemeData applyFontPackOrCustom(
  ThemeData base,
  ReaderFontPack pack,
  String? customFamily,
) {
  final fallback = chineseTextFallback();
  final family = trimToNull(customFamily);
  if (family != null) {
    final withFamily = _applyFamilyWithFallback(
      base.textTheme,
      family,
      fallback,
    );
    final withFamilyPrimary = _applyFamilyWithFallback(
      base.primaryTextTheme,
      family,
      fallback,
    );
    return base.copyWith(
      textTheme: withFamily,
      primaryTextTheme: withFamilyPrimary,
    );
  }
  return applyFontPack(base, pack);
}

Future<void> preloadEmbeddedChineseFonts() async {
  // We preload fonts on all platforms including web to ensure
  // consistent display and avoid tofu/squares.
  if (_preloadEmbeddedChineseFontsFuture != null) {
    return _preloadEmbeddedChineseFontsFuture!;
  }
  _preloadEmbeddedChineseFontsFuture = () async {
    try {
      // 1. Try loading from local assets (fastest, works offline)
      // Note: We use 'Noto Sans SC' with spaces to match pubspec.yaml and common usage
      final loader = FontLoader(embeddedChineseSansFamily);
      loader.addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'));
      loader.addFont(rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'));
      await loader.load();
    } catch (e) {
      debugPrint('Error loading embedded Chinese fonts from assets: $e');
    }

    try {
      // 2. Ensure Google Fonts package also loads it (as backup)
      await GoogleFonts.pendingFonts([GoogleFonts.notoSansSc()]);
    } catch (e) {
      debugPrint('Error loading Google Fonts pending fonts: $e');
    }
  }();
  return _preloadEmbeddedChineseFontsFuture!;
}

Future<void>? _preloadEmbeddedChineseFontsFuture;
