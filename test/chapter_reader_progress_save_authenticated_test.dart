import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/features/reader/state/reader_session_notifier.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

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

  testWidgets('Authenticated user: Stop triggers progress save', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    final fakeRepo = CapturingProgressPort();
    final storageService = LocalStorageService(prefs);
    final sessionNotifier = SessionNotifier(storageService);
    await sessionNotifier.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          progressRepositoryProvider.overrideWith((_) => fakeRepo),
          sessionProvider.overrideWith((_) => sessionNotifier),
          currentUserProvider.overrideWith((ref) async {
            final sid = ref.watch(sessionProvider);
            if (sid == null || sid.isEmpty) return null;
            return const BackendUser(id: 'auth-001');
          }),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
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
    expect(fakeRepo.lastSaved!.userId, 'auth-001');
    expect(fakeRepo.lastSaved!.novelId, 'n1');
  });
}
