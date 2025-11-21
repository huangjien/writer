import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/settings_screen.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/theme_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen shows localized Reduce Motion in en locale', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs); // defaults to 'en'
    final themeController = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Minimize animations for motion comfort'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows localized Reduce Motion in zh locale', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    appNotifier.setLanguage('zh');
    final themeController = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Chinese translations
    expect(find.text('减少动效'), findsOneWidget);
    expect(find.text('为舒适体验尽量减少动画'), findsOneWidget);
  });
}
