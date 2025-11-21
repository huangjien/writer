import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/theme/design_tokens.dart';

void main() {
  test('Design tokens provide spacing and radii', () {
    expect(Spacing.s, isA<double>());
    expect(Radii.s, isA<double>());
  });
}
