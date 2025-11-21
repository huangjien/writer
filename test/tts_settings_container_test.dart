import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/widgets/tts_settings_container.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/tts_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TtsSettingsContainer mounts and shows TTS headers', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final app = AppSettingsNotifier(prefs);
    final tts = TtsSettingsNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => app),
          ttsSettingsProvider.overrideWith((ref) => tts),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: TtsSettingsContainer()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TTS Settings'), findsOneWidget);
    expect(find.text('TTS Voice'), findsOneWidget);
    expect(find.text('TTS Language'), findsOneWidget);
  });
}
