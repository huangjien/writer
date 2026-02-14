import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_providers.dart'
    as lib_providers;
import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
// No Supabase imports; use a pure fake repository to avoid timers.

// A minimal fake to avoid Supabase and background timers in tests.
class TestChapterRepository implements ChapterRepository {
  TestChapterRepository();

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    return <Chapter>[
      Chapter(id: 'c1', novelId: novelId, idx: 1, title: 'One'),
      Chapter(id: 'c2', novelId: novelId, idx: 2, title: 'Two'),
    ];
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    return chapter;
  }

  // The following methods are no-ops for this test scope.
  @override
  Future<void> updateChapter(Chapter chapter) async {}

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}

  @override
  Future<int> getNextIdx(String novelId) async => 3;

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'new-$idx',
      novelId: novelId,
      idx: idx,
      title: title ?? 'Chapter $idx',
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pressing D triggers Download action without errors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);
    final repo = TestChapterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Standard provider overrides
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => ttsSettings),
          motionSettingsProvider.overrideWith((ref) => motion),
          remoteRepositoryProvider.overrideWith(
            (ref) => RemoteRepository('http://localhost:5600/'),
          ),
          aiChatServiceProvider.overrideWith(
            (ref) => AiChatService(ref.read(remoteRepositoryProvider)),
          ),
          libraryNovelsProviderV2.overrideWith(
            (ref) async => const [
              Novel(
                id: 'novel-001',
                title: 'The Whispering Forest',
                author: 'A. Storyteller',
                description: 'A gentle adventure through a mysterious forest.',
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
            ],
          ),
          chaptersProviderV2.overrideWith(
            (ref, novelId) async => const [
              Chapter(id: 'c1', novelId: 'novel-001', idx: 1, title: 'One'),
              Chapter(id: 'c2', novelId: 'novel-001', idx: 2, title: 'Two'),
            ],
          ),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          chapterRepositoryProvider.overrideWithValue(repo),
          isSignedInProvider.overrideWithValue(
            true,
          ), // Mock signed-in state for download test
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    final downloadButton = find.byKey(const Key('downloadButton_novel-001'));
    expect(downloadButton, findsOneWidget);

    // Trigger Download via the button press and allow any async timers to flush.
    await tester.runAsync(() async {
      await tester.ensureVisible(downloadButton);
      await tester.tap(downloadButton);
      await tester.pump();

      // When downloading, a progress indicator appears briefly.
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Let async download work complete to avoid pending timers.
      await tester.pumpAndSettle();
    });
    // Verify the Download button reappears after work completes.
    expect(downloadButton, findsOneWidget);
  });
}
