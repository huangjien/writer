import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login/logout not shown when signed out', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);
    final aiService = AiServiceNotifier(prefs);
    final motion = MotionSettingsNotifier(null);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          appSettingsProvider.overrideWith((ref) => appSettings),
          themeControllerProvider.overrideWith((ref) => themeController),
          aiServiceProvider.overrideWith((ref) => aiService),
          motionSettingsProvider.overrideWith((ref) => motion),
          ttsSettingsProvider.overrideWith((ref) => ttsSettings),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.login), findsNothing);
    expect(find.byIcon(Icons.logout), findsNothing);
  });
}
