import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/widgets/palette_settings_section.dart';
import 'package:novel_reader/state/theme_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PaletteSettingsSection shows color theme when unified', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeControllerProvider.overrideWith((_) => theme)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: PaletteSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Use separate dark palette'), findsOneWidget);
    expect(find.text('Color Theme'), findsOneWidget);
  });

  testWidgets('PaletteSettingsSection shows split palettes when enabled', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeController(prefs);
    theme.setSeparateDark(true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeControllerProvider.overrideWith((_) => theme)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: PaletteSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Light Palette'), findsOneWidget);
    expect(find.text('Dark Palette'), findsOneWidget);
  });
}
