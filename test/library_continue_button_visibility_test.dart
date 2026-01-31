import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Library Continue button hidden when no progress (en)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.
    final prefs = await SharedPreferences.getInstance();

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
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          // Override both real and mock providers to ensure deterministic behavior.
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith(
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
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue button should not be visible when no progress.
    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    expect(find.widgetWithText(NeumorphicButton, 'Continue'), findsNothing);
    expect(find.text('Not started'), findsOneWidget);
  });

  testWidgets('Library Continue button visible when progress present (en)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.
    final prefs = await SharedPreferences.getInstance();

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
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith(
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
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue text reflects chapter title and button is visible.
    expect(find.text('Continue at chapter • Hidden Creek'), findsOneWidget);
    expect(find.widgetWithText(NeumorphicButton, 'Continue'), findsOneWidget);
  });

  testWidgets('Library Continue button hidden when no progress (zh)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.
    final prefs = await SharedPreferences.getInstance();

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
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith(
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
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue button should not be visible when no progress.
    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    expect(find.widgetWithText(NeumorphicButton, '继续'), findsNothing);
    expect(find.text('尚未开始'), findsOneWidget);
  });

  testWidgets('Library Continue button visible when progress present (zh)', (
    tester,
  ) async {
    // SharedPreferences mock is initialized in setUp; no instance needed here.
    final prefs = await SharedPreferences.getInstance();

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
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          novelsProvider.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith(
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
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Continue text reflects chapter title and button is visible.
    expect(find.text('继续阅读章节 • Hidden Creek'), findsOneWidget);
    expect(find.widgetWithText(NeumorphicButton, '继续'), findsOneWidget);
  });
}
