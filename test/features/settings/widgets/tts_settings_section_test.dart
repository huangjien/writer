import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/tts_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  testWidgets('TtsSettingsSection renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier()),
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
}
