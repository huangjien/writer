import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/reader/chapter_edit_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';

class MockChapterPort extends Mock implements ChapterPort {}

void main() {
  late MockChapterPort mockRepo;

  setUp(() {
    mockRepo = MockChapterPort();
  });

  testWidgets('ChapterEditScreen creates chapter and navigates on success', (
    tester,
  ) async {
    const novelId = 'novel-1';
    const nextIdx = 2;
    const newChapterId = 'chapter-new';

    when(() => mockRepo.getNextIdx(novelId)).thenAnswer((_) async => nextIdx);
    when(
      () => mockRepo.createChapter(
        novelId: novelId,
        idx: nextIdx,
        title: any(named: 'title'),
        content: any(named: 'content'),
      ),
    ).thenAnswer(
      (_) async => const Chapter(
        id: newChapterId,
        novelId: novelId,
        idx: nextIdx,
        title: 'Chapter 2',
        content: '',
      ),
    );

    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) =>
              const ChapterEditScreen(novelId: novelId),
        ),
        GoRoute(
          path: '/novel/:novelId/chapters/:chapterId',
          builder: (context, state) => Scaffold(
            body: Text('Reader: ${state.pathParameters['chapterId']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [chapterRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    // Initial state (loading)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async operations and navigation
    await tester.pumpAndSettle();

    // Verify method calls
    verify(() => mockRepo.getNextIdx(novelId)).called(1);
    verify(
      () => mockRepo.createChapter(
        novelId: novelId,
        idx: nextIdx,
        title: 'Chapter $nextIdx',
        content: '',
      ),
    ).called(1);

    // Verify navigation
    expect(find.text('Reader: $newChapterId'), findsOneWidget);
  });

  testWidgets(
    'ChapterEditScreen shows error on failure and allows back navigation',
    (tester) async {
      const novelId = 'novel-1';
      const errorMsg = 'Failed to create';

      when(() => mockRepo.getNextIdx(novelId)).thenThrow(Exception(errorMsg));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/create'),
                child: const Text('Go Create'),
              ),
            ),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) =>
                const ChapterEditScreen(novelId: novelId),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [chapterRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      // Navigate to create screen
      await tester.tap(find.text('Go Create'));
      await tester.pump(); // Start navigation
      await tester.pump(); // Start loading (ChapterEditScreen build)

      // Wait for async failure
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.textContaining(errorMsg), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Test Back button
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back at home
      expect(find.text('Go Create'), findsOneWidget);
    },
  );
}
