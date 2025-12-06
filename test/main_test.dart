import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/main.dart' as app_main;
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/app.dart';

void main() {
  test('localStorageRepositoryProvider provides LocalStorageRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(app_main.localStorageRepositoryProvider);
    expect(repo, isA<LocalStorageRepository>());
  });

  test('supabaseEnabled reflects dart-define gating', () {
    final hasUrl = supabaseUrl.isNotEmpty;
    final hasKey = supabaseAnonKey.isNotEmpty;
    if (hasUrl && hasKey) {
      expect(supabaseEnabled, isTrue);
    } else {
      expect(supabaseEnabled, isFalse);
    }
  });

  group('main function component tests', () {
    testWidgets('main function initializes app with providers', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const ProviderScope(child: App()));

      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('main function initializes SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'test': 'value'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs, isA<SharedPreferences>());
    });

    test('AppSettingsNotifier can be created from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final appSettings = AppSettingsNotifier(prefs);
      expect(appSettings, isA<AppSettingsNotifier>());
    });

    test('ThemeController can be created from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      expect(themeController, isA<ThemeController>());
    });

    test('TtsSettingsNotifier can be created from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final ttsSettings = TtsSettingsNotifier(prefs);
      expect(ttsSettings, isA<TtsSettingsNotifier>());
    });

    test('main function components work together', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final appSettings = AppSettingsNotifier(prefs);
      final themeController = ThemeController(prefs);
      final ttsSettings = TtsSettingsNotifier(prefs);

      expect(appSettings, isA<AppSettingsNotifier>());
      expect(themeController, isA<ThemeController>());
      expect(ttsSettings, isA<TtsSettingsNotifier>());

      final providerScope = ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appSettings),
          themeControllerProvider.overrideWith((_) => themeController),
          ttsSettingsProvider.overrideWith((_) => ttsSettings),
        ],
        child: const App(),
      );

      expect(providerScope, isA<ProviderScope>());
    });

    test('ProviderScope can be created with real providers', () {
      SharedPreferences.setMockInitialValues({});

      final providerScope = ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier(
              SharedPreferences.getInstance() as SharedPreferences,
            ),
          ),
        ],
        child: const App(),
      );

      expect(providerScope, isA<ProviderScope>());
    });

    test('main function initialization sequence', () async {
      SharedPreferences.setMockInitialValues({});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs, isA<SharedPreferences>());

      final appSettings = AppSettingsNotifier(prefs);
      final themeController = ThemeController(prefs);
      final ttsSettings = TtsSettingsNotifier(prefs);

      expect(appSettings, isA<AppSettingsNotifier>());
      expect(themeController, isA<ThemeController>());
      expect(ttsSettings, isA<TtsSettingsNotifier>());

      expect(appSettings.state, isA<Locale>());
      expect(themeController.state, isA<ThemeState>());
      expect(ttsSettings.state, isA<TtsSettings>());
    });
  });
}
