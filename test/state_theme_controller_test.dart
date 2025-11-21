import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'package:novel_reader/theme/themes.dart';
import 'package:novel_reader/theme/reader_typography.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeController initializes with defaults', () async {
    final prefs = await SharedPreferences.getInstance();
    final ctrl = ThemeController(prefs);
    expect(ctrl.state.mode, ThemeMode.system);
    expect(ctrl.state.family, AppThemeFamily.sepia);
    expect(ctrl.state.customFontFamily, 'Consolas');
    expect(ctrl.state.preset, ReaderTypographyPreset.system);
  });

  test('setMode and setFamily persist', () async {
    final prefs = await SharedPreferences.getInstance();
    final ctrl = ThemeController(prefs);
    ctrl.setMode(ThemeMode.dark);
    ctrl.setFamily(AppThemeFamily.nord);
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getString('light_theme'), 'nord');
  });

  test('setFontScale clamps and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final ctrl = ThemeController(prefs);
    ctrl.setFontScale(10.0);
    expect(ctrl.state.fontScale, 3.2);
    expect(prefs.getDouble('reader_font_scale'), 3.2);
  });

  test('separate dark toggling adjusts dark family', () async {
    final prefs = await SharedPreferences.getInstance();
    final ctrl = ThemeController(prefs);
    ctrl.setFamily(AppThemeFamily.solarized);
    ctrl.setSeparateDark(true);
    expect(ctrl.state.hasSeparateDark, true);
    ctrl.setFamilyDark(AppThemeFamily.nord);
    ctrl.setSeparateDark(false);
    expect(ctrl.state.familyDark, ctrl.state.family);
  });

  test('separate typography off aligns presets', () async {
    final prefs = await SharedPreferences.getInstance();
    final ctrl = ThemeController(prefs);
    ctrl.setPreset(ReaderTypographyPreset.compact);
    ctrl.setSeparateTypography(false);
    expect(ctrl.state.presetLight, ReaderTypographyPreset.compact);
    expect(ctrl.state.presetDark, ReaderTypographyPreset.compact);
  });
}
