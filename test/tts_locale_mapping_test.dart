import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/features/reader/reader_screen.dart';

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    // Remove any mock handler to avoid test leakage.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets('Maps en locale to TTS en-US when no explicit voice', (
    tester,
  ) async {
    final calls = <Map<String, dynamic>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async {
          if (call.method == 'setLanguage') {
            calls.add({'method': call.method, 'args': call.arguments});
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs); // default en

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsProvider.overrideWith((_) => appNotifier)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Locale Map',
            content: 'Short content.',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Expect that setLanguage was called with en-US at least once.
    expect(calls.where((c) => c['args'] == 'en-US').isNotEmpty, isTrue);
  });

  testWidgets('Maps zh locale to TTS zh-CN when no explicit voice', (
    tester,
  ) async {
    final calls = <Map<String, dynamic>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async {
          if (call.method == 'setLanguage') {
            calls.add({'method': call.method, 'args': call.arguments});
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    appNotifier.setLanguage('zh');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsProvider.overrideWith((_) => appNotifier)],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Locale Map',
            content: '短内容。',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(calls.where((c) => c['args'] == 'zh-CN').isNotEmpty, isTrue);
  });

  testWidgets(
    'Changing appSettingsProvider from en to zh triggers TTS setLanguage zh-CN',
    (tester) async {
      final calls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ttsChannel, (MethodCall call) async {
            if (call.method == 'setLanguage') {
              calls.add({'method': call.method, 'args': call.arguments});
            }
            return null;
          });

      final prefs = await SharedPreferences.getInstance();
      final appNotifier = AppSettingsNotifier(prefs); // starts as en

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appSettingsProvider.overrideWith((_) => appNotifier)],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ChapterReaderScreen(
              chapterId: 'c1',
              title: 'Locale Switch',
              content: 'Content.',
              novelId: 'n1',
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Change app language to zh and allow ref.listen to react
      appNotifier.setLanguage('zh');
      await tester.pump();
      await tester.pumpAndSettle();

      // Last setLanguage call should be zh-CN
      expect(calls.isNotEmpty, isTrue);
      expect(calls.last['args'], 'zh-CN');
    },
  );
}
