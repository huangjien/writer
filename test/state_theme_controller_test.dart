import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';

void main() {
  test('ThemeController initializes with defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final theme = container.read(themeControllerProvider);
    expect(theme.mode, ThemeMode.system);
    expect(theme.family, AppThemeFamily.modernMinimalist);
    expect(theme.customFontFamily, null);
    expect(theme.preset, ReaderTypographyPreset.system);
  });

  test('setMode and setFamily persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(themeControllerProvider.notifier);
    await notifier.setMode(ThemeMode.dark);
    await notifier.setFamily(AppThemeFamily.oceanDepths);
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getString('light_theme'), 'oceanDepths');
  });

  test('setFontScale clamps and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(themeControllerProvider.notifier);
    await notifier.setFontScale(10.0);
    final theme = container.read(themeControllerProvider);
    expect(theme.fontScale, 3.2);
    expect(prefs.getDouble('reader_font_scale'), 3.2);
  });

  test('separate dark toggling adjusts dark family', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(themeControllerProvider.notifier);
    await notifier.setFamily(AppThemeFamily.goldenHour);
    await notifier.setSeparateDark(true);
    var theme = container.read(themeControllerProvider);
    expect(theme.hasSeparateDark, true);
    await notifier.setFamilyDark(AppThemeFamily.midnightGalaxy);
    await notifier.setSeparateDark(false);
    theme = container.read(themeControllerProvider);
    expect(theme.familyDark, theme.family);
  });

  test('separate typography off aligns presets', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(themeControllerProvider.notifier);
    await notifier.setPreset(ReaderTypographyPreset.compact);
    await notifier.setSeparateTypography(false);
    final theme = container.read(themeControllerProvider);
    expect(theme.presetLight, ReaderTypographyPreset.compact);
    expect(theme.presetDark, ReaderTypographyPreset.compact);
  });
}
