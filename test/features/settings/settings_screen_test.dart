import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/ai_service_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen shows all sections', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Use the first scrollable (vertical list)
    final scrollable = find.byType(Scrollable).at(0);

    // App Settings (visible at top)
    expect(find.byType(AppSettingsSection), findsOneWidget);

    // Palette
    final palette = find.byType(PaletteSettingsSection);
    await tester.scrollUntilVisible(palette, 500, scrollable: scrollable);
    expect(palette, findsOneWidget);

    // AI Configurations section removed; ensure other sections still render

    // Supabase
    final supabase = find.byType(SupabaseSection);
    await tester.scrollUntilVisible(supabase, 500, scrollable: scrollable);
    expect(supabase, findsOneWidget);

    // TTS
    final tts = find.byType(TtsSettingsContainer);
    await tester.scrollUntilVisible(tts, 500, scrollable: scrollable);
    expect(tts, findsOneWidget);
  });
}
