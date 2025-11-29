import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/widgets/tts_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  testWidgets('TtsSettingsSection renders correctly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TtsSettingsSection(
              voiceItems: [],
              uniqueVoices: {},
              voiceKey: (v) => '',
              loadingVoices: false,
              loadingLocales: false,
              effectiveSelectedKey: null,
              filteredLocales: [],
              effectiveSelectedLocale: null,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TTS Settings'), findsOneWidget);
    expect(find.text('TTS Voice'), findsOneWidget);
    expect(find.text('TTS Language'), findsOneWidget);
    expect(find.text('Speech Rate'), findsOneWidget);
    expect(find.text('Speech Volume'), findsOneWidget);
  });

  testWidgets('Adjusting rate and volume sliders updates TTS settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifier = TtsSettingsNotifier(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [ttsSettingsProvider.overrideWith((_) => notifier)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TtsSettingsSection(
              voiceItems: const [],
              uniqueVoices: const {},
              voiceKey: (v) => '',
              loadingVoices: false,
              loadingLocales: false,
              effectiveSelectedKey: null,
              filteredLocales: const [],
              effectiveSelectedLocale: null,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final sliders = find.byType(Slider);
    expect(sliders, findsWidgets);
    await tester.drag(sliders.first, const Offset(30, 0));
    await tester.pump();
    expect(notifier.state.rate, isNot(0.45));

    await tester.drag(sliders.last, const Offset(-30, 0));
    await tester.pump();
    expect(notifier.state.volume, isNot(1.0));
  });
}
