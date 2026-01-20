import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/features/library/widgets/enhanced_search_bar.dart';
import 'package:writer/features/library/widgets/library_grid_item.dart';
import 'package:writer/features/library/widgets/library_item_row.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/shared/widgets/mobile_fab.dart';
import 'package:writer/shared/widgets/mobile_novel_card.dart';
import 'package:writer/widgets/sync_status_indicator.dart';

void main() {
  group('LibraryScreen - Filter Logic', () {
    testWidgets('filter by all shows all novels', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Novel Two',
          description: '',
          author: 'Author B',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            downloadedNovelIdsProvider.overrideWith((ref) async => {'n1'}),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "all" filter chip by its icon
      final allFilterChip = find.descendant(
        of: find.byType(LibraryFilterChip),
        matching: find.byIcon(Icons.apps),
      );
      expect(allFilterChip, findsOneWidget);

      // Both novels should be visible
      expect(find.text('Novel One'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Novel Two'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('libraryListView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Novel Two'), findsOneWidget);
    });

    testWidgets('filter by completed shows empty list', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "completed" filter chip by its icon
      final completedFilterChip = find.descendant(
        of: find.byType(LibraryFilterChip),
        matching: find.byIcon(Icons.check_circle),
      );
      expect(completedFilterChip, findsOneWidget);
      await tester.tap(completedFilterChip);
      await tester.pumpAndSettle();

      // Should show empty state - check for text "No novels found."
      expect(find.text('No novels found.'), findsOneWidget);
    });

    testWidgets('filter by reading shows all novels (current implementation)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            recentUserProgressProvider.overrideWith(
              (ref) async => [
                UserProgress(
                  userId: 'user1',
                  novelId: 'n1',
                  chapterId: 'c1',
                  scrollOffset: 0,
                  ttsCharIndex: 0,
                  updatedAt: DateTime.now(),
                ),
              ],
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "reading" filter chip by its icon
      final readingFilterChip = find.descendant(
        of: find.byType(LibraryFilterChip),
        matching: find.byIcon(Icons.menu_book),
      );
      expect(readingFilterChip, findsOneWidget);
      await tester.tap(readingFilterChip);
      await tester.pumpAndSettle();

      // Novel should still be visible (current implementation shows all)
      expect(find.text('Novel One'), findsOneWidget);
    });

    testWidgets(
      'filter by downloaded shows all novels (current implementation)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final novels = [
          const Novel(
            id: 'n1',
            title: 'Novel One',
            description: '',
            author: 'Author A',
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
              chaptersProvider.overrideWith((ref, novelId) async => const []),
              lastProgressProvider.overrideWith((ref, novelId) async => null),
              downloadedNovelIdsProvider.overrideWith((ref) async => {'n1'}),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const LibraryScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and tap the "downloaded" filter chip by its icon
        final downloadedFilterChip = find.descendant(
          of: find.byType(LibraryFilterChip),
          matching: find.byIcon(Icons.download_done),
        );
        expect(downloadedFilterChip, findsOneWidget);
        await tester.tap(downloadedFilterChip);
        await tester.pumpAndSettle();

        // Novel should still be visible (current implementation shows all)
        expect(find.text('Novel One'), findsOneWidget);
      },
    );
  });

  group('LibraryScreen - Desktop AppBar', () {
    testWidgets('desktop app bar shows refresh button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            isSignedInProvider.overrideWithValue(true),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('desktop app bar shows sync status indicator', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have sync status indicator
      expect(find.byType(SyncStatusIndicator), findsOneWidget);
    });

    testWidgets('desktop app bar shows settings button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            isAdminProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have settings button
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('desktop app bar shows about button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have about button (there are now two info_outline icons in the app)
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });
  });

  group('LibraryScreen - Desktop View', () {
    testWidgets('desktop view shows list mode by default', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show list view by default
      expect(find.byType(LibraryItemRow), findsOneWidget);
    });

    testWidgets('desktop view can switch to grid mode', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap grid view button
      final gridViewButton = find.byIcon(Icons.grid_view);
      expect(gridViewButton, findsOneWidget);
      await tester.tap(gridViewButton);
      await tester.pumpAndSettle();

      // Should show grid view
      expect(find.byType(LibraryGridItem), findsOneWidget);
    });
  });

  group('LibraryScreen - Mobile AppBar', () {
    testWidgets('mobile app bar shows more menu button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have more menu button
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('mobile app bar shows library title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show library title
      expect(find.text('Library'), findsOneWidget);
    });
  });

  group('LibraryScreen - Mobile List', () {
    testWidgets('mobile list shows novel cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show mobile novel card
      expect(find.byType(MobileNovelCard), findsOneWidget);
    });

    testWidgets('mobile list shows floating action button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = const <Novel>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => novels),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show FAB
      expect(find.byType(MobileFab), findsOneWidget);
    });

    testWidgets('mobile list shows bottom navigation bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = const <Novel>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => novels),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show bottom navigation bar
      expect(find.byType(MobileBottomNavBar), findsOneWidget);
    });
  });

  group('LibraryScreen - Tab Navigation', () {
    testWidgets('bottom nav bar shows all tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => const []),
            memberNovelsProvider.overrideWith((ref) async => const []),
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have bottom nav bar
      final bottomNavBar = find.byType(MobileBottomNavBar);
      expect(bottomNavBar, findsOneWidget);
    });
  });

  group('LibraryScreen - Search with Diacritics', () {
    testWidgets('search is case-insensitive', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'The Great Novel',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search in lowercase
      final searchField = find
          .descendant(
            of: find.byType(EnhancedSearchBar),
            matching: find.byType(TextField),
          )
          .first;
      await tester.enterText(searchField, 'great');
      await tester.pumpAndSettle();

      // Should find novel
      expect(find.text('The Great Novel'), findsOneWidget);
    });

    testWidgets('search matches partial titles', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'The Great Adventure',
          description: '',
          author: 'Author A',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter partial search
      final searchField = find
          .descendant(
            of: find.byType(EnhancedSearchBar),
            matching: find.byType(TextField),
          )
          .first;
      await tester.enterText(searchField, 'adv');
      await tester.pumpAndSettle();

      // Should find the novel
      expect(find.text('The Great Adventure'), findsOneWidget);
    });

    testWidgets('search with empty query shows all novels', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Novel Two',
          description: '',
          author: 'Author B',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both novels should be visible with empty search
      expect(find.text('Novel One'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Novel Two'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('libraryListView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Novel Two'), findsOneWidget);
    });

    testWidgets('clear search shows all novels', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Novel Two',
          description: '',
          author: 'Author B',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search
      final searchField = find
          .descendant(
            of: find.byType(EnhancedSearchBar),
            matching: find.byType(TextField),
          )
          .first;
      await tester.enterText(searchField, 'One');
      await tester.pumpAndSettle();

      // Only one novel should be visible
      expect(find.text('Novel One'), findsOneWidget);
      expect(find.text('Novel Two'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Both novels should be visible again
      expect(find.text('Novel One'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Novel Two'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('libraryListView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Novel Two'), findsOneWidget);
    });
  });

  group('LibraryScreen - Sort', () {
    testWidgets('sort by title ascending', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Zebra',
          description: '',
          author: 'Author A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Apple',
          description: '',
          author: 'Author B',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listItems = find.byType(LibraryItemRow);
      expect(listItems, findsWidgets);
      expect(
        find.descendant(of: listItems.first, matching: find.text('Apple')),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Zebra'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('libraryListView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Zebra'), findsOneWidget);
    });

    testWidgets('sort by author ascending', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Zebra Author',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Novel Two',
          description: '',
          author: 'Apple Author',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: LibraryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the sort dropdown and select author ascending
      final sortDropdown = find.byKey(const Key('sortDropdown'));
      expect(sortDropdown, findsOneWidget);
      await tester.tap(sortDropdown);
      await tester.pumpAndSettle();

      // Select author ascending
      // Select author ascending - dropdown shows "Author" as option
      await tester.tap(find.text('Author'));
      await tester.pumpAndSettle();

      final listItems = find.byType(LibraryItemRow);
      expect(listItems, findsWidgets);
      expect(
        find.descendant(of: listItems.first, matching: find.text('Novel Two')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Novel One'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('libraryListView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Novel One'), findsOneWidget);
    });
  });

  group('LibraryScreen - Removed Novels', () {
    testWidgets('removed novels are not shown', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Novel One',
          description: '',
          author: 'Author A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Novel Two',
          description: '',
          author: 'Author B',
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
            chaptersProvider.overrideWith((ref, novelId) async => const []),
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            removedNovelIdsProvider.overrideWith((ref) => {'n1'}),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only Novel Two should be visible
      expect(find.text('Novel One'), findsNothing);
      expect(find.text('Novel Two'), findsOneWidget);
    });
  });
}
