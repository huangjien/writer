import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/models/user_progress.dart';
import 'package:novel_reader/features/library/widgets/library_item_row.dart';
import 'package:novel_reader/features/library/library_providers.dart'
    as lib_providers;
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/progress_providers.dart';
import 'package:novel_reader/repositories/chapter_repository.dart';

class TestChapterRepository implements ChapterRepository {
  TestChapterRepository();

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    return <Chapter>[
      Chapter(id: 'c1', novelId: novelId, idx: 1, title: 'One', content: 'x'),
      Chapter(id: 'c2', novelId: novelId, idx: 2, title: 'Two', content: 'y'),
    ];
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    return chapter;
  }

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mock mode shows 0% progress and Not started', (tester) async {
    const n = Novel(
      id: 'n1',
      title: 'Sample',
      author: 'A',
      description: 'D',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryItemRow(
              novel: n,
              isSupabaseEnabled: false,
              isSignedIn: false,
              canRemove: true,
              canDownload: false,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Not started'), findsOneWidget);
    expect(find.byKey(const ValueKey('ring-0')), findsOneWidget);
    expect(find.text('Sample'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('Continue button shows when progress exists', (tester) async {
    const n = Novel(
      id: 'n2',
      title: 'Alpha',
      author: null,
      description: null,
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final progress = UserProgress(
      userId: 'u',
      novelId: 'n2',
      chapterId: 'c1',
      scrollOffset: 0,
      ttsCharIndex: 50,
      updatedAt: DateTime.parse('2025-01-01T00:00:00Z'),
    );
    final chapters = [
      Chapter(
        id: 'c1',
        novelId: 'n2',
        idx: 1,
        title: 'One',
        content: List.filled(100, 'a').join(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lastProgressProvider.overrideWith((ref, id) async => progress),
          chaptersProvider.overrideWith((ref, id) async => chapters),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryItemRow(
              novel: n,
              isSupabaseEnabled: true,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byKey(const ValueKey('ring-50')), findsOneWidget);
    expect(find.text('Continue at chapter • One'), findsOneWidget);
  });

  testWidgets('Download disabled shows tooltip and is inactive', (
    tester,
  ) async {
    const n = Novel(
      id: 'n3',
      title: 'Beta',
      author: 'B',
      description: 'Desc',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryItemRow(
              novel: n,
              isSupabaseEnabled: false,
              isSignedIn: false,
              canRemove: true,
              canDownload: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final btnFinder = find.byKey(const Key('downloadButton_n3'));
    expect(
      find.byTooltip('Supabase is not configured for this build.'),
      findsWidgets,
    );
    final btn = tester.widget<IconButton>(btnFinder);
    expect(btn.onPressed, isNull);
  });

  testWidgets('Download action shows spinner then resets', (tester) async {
    const n = Novel(
      id: 'n4',
      title: 'Gamma',
      author: null,
      description: null,
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final repo = TestChapterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          chapterRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryItemRow(
              novel: n,
              isSupabaseEnabled: true,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final downloadButton = find.byKey(const Key('downloadButton_n4'));
    expect(downloadButton, findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(downloadButton);
      await tester.pumpAndSettle();
    });
    expect(downloadButton, findsOneWidget);
  });
}
