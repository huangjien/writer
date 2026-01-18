import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/font_packs.dart';

void main() {
  group('ReaderFontPack', () {
    test('enum values are correct', () {
      expect(ReaderFontPack.values, hasLength(3));
      expect(ReaderFontPack.values, contains(ReaderFontPack.system));
      expect(ReaderFontPack.values, contains(ReaderFontPack.inter));
      expect(ReaderFontPack.values, contains(ReaderFontPack.merriweather));
    });
  });

  group('applyFontPack', () {
    late ThemeData baseTheme;

    setUp(() {
      disableGoogleFontsForTesting = true;
      baseTheme = ThemeData.light();
    });

    tearDown(() {
      disableGoogleFontsForTesting = false;
    });

    test('system pack returns unchanged theme', () {
      final result = applyFontPack(baseTheme, ReaderFontPack.system);

      expect(result.primaryColor, baseTheme.primaryColor);
      expect(result.brightness, baseTheme.brightness);
      expect(
        result.textTheme.bodyLarge?.fontFamily,
        baseTheme.textTheme.bodyLarge?.fontFamily,
      );
      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
    });

    test('inter pack applies Inter font family', () {
      final result = applyFontPack(baseTheme, ReaderFontPack.inter);

      expect(result.textTheme.displayLarge?.fontFamily, equals('Inter'));
      expect(result.textTheme.bodyLarge?.fontFamily, equals('Inter'));
      expect(result.textTheme.labelSmall?.fontFamily, equals('Inter'));
    });

    test('inter pack applies fallbacks', () {
      final result = applyFontPack(baseTheme, ReaderFontPack.inter);

      expect(result.textTheme.displayLarge?.fontFamilyFallback, isNotNull);
      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
    });

    test('merriweather pack applies Merriweather font family', () {
      final result = applyFontPack(baseTheme, ReaderFontPack.merriweather);

      expect(result.textTheme.displayLarge?.fontFamily, equals('Merriweather'));
      expect(result.textTheme.bodyLarge?.fontFamily, equals('Merriweather'));
      expect(result.textTheme.labelSmall?.fontFamily, equals('Merriweather'));
    });

    test('merriweather pack applies fallbacks', () {
      final result = applyFontPack(baseTheme, ReaderFontPack.merriweather);

      expect(result.textTheme.displayLarge?.fontFamilyFallback, isNotNull);
      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
    });

    test('pack application preserves other theme properties', () {
      final customTheme = baseTheme.copyWith(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
      );

      final result = applyFontPack(customTheme, ReaderFontPack.inter);

      expect(result.primaryColor, equals(Colors.red));
      expect(result.brightness, equals(Brightness.dark));
      expect(result.textTheme.bodyLarge?.fontFamily, equals('Inter'));
    });
  });

  group('applyFontPackOrCustom', () {
    late ThemeData baseTheme;

    setUp(() {
      disableGoogleFontsForTesting = true;
      baseTheme = ThemeData.light();
    });

    tearDown(() {
      disableGoogleFontsForTesting = false;
    });

    test('null custom family uses pack', () {
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.inter,
        null,
      );

      expect(result.textTheme.bodyLarge?.fontFamily, equals('Inter'));
      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
    });

    test('empty custom family uses pack', () {
      final result = applyFontPackOrCustom(baseTheme, ReaderFontPack.inter, '');

      expect(result.textTheme.bodyLarge?.fontFamily, equals('Inter'));
    });

    test('whitespace-only custom family uses pack', () {
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.inter,
        '   ',
      );

      expect(result.textTheme.bodyLarge?.fontFamily, equals('Inter'));
    });

    test('valid custom family applies with fallbacks', () {
      const customFamily = 'Custom Font';
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.system,
        customFamily,
      );

      expect(result.textTheme.bodyLarge?.fontFamily, equals(customFamily));
      expect(result.textTheme.displayLarge?.fontFamily, equals(customFamily));
      expect(result.textTheme.labelSmall?.fontFamily, equals(customFamily));
    });

    test('custom family applies fallbacks', () {
      const customFamily = 'Custom Font';
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.system,
        customFamily,
      );

      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
      expect(result.textTheme.displayLarge?.fontFamilyFallback, isNotNull);
    });

    test('custom family overrides pack setting', () {
      const customFamily = 'Custom Font';
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.inter,
        customFamily,
      );

      expect(result.textTheme.bodyLarge?.fontFamily, equals(customFamily));
      expect(result.textTheme.bodyLarge?.fontFamily, isNot(equals('Inter')));
    });

    test('custom family with special characters', () {
      const customFamily = 'Fira Code';
      final result = applyFontPackOrCustom(
        baseTheme,
        ReaderFontPack.system,
        customFamily,
      );

      expect(result.textTheme.bodyLarge?.fontFamily, equals(customFamily));
      expect(result.textTheme.bodyLarge?.fontFamilyFallback, isNotNull);
    });
  });
}
