import 'package:flutter/material.dart';

/// Reader typography presets independent from color palettes.
enum ReaderTypographyPreset { system, comfortable, compact, serifLike }

ThemeData applyReaderTypography(ThemeData base, ReaderTypographyPreset preset) {
  final t = base.textTheme;

  TextTheme adjust({
    double? bodyHeight,
    double? titleHeight,
    String? fontFamily,
  }) {
    return t.copyWith(
      bodyLarge: t.bodyLarge?.copyWith(
        height: bodyHeight,
        fontFamily: fontFamily,
      ),
      bodyMedium: t.bodyMedium?.copyWith(
        height: bodyHeight,
        fontFamily: fontFamily,
      ),
      bodySmall: t.bodySmall?.copyWith(
        height: bodyHeight,
        fontFamily: fontFamily,
      ),
      titleLarge: t.titleLarge?.copyWith(
        height: titleHeight,
        fontFamily: fontFamily,
      ),
      titleMedium: t.titleMedium?.copyWith(
        height: titleHeight,
        fontFamily: fontFamily,
      ),
      titleSmall: t.titleSmall?.copyWith(
        height: titleHeight,
        fontFamily: fontFamily,
      ),
    );
  }

  switch (preset) {
    case ReaderTypographyPreset.system:
      return base; // keep defaults
    case ReaderTypographyPreset.comfortable:
      return base.copyWith(
        textTheme: adjust(bodyHeight: 1.6, titleHeight: 1.3),
      );
    case ReaderTypographyPreset.compact:
      return base.copyWith(
        textTheme: adjust(bodyHeight: 1.3, titleHeight: 1.2),
      );
    case ReaderTypographyPreset.serifLike:
      // Avoid assuming custom fonts are available; set only line height.
      // If you later add fonts (e.g., Merriweather), set fontFamily here.
      return base.copyWith(
        textTheme: adjust(bodyHeight: 1.5, titleHeight: 1.25),
      );
  }
}
