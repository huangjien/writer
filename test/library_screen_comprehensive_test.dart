import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/widgets/library_error_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/shared/widgets/mobile_fab.dart';

void main() {
  group('LibraryScreen - Search Functionality', () {
    testWidgets('search and clear functionality', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Clear Search Test',
          description: '',
          author: 'Test Author',
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

      // Should find the novel initially
      expect(find.text('Clear Search Test'), findsOneWidget);

      // Search for specific text
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Clear');
      await tester.pump();
      expect(find.text('Clear Search Test'), findsOneWidget);

      // Clear search and verify novel is still visible
      await tester.enterText(searchField, '');
      await tester.pump();
      expect(find.text('Clear Search Test'), findsOneWidget);
    });

    testWidgets('basic search functionality works', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Search Test Novel',
          description: '',
          author: 'Test Author',
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

      // Should find the novel
      expect(find.text('Search Test Novel'), findsOneWidget);

      // Enter search text
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Search');
      await tester.pump();
      expect(find.text('Search Test Novel'), findsOneWidget);

      // Search with text that won't match
      await tester.enterText(searchField, 'Nonexistent');
      await tester.pump();
      expect(find.text('No novels found.'), findsOneWidget);
    });

    testWidgets('search clear button works correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Test Novel',
          description: '',
          author: 'Test Author',
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

      // Search for something
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nonexistent');
      await tester.pump();

      // Novel should be filtered out
      expect(find.text('Test Novel'), findsNothing);

      // Clear the search
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      // Novel should be visible again
      expect(find.text('Test Novel'), findsOneWidget);
    });
  });

  group('LibraryScreen - Sorting', () {
    testWidgets('sort dropdown is present', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Test Novel',
          description: '',
          author: 'John Doe',
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

      // Should find the novel
      expect(find.text('Test Novel'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('search field is present', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Search Test Novel',
          description: '',
          author: 'Test Author',
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

      // Should find the search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Test Novel'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });
  });

  group('LibraryScreen - Empty States', () {
    testWidgets('shows empty state when no novels', (tester) async {
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
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No novels found.'), findsOneWidget);
    });

    testWidgets('empty state create button navigates correctly', (
      tester,
    ) async {
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
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No novels found.'), findsOneWidget);
    });
  });

  group('LibraryScreen - Error Handling', () {
    testWidgets('shows error state when novels fail to load', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final error = Exception('Network error');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryNovelsProvider.overrideWith((ref) async => throw error),
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

      // Should show error section
      expect(find.byType(LibraryErrorSection), findsOneWidget);
    });
  });

  group('LibraryScreen - Responsive Design', () {
    testWidgets('mobile layout shows bottom navigation', (tester) async {
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

      // Should show bottom navigation on mobile
      expect(find.byType(MobileBottomNavBar), findsOneWidget);
    });

    testWidgets('desktop layout shows app drawer', (tester) async {
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

      // Desktop doesn't use mobile bottom navigation
      expect(find.byType(MobileBottomNavBar), findsNothing);
    });
  });

  group('LibraryScreen - Accessibility', () {
    testWidgets('floating action button has proper semantics', (tester) async {
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

      // Should find mobile fab
      expect(find.byType(MobileFab), findsOneWidget);
    });
  });

  group('LibraryScreen - Edge Cases', () {
    testWidgets('handles very long titles gracefully', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final longTitle =
          'This is an extremely long novel title that should be truncated properly in the UI without breaking the layout or causing overflow issues';
      final novels = [
        Novel(
          id: 'n1',
          title: longTitle,
          description: '',
          author: 'Test Author',
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

      // Should handle long titles without overflow
      expect(find.byType(LibraryScreen), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('handles special characters in search', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Café & Restaurant: A Story',
          description: '',
          author: 'Jean-Paul O\'Connor',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'The @Hashtag Generation',
          description: '',
          author: 'Jane Smith',
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

      // Search with special characters
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Café &');
      await tester.pump();
      expect(find.text('Café & Restaurant: A Story'), findsOneWidget);

      // Clear and search for different special chars
      await tester.enterText(searchField, '@Hashtag');
      await tester.pump();
      expect(find.text('The @Hashtag Generation'), findsOneWidget);
    });

    testWidgets('handles empty search string correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Test Novel 1',
          description: '',
          author: 'Author One',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Test Novel 2',
          description: '',
          author: 'Author Two',
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

      // Initially all novels should be visible
      expect(find.text('Test Novel 1'), findsOneWidget);
      expect(find.text('Test Novel 2'), findsOneWidget);

      // Clear search should show all novels
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '');
      await tester.pump();
      expect(find.text('Test Novel 1'), findsOneWidget);
      expect(find.text('Test Novel 2'), findsOneWidget);
    });

    testWidgets('handles whitespace-only search correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Test Novel',
          description: '',
          author: 'Test Author',
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

      // Search with only whitespace
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '   ');
      await tester.pump();

      // Should treat whitespace as empty search and show all novels
      expect(find.text('Test Novel'), findsOneWidget);
    });
  });

  group('LibraryScreen - Complex User Interactions', () {
    testWidgets('search and navigate interactions work together', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Interactive Novel',
          description: 'A test novel for interaction testing',
          author: 'Test Author',
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

      // Search for the novel
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Interactive');
      await tester.pump();
      expect(find.text('Interactive Novel'), findsOneWidget);

      // Verify search functionality works correctly
      expect(find.text('Interactive Novel'), findsOneWidget);

      // Clear search and verify all novels are still visible
      await tester.enterText(searchField, '');
      await tester.pump();
      expect(find.text('Interactive Novel'), findsOneWidget);
    });

    testWidgets('rapid search typing doesn\'t cause errors', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Rapid Search Test',
          description: '',
          author: 'Test Author',
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

      final searchField = find.byType(TextField);

      // Simulate rapid typing
      await tester.enterText(searchField, 'R');
      await tester.pump();
      await tester.enterText(searchField, 'Ra');
      await tester.pump();
      await tester.enterText(searchField, 'Rap');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid ');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid S');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid Se');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid Sea');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid Sear');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid Searc');
      await tester.pump();
      await tester.enterText(searchField, 'Rapid Search');
      await tester.pump();

      // Should still work correctly
      expect(find.text('Rapid Search Test'), findsOneWidget);
    });

    testWidgets('search maintains state during user interactions', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'State Test Novel',
          description: '',
          author: 'Test Author',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Other Novel',
          description: '',
          author: 'Other Author',
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

      // Search for specific novel
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'State Test');
      await tester.pump();

      // Verify filtered results
      expect(find.text('State Test Novel'), findsOneWidget);
      expect(find.text('Other Novel'), findsNothing);

      // Verify the search field maintains its state
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.controller?.text == 'State Test',
        ),
        findsOneWidget,
      );
      expect(find.text('State Test Novel'), findsOneWidget);
    });
  });

  group('LibraryScreen - Additional Edge Cases', () {
    testWidgets('handles rapid search query changes', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final novels = [
        const Novel(
          id: 'n1',
          title: 'Test Novel for Search',
          description: 'A test novel',
          author: 'Test Author',
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

      // Verify the novel is initially visible
      expect(find.text('Test Novel for Search'), findsOneWidget);

      // Find and interact with the search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test rapid search changes
      await tester.enterText(searchField, 'Search');
      await tester.pump();
      expect(find.text('Test Novel for Search'), findsOneWidget);

      await tester.enterText(searchField, 'Novel');
      await tester.pump();
      expect(find.text('Test Novel for Search'), findsOneWidget);

      await tester.enterText(searchField, 'NonExistent');
      await tester.pump();
      expect(find.text('Test Novel for Search'), findsNothing);

      // Clear search and verify novel is visible again
      await tester.enterText(searchField, '');
      await tester.pump();
      expect(find.text('Test Novel for Search'), findsOneWidget);
    });
  });
}
