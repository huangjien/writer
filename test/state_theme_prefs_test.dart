import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/theme_prefs.dart';
import 'package:flutter/material.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';

void main() {
  test('encode/decode ThemeMode', () {
    expect(encodeMode(ThemeMode.light), 'light');
    expect(encodeMode(ThemeMode.dark), 'dark');
    expect(encodeMode(ThemeMode.system), 'system');
    expect(decodeMode('light'), ThemeMode.light);
    expect(decodeMode('dark'), ThemeMode.dark);
    expect(decodeMode('system'), ThemeMode.system);
    expect(decodeMode(null), ThemeMode.system);
    expect(decodeMode('unknown'), ThemeMode.system);
  });

  test('encode/decode AppThemeFamily', () {
    expect(encodeFamily(AppThemeFamily.defaultFamily), 'light');
    expect(encodeFamily(AppThemeFamily.sepia), 'sepia');
    expect(encodeFamily(AppThemeFamily.emerald), 'emerald');
    expect(encodeFamily(AppThemeFamily.contrast), 'contrast');
    expect(encodeFamily(AppThemeFamily.solarizedTan), 'solarizedTan');
    expect(encodeFamily(AppThemeFamily.nord), 'nord');
    expect(encodeFamily(AppThemeFamily.nordFrost), 'nordFrost');
    expect(decodeFamily('light'), AppThemeFamily.defaultFamily);
    expect(decodeFamily('sepia'), AppThemeFamily.sepia);
    expect(decodeFamily('emerald'), AppThemeFamily.emerald);
    expect(decodeFamily('emeraldGreen'), AppThemeFamily.emerald);
    expect(decodeFamily('contrast'), AppThemeFamily.contrast);
    expect(decodeFamily('highContrast'), AppThemeFamily.contrast);
    expect(decodeFamily('solarizedTan'), AppThemeFamily.solarizedTan);
    expect(decodeFamily('nord'), AppThemeFamily.nord);
    expect(decodeFamily('nordFrost'), AppThemeFamily.nordFrost);
    expect(decodeFamily(null), AppThemeFamily.defaultFamily);
    expect(decodeFamily('unknown'), AppThemeFamily.defaultFamily);
  });

  test('encode/decode ReaderTypographyPreset', () {
    expect(encodePreset(ReaderTypographyPreset.system), 'system');
    expect(encodePreset(ReaderTypographyPreset.comfortable), 'comfortable');
    expect(encodePreset(ReaderTypographyPreset.compact), 'compact');
    expect(encodePreset(ReaderTypographyPreset.serifLike), 'serifLike');
    expect(decodePreset('system'), ReaderTypographyPreset.system);
    expect(decodePreset('comfortable'), ReaderTypographyPreset.comfortable);
    expect(decodePreset('compact'), ReaderTypographyPreset.compact);
    expect(decodePreset('serifLike'), ReaderTypographyPreset.serifLike);
    expect(decodePreset(null), ReaderTypographyPreset.system);
    expect(decodePreset('unknown'), ReaderTypographyPreset.system);
    expect(tryDecodePreset(null), isNull);
    expect(tryDecodePreset('compact'), ReaderTypographyPreset.compact);
  });

  test('encode/decode ReaderFontPack', () {
    expect(encodeFontPack(ReaderFontPack.system), 'system');
    expect(encodeFontPack(ReaderFontPack.inter), 'inter');
    expect(encodeFontPack(ReaderFontPack.merriweather), 'merriweather');
    expect(decodeFontPack('system'), ReaderFontPack.system);
    expect(decodeFontPack('inter'), ReaderFontPack.inter);
    expect(decodeFontPack('merriweather'), ReaderFontPack.merriweather);
    expect(decodeFontPack(null), ReaderFontPack.system);
    expect(decodeFontPack('unknown'), ReaderFontPack.system);
  });

  test('encode/decode ReaderBackgroundDepth', () {
    expect(encodeBgDepth(ReaderBackgroundDepth.low), 'low');
    expect(encodeBgDepth(ReaderBackgroundDepth.medium), 'medium');
    expect(encodeBgDepth(ReaderBackgroundDepth.high), 'high');
    expect(decodeBgDepth('low'), ReaderBackgroundDepth.low);
    expect(decodeBgDepth('medium'), ReaderBackgroundDepth.medium);
    expect(decodeBgDepth('high'), ReaderBackgroundDepth.high);
    expect(decodeBgDepth(null), ReaderBackgroundDepth.medium);
    expect(decodeBgDepth('unknown'), ReaderBackgroundDepth.medium);
  });
}
