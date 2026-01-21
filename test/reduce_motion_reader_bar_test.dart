import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async => null);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets('Reader bar AnimatedSwitcher honors Reduce Motion', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion_enabled', true);
    final motion = MotionSettingsNotifier(prefs);
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          motionSettingsProvider.overrideWith((_) => motion),
          appSettingsProvider.overrideWith((_) => appSettings),
          ttsSettingsProvider.overrideWith((_) => ttsSettings),
          aiChatServiceProvider.overrideWith(
            (ref) => AiChatService(RemoteRepository('http://localhost:5600/')),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Test Chapter',
            content: 'Hello world.',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switcherFinder = find.byKey(
      const ValueKey('reader_bar_play_switcher'),
    );
    expect(switcherFinder, findsOneWidget);
    final switcher = tester.widget<AnimatedSwitcher>(switcherFinder);
    expect(switcher.duration, Duration.zero);
    expect(switcher.switchInCurve, Curves.linear);
    expect(switcher.switchOutCurve, Curves.linear);
  });
}
