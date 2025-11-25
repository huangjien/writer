import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/reader_typography.dart';

void main() {
  group('ReaderTypography', () {
    test('applyReaderTypography returns original theme for system preset', () {
      final base = ThemeData.light();
      final result = applyReaderTypography(base, ReaderTypographyPreset.system);

      expect(result, base);
    });

    test('applyReaderTypography applies comfortable preset settings', () {
      final base = ThemeData.light();
      final result = applyReaderTypography(
        base,
        ReaderTypographyPreset.comfortable,
      );

      final t = result.textTheme;
      expect(t.bodyLarge?.height, 1.6);
      expect(t.titleLarge?.height, 1.3);
      // Ensure it's not the same instance if it was modified
      expect(result, isNot(base));
    });

    test('applyReaderTypography applies compact preset settings', () {
      final base = ThemeData.light();
      final result = applyReaderTypography(
        base,
        ReaderTypographyPreset.compact,
      );

      final t = result.textTheme;
      expect(t.bodyLarge?.height, 1.3);
      expect(t.titleLarge?.height, 1.2);
    });

    test('applyReaderTypography applies serifLike preset settings', () {
      final base = ThemeData.light();
      final result = applyReaderTypography(
        base,
        ReaderTypographyPreset.serifLike,
      );

      final t = result.textTheme;
      expect(t.bodyLarge?.height, 1.5);
      expect(t.titleLarge?.height, 1.25);
    });

    test(
      'applyReaderTypography preserves existing text styles except height',
      () {
        final base = ThemeData.light().copyWith(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 20, color: Colors.red),
          ),
        );

        final result = applyReaderTypography(
          base,
          ReaderTypographyPreset.comfortable,
        );

        final t = result.textTheme;
        expect(t.bodyLarge?.height, 1.6);
        expect(t.bodyLarge?.fontSize, 20);
        expect(t.bodyLarge?.color, Colors.red);
      },
    );
  });
}
