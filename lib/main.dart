import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'state/supabase_config.dart';
import 'repositories/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_settings.dart';
import 'state/theme_controller.dart';
import 'state/tts_settings.dart';

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  return LocalStorageRepository();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseEnabled) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettingsNotifier(prefs);
  final themeController = ThemeController(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);

  runApp(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((_) => appSettings),
        themeControllerProvider.overrideWith((_) => themeController),
        ttsSettingsProvider.overrideWith((_) => ttsSettings),
      ],
      child: const App(),
    ),
  );
}
