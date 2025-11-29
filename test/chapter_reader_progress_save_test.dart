import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/features/reader/logic/progress_saver.dart' as saver;
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/user_progress.dart';

class CapturingProgressPort implements ProgressPort {
  int saveCalls = 0;
  @override
  Future<void> upsertProgress(UserProgress progress) async {
    saveCalls += 1;
  }

  @override
  Future<UserProgress?> latestProgressForUser() async => null;

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;
}

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Make TTS calls no-op to avoid plugin dependencies in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async => null);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets(
    'Supabase enabled but unauthenticated user: Stop does not call save',
    (tester) async {
      // Gate this test so it runs only when supabase is enabled.
      if (!supabaseEnabled) {
        return; // skip when not enabled
      }
      saver.mockSupabaseEnabled = true;
      saver.mockGetUser = () => null;

      final prefs = await SharedPreferences.getInstance();
      final appNotifier = AppSettingsNotifier(prefs);
      final fakeRepo = CapturingProgressPort();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((_) => appNotifier),
            progressRepositoryProvider.overrideWith((_) => fakeRepo),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ChapterReaderScreen(
              chapterId: 'c1',
              title: 'Progress',
              content: 'Hello world. This is a chapter.',
              novelId: 'n1',
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byTooltip('Speak'), findsOneWidget);
      await tester.tap(find.byTooltip('Speak'));
      await tester.pump();
      expect(find.byTooltip('Stop TTS'), findsOneWidget);
      await tester.tap(find.byTooltip('Stop TTS'));
      await tester.pumpAndSettle();

      // Without an authenticated user, save should not be called.
      expect(fakeRepo.saveCalls, 0);
      saver.mockSupabaseEnabled = null;
      saver.mockGetUser = null;
    },
    skip: supabaseEnabled,
  );
}
