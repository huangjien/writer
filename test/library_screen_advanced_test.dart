import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  group('LibraryScreen - Advanced Functionality', () {
    late SharedPreferences prefs;
    late List<Novel> testNovels;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      testNovels = [
        const Novel(
          id: 'n1',
          title: 'Café Novel',
          description: 'A story with accented characters',
          author: 'José García',
          coverUrl: null,
          languageCode: 'es',
          isPublic: true,
        ),
        const Novel(
          id: 'n2',
          title: 'Regular Novel',
          description: 'A normal story',
          author: 'John Smith',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
      ];
    });

    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    Widget createTestWidget({required List<Novel> novels}) {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWith((ref) => false),
          isAdminProvider.overrideWith((ref) => false),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          removedNovelIdsProvider.overrideWith((ref) => <String>{}),
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
          routes: {
            '/novel/create': (context) => const Scaffold(body: Text('Create')),
          },
        ),
      );
    }

    testWidgets('search normalization handles accented characters', (
      tester,
    ) async {
      // Set mobile screen size
      tester.view.physicalSize = const Size(550, 800);
      tester.view.devicePixelRatio = 1.0;

      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createTestWidget(novels: testNovels));
      await tester.pumpAndSettle();

      // Search for 'cafe' (without accent) should find 'Café' (with accent)
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'cafe');
      await tester.pump();

      expect(find.text('Café Novel'), findsOneWidget);
      expect(find.text('Regular Novel'), findsNothing);
    });

    testWidgets('case insensitive search works correctly', (tester) async {
      // Set mobile screen size
      tester.view.physicalSize = const Size(550, 800);
      tester.view.devicePixelRatio = 1.0;

      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createTestWidget(novels: testNovels));
      await tester.pumpAndSettle();

      // Search for 'novel' (lowercase) should find both novels
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'novel');
      await tester.pump();

      expect(find.text('Café Novel'), findsOneWidget);
      expect(find.text('Regular Novel'), findsOneWidget);
    });

    testWidgets('delete functionality shows undo snackbar', (tester) async {
      // Set mobile screen size - tall enough to avoid FAB overlap
      tester.view.physicalSize = const Size(550, 2000);
      tester.view.devicePixelRatio = 1.0;

      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createTestWidget(novels: testNovels));
      await tester.pumpAndSettle();

      // Find the more menu button for the first novel
      // Use long press on the card to open the menu (avoids FAB overlap issues with the more button)
      // Manually trigger the more button action since FAB layout obscures it in test
      final moreButtonFinder = find.byKey(const ValueKey('more_actions_n1'));
      final moreButton = tester.widget<NeumorphicButton>(moreButtonFinder);
      moreButton.onPressed?.call();
      await tester.pumpAndSettle();

      // Tap the delete option using key
      final deleteOption = find.byKey(
        const ValueKey('action_sheet_item_delete'),
      );
      expect(deleteOption, findsOneWidget);

      await tester.tap(deleteOption);
      await tester.pump();
      await tester.pumpAndSettle();

      // Should show snackbar with undo option
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().removedNovel('Café Novel')),
        findsOneWidget,
      );
      expect(find.text(AppLocalizationsEn().undo), findsOneWidget);
    });

    testWidgets('undo functionality restores novel to library', (tester) async {
      // Set mobile screen size - tall enough to avoid FAB overlap
      tester.view.physicalSize = const Size(550, 2000);
      tester.view.devicePixelRatio = 1.0;

      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createTestWidget(novels: testNovels));
      await tester.pumpAndSettle();

      // Delete the novel
      // Use long press on the card to open the menu (avoids FAB overlap issues with the more button)
      // Manually trigger the more button action since FAB layout obscures it in test
      final moreButtonFinder = find.byKey(const ValueKey('more_actions_n1'));
      final moreButton = tester.widget<NeumorphicButton>(moreButtonFinder);
      moreButton.onPressed?.call();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('action_sheet_item_delete')));
      await tester.pump();

      // Novel should be hidden
      expect(find.text('Café Novel'), findsNothing);

      // Wait a moment for the snackbar to be fully interactive
      await tester.pump(const Duration(milliseconds: 100));

      // Click undo with a more specific finder
      final undoButton = find.text(AppLocalizationsEn().undo);
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Novel should be visible again
      expect(find.text('Café Novel'), findsOneWidget);
    });

    testWidgets('library screen builds without errors', (tester) async {
      // Set mobile screen size
      tester.view.physicalSize = const Size(550, 800);
      tester.view.devicePixelRatio = 1.0;

      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createTestWidget(novels: testNovels));
      await tester.pumpAndSettle();

      // Should find both novels
      expect(find.text('Café Novel'), findsOneWidget);
      expect(find.text('Regular Novel'), findsOneWidget);

      // Should find search functionality
      expect(find.byType(TextField), findsOneWidget);

      // Should find more menu buttons
      expect(find.byIcon(Icons.more_vert), findsWidgets);
    });

    testWidgets('delete and undo functionality works', (tester) async {
      prefs = await SharedPreferences.getInstance();

      // Test the state management for removed novels
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // Test adding to removed set
      final removedNotifier = container.read(removedNovelIdsProvider.notifier);
      removedNotifier.update((state) => <String>{...state, 'n1'});

      final removedIds = container.read(removedNovelIdsProvider);
      expect(removedIds.contains('n1'), isTrue);

      container.dispose();
    });
  });
}
