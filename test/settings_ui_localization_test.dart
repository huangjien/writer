import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';

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
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
          motionSettingsProvider.overrideWith(
            (_) => MotionSettingsNotifier(prefs),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
          motionSettingsProvider.overrideWith(
            (_) => MotionSettingsNotifier(prefs),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Chinese translations
    expect(find.text('减少动效'), findsOneWidget);
    expect(find.text('为舒适体验尽量减少动画'), findsOneWidget);
  });
}
