import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';

void main() {
  test('Theme functions produce non-null ThemeData', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final light = themeForLight(AppThemeFamily.modernMinimalist);
    final dark = themeForDark(AppThemeFamily.modernMinimalist);
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
