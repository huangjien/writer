import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/user_progress.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/progress_providers.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  testWidgets(
    'Mock fallback: 0% ring with Not started when Supabase disabled',
    (tester) async {
      // Ensure a clean preferences state
      SharedPreferences.setMockInitialValues({});

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
            // In Supabase-disabled mode, LibraryScreen consumes mock providers.
            mockNovelsProvider.overrideWith((ref) async => novels),
            mockChaptersProvider.overrideWith((ref, novelId) async {
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
            // Neutral offline progress: expect 0% ring and label.
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

      // Allow async providers to resolve
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify Supabase disabled banner is shown
      expect(
        find.text('Supabase is not configured for this build.'),
        findsOneWidget,
      );

      // Neutral offline ring and label should be visible.
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
    },
  );

  testWidgets('Supabase-backed: shows progress ring and continue text', (
    tester,
  ) async {
    // Skip if Supabase is not enabled for this test run.
    if (!supabaseEnabled) {
      return;
    }

    SharedPreferences.setMockInitialValues({});

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
          // Force Library to use Supabase-backed providers by overriding them directly.
          novelsProvider.overrideWith((ref) async => novels),
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
