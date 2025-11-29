import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/logic/progress_saver.dart' as saver;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/features/reader/state/reader_session_notifier.dart';

class FakeUser extends User {
  FakeUser({required super.id})
    : super(
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
}

class CapturingProgressPort implements ProgressPort {
  int saveCalls = 0;
  UserProgress? lastSaved;
  @override
  Future<void> upsertProgress(UserProgress progress) async {
    saveCalls += 1;
    lastSaved = progress;
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
    'Supabase enabled and authenticated user: Stop triggers progress save',
    (tester) async {
      saver.mockSupabaseEnabled = true;
      final currentUser = FakeUser(id: 'auth-001');
      saver.mockGetUser = () => currentUser;

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
              title: 'Progress Auth',
              content: 'Hello world. This is a chapter.',
              novelId: 'n1',
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final element = tester.element(find.byTooltip('Speak'));
      final container = ProviderScope.containerOf(element, listen: false);
      final notifier = container.read(readerSessionProvider.notifier);
      final current = container.read(readerSessionProvider);
      notifier.state = current.copyWith(speaking: true);
      await notifier.playStop(0.0);

      // With an authenticated user, save should be called once.
      expect(fakeRepo.saveCalls, 1);
      expect(fakeRepo.lastSaved, isNotNull);
      expect(fakeRepo.lastSaved!.userId, currentUser.id);
      expect(fakeRepo.lastSaved!.novelId, 'n1');
      saver.mockSupabaseEnabled = null;
      saver.mockGetUser = null;
    },
  );
}
