import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/user_progress.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/progress_providers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Library Continue button hidden when no progress (en)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override both real and mock providers to ensure deterministic behavior.
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProvider.overrideWith(
            (ref, novelId) async => const [
              Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: 'abc',
              ),
            ],
          ),
          lastProgressProvider.overrideWith((ref, novelId) async => null),

          mockNovelsProvider.overrideWith((ref) async => novels),
          mockChaptersProvider.overrideWith(
            (ref, novelId) async => const [
              Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: 'abc',
              ),
            ],
          ),
          mockLastProgressProvider.overrideWith((ref, novelId) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue button should not be visible when no progress.
    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Continue'), findsNothing);
    expect(find.text('Not started'), findsOneWidget);
  });

  testWidgets('Library Continue button visible when progress present (en)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    final chapterContent = List.filled(1000, 'x').join();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProvider.overrideWith(
            (ref, novelId) async => [
              const Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: null,
              ),
              Chapter(
                id: 'c-2',
                novelId: 'n-1',
                idx: 2,
                title: 'Hidden Creek',
                content: chapterContent,
              ),
            ],
          ),
          lastProgressProvider.overrideWith(
            (ref, novelId) async => UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 250,
              updatedAt: DateTime(2024, 1, 1),
            ),
          ),

          mockNovelsProvider.overrideWith((ref) async => novels),
          mockChaptersProvider.overrideWith(
            (ref, novelId) async => [
              const Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: null,
              ),
              Chapter(
                id: 'c-2',
                novelId: 'n-1',
                idx: 2,
                title: 'Hidden Creek',
                content: chapterContent,
              ),
            ],
          ),
          mockLastProgressProvider.overrideWith(
            (ref, novelId) async => UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 250,
              updatedAt: DateTime(2024, 1, 1),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue text reflects chapter title and button is visible.
    expect(find.text('Continue at chapter • Hidden Creek'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Continue'), findsOneWidget);
  });

  testWidgets('Library Continue button hidden when no progress (zh)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProvider.overrideWith(
            (ref, novelId) async => const [
              Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: 'abc',
              ),
            ],
          ),
          lastProgressProvider.overrideWith((ref, novelId) async => null),

          mockNovelsProvider.overrideWith((ref) async => novels),
          mockChaptersProvider.overrideWith(
            (ref, novelId) async => const [
              Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: 'abc',
              ),
            ],
          ),
          mockLastProgressProvider.overrideWith((ref, novelId) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue button should not be visible when no progress.
    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    expect(find.widgetWithText(TextButton, '继续'), findsNothing);
    expect(find.text('尚未开始'), findsOneWidget);
  });

  testWidgets('Library Continue button visible when progress present (zh)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    final chapterContent = List.filled(1000, 'x').join();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProvider.overrideWith(
            (ref, novelId) async => [
              const Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: null,
              ),
              Chapter(
                id: 'c-2',
                novelId: 'n-1',
                idx: 2,
                title: 'Hidden Creek',
                content: chapterContent,
              ),
            ],
          ),
          lastProgressProvider.overrideWith(
            (ref, novelId) async => UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 250,
              updatedAt: DateTime(2024, 1, 1),
            ),
          ),

          mockNovelsProvider.overrideWith((ref) async => novels),
          mockChaptersProvider.overrideWith(
            (ref, novelId) async => [
              const Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: null,
              ),
              Chapter(
                id: 'c-2',
                novelId: 'n-1',
                idx: 2,
                title: 'Hidden Creek',
                content: chapterContent,
              ),
            ],
          ),
          mockLastProgressProvider.overrideWith(
            (ref, novelId) async => UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 250,
              updatedAt: DateTime(2024, 1, 1),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue text reflects chapter title and button is visible.
    expect(find.text('继续阅读章节 • Hidden Creek'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '继续'), findsOneWidget);
  });
}
