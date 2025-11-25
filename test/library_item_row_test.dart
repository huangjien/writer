import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/features/library/widgets/library_item_row.dart';
import 'package:writer/features/library/library_providers.dart'
    as lib_providers;
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeNovelRepository implements NovelRepository {
  final Set<String> deletedNovels = {};

  @override
  SupabaseClient get client => throw UnimplementedError();

  @override
  Future<void> deleteNovel(String novelId) async {
    deletedNovels.add(novelId);
  }

  @override
  Future<List<Novel>> fetchPublicNovels() async => [];

  @override
  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async => [];

  @override
  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Novel?> getNovel(String novelId) async => null;

  @override
  Future<Chapter?> getChapter(String chapterId) async => null;

  @override
  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {}

  @override
  Future<void> addContributor({
    required String novelId,
    required String userId,
  }) async {}

  @override
  Future<List<Novel>> fetchMemberNovels({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {}
}

class TestChapterRepository implements ChapterRepository {
  TestChapterRepository();

  final List<String> calls = [];

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    calls.add('getChapters($novelId)');
    return <Chapter>[
      Chapter(id: 'c1', novelId: novelId, idx: 1, title: 'One', content: 'x'),
      Chapter(id: 'c2', novelId: novelId, idx: 2, title: 'Two', content: 'y'),
    ];
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    calls.add('getChapter(${chapter.id})');
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

  testWidgets('Remove action (Supabase + SignedIn) shows dialog and deletes', (
    tester,
  ) async {
    const n = Novel(
      id: 'n5',
      title: 'Delta',
      author: null,
      description: null,
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final fakeRepo = FakeNovelRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [novelRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                // Watch provider to verify state changes
                final removedIds = ref.watch(
                  lib_providers.removedNovelIdsProvider,
                );
                return Column(
                  children: [
                    LibraryItemRow(
                      novel: n,
                      isSupabaseEnabled: true,
                      isSignedIn: true,
                      canRemove: true,
                      canDownload: false,
                    ),
                    Text('Removed count: ${removedIds.length}'),
                    if (removedIds.contains(n.id)) const Text('Novel Removed'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap remove button
    final removeBtn = find.byKey(const Key('removeButton_n5'));
    expect(removeBtn, findsOneWidget);
    await tester.tap(removeBtn);
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Confirm Delete'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle(); // Wait for async delete and snackbar

    // Verify deleteNovel called
    expect(fakeRepo.deletedNovels, contains('n5'));

    // Verify provider updated
    expect(find.text('Novel Removed'), findsOneWidget);

    // Verify SnackBar
    expect(find.text('Removed from Library'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Test Undo
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // Verify provider reverted
    expect(find.text('Novel Removed'), findsNothing);
  });

  testWidgets('Remove action (Local) deletes immediately without dialog', (
    tester,
  ) async {
    const n = Novel(
      id: 'n6',
      title: 'Epsilon',
      author: null,
      description: null,
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
            body: Consumer(
              builder: (context, ref, _) {
                final removedIds = ref.watch(
                  lib_providers.removedNovelIdsProvider,
                );
                return Column(
                  children: [
                    LibraryItemRow(
                      novel: n,
                      isSupabaseEnabled: false, // Local mode
                      isSignedIn: false,
                      canRemove: true,
                      canDownload: false,
                    ),
                    if (removedIds.contains(n.id)) const Text('Novel Removed'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap remove button
    final removeBtn = find.byKey(const Key('removeButton_n6'));
    await tester.tap(removeBtn);
    await tester.pumpAndSettle();

    // Verify NO dialog
    expect(find.text('Confirm Delete'), findsNothing);

    // Verify provider updated immediately
    expect(find.text('Novel Removed'), findsOneWidget);

    // Verify SnackBar
    expect(find.text('Removed from Library'), findsOneWidget);

    // Test Undo
    await tester.tap(find.text('Undo'));
    await tester.pump(); // Start animation
    await tester.pumpAndSettle(); // Finish animation

    expect(find.text('Novel Removed'), findsNothing);
  });

  testWidgets('Shortcuts trigger actions', (tester) async {
    const n = Novel(
      id: 'n7',
      title: 'Zeta',
      author: null,
      description: null,
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final repo = TestChapterRepository();

    final progress = UserProgress(
      userId: 'u',
      novelId: 'n7',
      chapterId: 'c1',
      scrollOffset: 0,
      ttsCharIndex: 0,
      updatedAt: DateTime.now(),
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final removedIds = ref.watch(
                  lib_providers.removedNovelIdsProvider,
                );
                return Column(
                  children: [
                    LibraryItemRow(
                      novel: n,
                      isSupabaseEnabled: true,
                      isSignedIn: true,
                      canRemove: true,
                      canDownload: true,
                    ),
                    if (removedIds.contains(n.id)) const Text('Novel Removed'),
                  ],
                );
              },
            ),
          ),
        ),
        GoRoute(
          path: '/novel/:novelId/chapters/:chapterId',
          builder: (context, state) =>
              Text('Chapter ${state.pathParameters['chapterId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(repo),
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          lastProgressProvider.overrideWith((ref, id) async => progress),
          chaptersProvider.overrideWith((ref, id) async => []),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Test Download Shortcut (D)
    // Find the Focus widget that wraps the ListTile
    final focusFinder = find.byWidgetPredicate(
      (widget) => widget is Focus && widget.child is ListTile,
    );
    expect(focusFinder, findsOneWidget);

    // Find the child ListTile to get the context inside the Focus widget
    final listTileFinder = find.descendant(
      of: focusFinder,
      matching: find.byType(ListTile),
    );
    final listTileElement = tester.element(listTileFinder);

    // Request focus using the node found from the child's context
    final focusNode = Focus.of(listTileElement);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue, reason: 'ListTile should have focus');

    // Send 'D'
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump(); // Trigger action

    // Wait for async operations
    await tester.pumpAndSettle();

    // Check if repo was called
    expect(repo.calls, contains('getChapters(n7)'));
    expect(repo.calls, contains('getChapter(c1)'));

    // 2. Test Continue Shortcut (Enter)
    // Focus should still be there, but request again just in case
    focusNode.requestFocus();
    await tester.pump();

    // Send 'Enter'
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // Should navigate to chapter screen
    expect(find.text('Chapter c1'), findsOneWidget);

    // Navigate back to reset for next test
    router.go('/');
    await tester.pumpAndSettle();

    // 3. Test Remove Shortcut (Delete)
    // We need to re-acquire focus because we navigated away and back
    // Re-find widgets as the tree has been rebuilt
    final focusFinder2 = find.byWidgetPredicate(
      (widget) => widget is Focus && widget.child is ListTile,
    );
    final listTileFinder2 = find.descendant(
      of: focusFinder2,
      matching: find.byType(ListTile),
    );
    final listTileElement2 = tester.element(listTileFinder2);
    final focusNode2 = Focus.of(listTileElement2);

    focusNode2.requestFocus();
    await tester.pump();

    // Send 'Delete'
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();

    // Should show dialog (since isSupabaseEnabled=true)
    expect(find.text('Confirm Delete'), findsOneWidget);

    // Cancel deletion to finish test cleanly (or confirm)
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
