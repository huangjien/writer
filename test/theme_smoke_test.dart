import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:novel_reader/theme/themes.dart';
import 'package:novel_reader/theme/reader_typography.dart';
import 'package:novel_reader/theme/font_packs.dart';

void main() {
  test('Theme functions produce non-null ThemeData', () {
    final light = themeForLight(AppThemeFamily.defaultFamily);
    final dark = themeForDark(AppThemeFamily.defaultFamily);
    expect(light, isA<ThemeData>());
    expect(dark, isA<ThemeData>());

    final withFont = applyFontPackOrCustom(light, ReaderFontPack.system, null);
    final withTypography = applyReaderTypography(
      withFont,
      ReaderTypographyPreset.system,
    );
    expect(withTypography, isA<ThemeData>());
  });
}
