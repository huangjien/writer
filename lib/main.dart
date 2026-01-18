import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_settings.dart';
import 'state/ai_service_settings.dart';
import 'state/theme_controller.dart';
import 'state/ui_style_controller.dart';
import 'state/tts_settings.dart';
import 'state/admin_settings.dart';
import 'state/storage_service_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettingsNotifier(prefs);
  final themeController = ThemeController(prefs);
  final uiStyleController = UiStyleController(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);
  final aiService = AiServiceNotifier(prefs);
  final adminMode = AdminModeNotifier(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appSettingsProvider.overrideWith((_) => appSettings),
        themeControllerProvider.overrideWith((_) => themeController),
        uiStyleControllerProvider.overrideWith((_) => uiStyleController),
        ttsSettingsProvider.overrideWith((_) => ttsSettings),
        aiServiceProvider.overrideWith((_) => aiService),
        adminModeProvider.overrideWith((_) => adminMode),
      ],
      child: const App(),
    ),
  );
}
