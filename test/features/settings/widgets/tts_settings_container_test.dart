import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/tts_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  const channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
              {'name': 'Voice2', 'locale': 'en-GB', 'identifier': 'v2'},
              {'name': 'Voice3', 'locale': 'zh-CN', 'identifier': 'v3'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'en-GB', 'zh-CN'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('TtsSettingsContainer loads voices and displays section', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: TtsSettingsContainer()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify loading finished
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify section exists
    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });
}
