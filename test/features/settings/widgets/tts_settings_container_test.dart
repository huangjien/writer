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

  testWidgets('TtsSettingsContainer handles empty voices gracefully', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles getVoices error', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            throw Exception('Failed to get voices');
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer filters voices by app locale', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'English Voice', 'locale': 'en-US', 'identifier': 'en1'},
              {'name': 'Chinese Voice', 'locale': 'zh-CN', 'identifier': 'zh1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'zh-CN'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles invalid voice data', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': '', 'locale': 'en-US', 'identifier': 'v1'},
              {'locale': 'en-US'},
              {'name': 'Valid Voice', 'locale': 'en-US', 'identifier': 'v2'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles getLanguages error', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            throw Exception('Failed to get languages');
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer calculates effectiveSelectedKey', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
              {'name': 'Voice2', 'locale': 'en-GB', 'identifier': 'v2'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'en-GB'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_name', 'Voice1');

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer calculates effectiveSelectedLocale', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'en-GB'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_locale', 'en-US');

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles both voice name and locale set', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
              {'name': 'Voice2', 'locale': 'en-GB', 'identifier': 'v2'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'en-GB'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_name', 'Voice1');
    await prefs.setString('tts_voice_locale', 'en-US');

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles non-matching voice name', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_name', 'NonExistentVoice');

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer handles non-matching locale', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_locale', 'zh-CN');

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });

  testWidgets('TtsSettingsContainer filters locales by app language', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getVoices') {
            return [
              {'name': 'Voice1', 'locale': 'en-US', 'identifier': 'v1'},
            ];
          }
          if (methodCall.method == 'getLanguages') {
            return ['en-US', 'en-GB', 'zh-CN', 'ja-JP'];
          }
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });

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

    expect(find.byType(TtsSettingsSection), findsOneWidget);
  });
}
