import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_providers.dart'
    as lib_providers;
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/providers.dart';
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

    final repo = TestChapterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => false),
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          chapterRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

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
