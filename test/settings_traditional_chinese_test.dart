import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/screens/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/theme_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Traditional Chinese (zh-TW) locale loads correctly', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', 'zh-TW');

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: container.read(appSettingsProvider),
          theme: ThemeData(useMaterial3: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final locale = container.read(appSettingsProvider);
    expect(locale.languageCode, 'zh');
    expect(locale.countryCode, 'TW');
    expect(locale.toLanguageTag(), 'zh-TW');
  });

  testWidgets('Switching to Traditional Chinese updates the app locale', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final langLabel = find.text('App Language');
    final langTile = find.ancestor(
      of: langLabel,
      matching: find.byType(ListTile),
    );
    final langDropdown = find.descendant(
      of: langTile,
      matching: find.byType(DropdownButton<String>),
    );
    expect(langDropdown, findsOneWidget);
    await tester.tap(langDropdown);
    await tester.pumpAndSettle();

    final traditionalChineseOption = find.text('繁體');
    expect(traditionalChineseOption, findsOneWidget);
    await tester.tap(traditionalChineseOption);
    await tester.pumpAndSettle();

    final locale = container.read(appSettingsProvider);
    expect(locale.languageCode, 'zh');
    expect(locale.countryCode, 'TW');
    expect(locale.toLanguageTag(), 'zh-TW');
  });
}
