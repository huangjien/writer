import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/tts_settings_section.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  testWidgets('TtsSettingsSection renders voice, language, rate, and volume', (
    tester,
  ) async {
    final voices = [
      {'identifier': 'en-US-1', 'name': 'English Voice 1', 'locale': 'en-US'},
      {'identifier': 'en-US-2', 'name': 'English Voice 2', 'locale': 'en-US'},
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TtsSettingsSection(
                voiceItems: voices,
                uniqueVoices: {'en-US-1': voices[0], 'en-US-2': voices[1]},
                voiceKey: (v) => v['identifier'] as String? ?? '',
                loadingVoices: false,
                loadingLocales: false,
                effectiveSelectedKey: null,
                filteredLocales: const ['en-US', 'en-GB'],
                effectiveSelectedLocale: null,
              ),
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
}
