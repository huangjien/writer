import 'package:flutter/material.dart';
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

const List<String> _textFallback = <String>[
  'Noto Sans SC',
  'Noto Sans',
  'Roboto',
  'PingFang SC',
  'Hiragino Sans GB',
  'Microsoft YaHei',
  'Heiti SC',
  'SimHei',
  'Arial Unicode MS',
  'sans-serif',
];

TextTheme _applyFamilyWithFallback(TextTheme base, String family) {
  List<String> fallback = <String>[..._textFallback, ..._monoFallback];
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

TextTheme _applyFamily(TextTheme base, String family) {
  TextStyle? withStyle(TextStyle? s) =>
      s?.copyWith(fontFamily: family, fontFamilyFallback: _textFallback);
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
  switch (pack) {
    case ReaderFontPack.system:
      return base; // No change
    case ReaderFontPack.inter:
      return base.copyWith(textTheme: _applyFamily(base.textTheme, 'Inter'));
    case ReaderFontPack.merriweather:
      return base.copyWith(
        textTheme: _applyFamily(base.textTheme, 'Merriweather'),
      );
  }
}

/// Applies a custom font family override if provided; otherwise uses the selected font pack.
ThemeData applyFontPackOrCustom(
  ThemeData base,
  ReaderFontPack pack,
  String? customFamily,
) {
  final family = trimToNull(customFamily);
  if (family != null) {
    // Apply specified fontFamily with graceful monospace fallbacks across the TextTheme.
    final withFamily = _applyFamilyWithFallback(base.textTheme, family);
    return base.copyWith(textTheme: withFamily);
  }
  return applyFontPack(base, pack);
}
