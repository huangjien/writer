import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';
import 'state/ai_service_settings.dart';
import 'repositories/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_settings.dart';
import 'state/theme_controller.dart';
import 'state/tts_settings.dart';
import 'state/admin_settings.dart';
import 'state/providers.dart';

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  final vectorService = ref.watch(vectorServiceProvider);
  return LocalStorageRepository(vectorService: vectorService);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  if (supabaseEnabled) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettingsNotifier(prefs);
  final themeController = ThemeController(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);
  final aiService = AiServiceNotifier(prefs);
  final adminMode = AdminModeNotifier(prefs);

  runApp(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((_) => appSettings),
        themeControllerProvider.overrideWith((_) => themeController),
        ttsSettingsProvider.overrideWith((_) => ttsSettings),
        aiServiceProvider.overrideWith((_) => aiService),
        adminModeProvider.overrideWith((_) => adminMode),
      ],
      child: const App(),
    ),
  );
}
