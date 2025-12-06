import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/reader_background.dart';

void main() {
  group('ReaderBackground Tests', () {
    test('readerBackgroundColor returns correct color for low depth', () {
      const scheme = ColorScheme.light();
      final color = readerBackgroundColor(scheme, ReaderBackgroundDepth.low);
      expect(color, scheme.surface);
    });

    test('readerBackgroundColor returns correct color for medium depth', () {
      const scheme = ColorScheme.light();
      final color = readerBackgroundColor(scheme, ReaderBackgroundDepth.medium);
      expect(color, scheme.surfaceContainerHigh);
    });

    test('readerBackgroundColor returns correct color for high depth', () {
      const scheme = ColorScheme.light();
      final color = readerBackgroundColor(scheme, ReaderBackgroundDepth.high);
      expect(color, scheme.surfaceContainerHighest);
    });
  });
}
