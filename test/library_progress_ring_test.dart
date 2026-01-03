import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('0% ring with Not started when no progress exists', (
    tester,
  ) async {
    // Ensure a clean preferences state
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'Quiet City Nights',
        author: 'L. Dreamer',
        description: 'Slice-of-life stories set in a peaceful city.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          libraryNovelsProvider.overrideWith((ref) async => novels),
          memberNovelsProvider.overrideWith((ref) async => const []),
          chaptersProvider.overrideWith((ref, novelId) async {
            return [
              const Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Chapter One',
                content: 'abc',
              ),
            ];
          }),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Allow async providers to resolve
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Neutral ring and label should be visible.
    expect(find.text('Not started'), findsOneWidget);
    final rings = find.byWidgetPredicate(
      (w) => w is CircularProgressIndicator && w.strokeWidth == 3,
    );
    final ringWidgets = rings
        .evaluate()
        .map((e) => e.widget)
        .whereType<CircularProgressIndicator>()
        .toList();
    expect(ringWidgets.any((r) => r.value == 0.0), isTrue);
  });

  testWidgets('Shows progress ring and continue text when progress exists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
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

    // Chapter content of known length so ring value is deterministic.
    final chapterContent = List.filled(1000, 'x').join(); // length: 1000

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          libraryNovelsProvider.overrideWith((ref) async => novels),
          memberNovelsProvider.overrideWith((ref) async => const []),
          chaptersProvider.overrideWith((ref, novelId) async {
            return [
              Chapter(
                id: 'c-1',
                novelId: 'n-1',
                idx: 1,
                title: 'Into the Woods',
                content: chapterContent,
              ),
              Chapter(
                id: 'c-2',
                novelId: 'n-1',
                idx: 2,
                title: 'Hidden Creek',
                content: chapterContent,
              ),
            ];
          }),
          lastProgressProvider.overrideWith((ref, novelId) async {
            // Progress points into chapter 2 at character 400 => 40% ring.
            return UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0,
              ttsCharIndex: 400,
              updatedAt: DateTime.now(),
            );
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Allow async providers to resolve
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Continue text reflects chapter title
    expect(find.text('Continue at chapter • Hidden Creek'), findsOneWidget);

    // A determinate progress indicator should be present (value close to 0.4).
    final rings = find.byWidgetPredicate(
      (w) => w is CircularProgressIndicator && w.strokeWidth == 3,
    );
    expect(rings, findsWidgets);
    final ringWidget =
        rings.evaluate().first.widget as CircularProgressIndicator;
    expect(ringWidget.value, isNotNull);
    expect(ringWidget.value!, closeTo(0.4, 0.001));
  });
}
