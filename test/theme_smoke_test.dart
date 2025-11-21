import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/theme/themes.dart';

void main() {
  test('Theme builders return Material3 with correct brightness', () {
    final light = themeForLight(AppThemeFamily.sepia);
    final dark = themeForDark(AppThemeFamily.sepia);
    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.colorScheme.brightness.name, 'light');
    expect(dark.colorScheme.brightness.name, 'dark');
    final hcLight = themeForLight(AppThemeFamily.highContrast);
    final hcDark = themeForDark(AppThemeFamily.highContrast);
    expect(hcLight.colorScheme.brightness.name, 'light');
    expect(hcDark.colorScheme.brightness.name, 'dark');
  });
}
