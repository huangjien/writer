import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'state/ai_service_settings.dart';
import 'repositories/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_settings.dart';
import 'state/theme_controller.dart';
import 'state/tts_settings.dart';
import 'state/admin_settings.dart';
import 'state/session_state.dart';

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  // final vectorService = ref.watch(vectorServiceProvider);
  return LocalStorageRepository();
});

Future<void> _preloadFonts() async {
  final noto = FontLoader('Noto Sans SC')
    ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'));
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf'));
  final merri = FontLoader('Merriweather')
    ..addFont(rootBundle.load('assets/fonts/Merriweather-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Merriweather-Bold.ttf'));
  await Future.wait([noto.load(), inter.load(), merri.load()]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _preloadFonts();

  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettingsNotifier(prefs);
  final themeController = ThemeController(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);
  final aiService = AiServiceNotifier(prefs);
  final adminMode = AdminModeNotifier(prefs);
  final session = SessionNotifier(prefs);

  runApp(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((_) => appSettings),
        themeControllerProvider.overrideWith((_) => themeController),
        ttsSettingsProvider.overrideWith((_) => ttsSettings),
        aiServiceProvider.overrideWith((_) => aiService),
        adminModeProvider.overrideWith((_) => adminMode),
        sessionProvider.overrideWith((_) => session),
      ],
      child: const App(),
    ),
  );
}
