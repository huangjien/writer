import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TtsSettingsContainer renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TtsSettingsContainer(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Since the TTS plugin is not available in tests, we expect to see the loading indicators.
    expect(find.text('Loading voices...'), findsOneWidget);
    expect(find.text('Loading languages...'), findsOneWidget);
  });
}
