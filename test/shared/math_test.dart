import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/shared/math.dart';

void main() {
  group('Math Utilities', () {
    test('clampDouble clamps values correctly', () {
      expect(clampDouble(5.0, 0.0, 10.0), 5.0);
      expect(clampDouble(-5.0, 0.0, 10.0), 0.0);
      expect(clampDouble(15.0, 0.0, 10.0), 10.0);
    });

    test('clampInt clamps values correctly', () {
      expect(clampInt(5, 0, 10), 5);
      expect(clampInt(-5, 0, 10), 0);
      expect(clampInt(15, 0, 10), 10);
    });

    test('clamp01 clamps values between 0.0 and 1.0', () {
      expect(clamp01(0.5), 0.5);
      expect(clamp01(-0.5), 0.0);
      expect(clamp01(1.5), 1.0);
    });
  });
}
