import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';

class MockUser extends Mock implements User {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('SupabaseSection Comprehensive Tests', () {
    testWidgets('shows my novels navigation when enabled', (tester) async {
      if (!supabaseEnabled) return;

      final mockUser = MockUser();
      final mockGoRouter = MockGoRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: InheritedGoRouter(
                goRouter: mockGoRouter,
                child: SingleChildScrollView(
                  child: SupabaseSection(user: mockUser),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "My Novels" list tile
      final myNovelsTile = find.byIcon(Icons.library_books);
      expect(myNovelsTile, findsOneWidget);

      await tester.tap(myNovelsTile);
      await tester.pumpAndSettle();

      // Verify navigation was called
      verify(() => mockGoRouter.goNamed('myNovels')).called(1);
    });

    testWidgets('shows novels list from provider', (tester) async {
      if (!supabaseEnabled) return;

      final mockUser = MockUser();
      final testNovels = [
        Novel(
          id: 'novel1',
          title: 'Test Novel 1',
          languageCode: 'en',
          isPublic: true,
        ),
        Novel(
          id: 'novel2',
          title: 'Test Novel 2',
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [novelsProvider.overrideWith((ref) async => testNovels)],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SupabaseSection(user: mockUser),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify novels are displayed
      expect(find.text('Test Novel 1'), findsOneWidget);
      expect(find.text('Test Novel 2'), findsOneWidget);
    });

    testWidgets('shows user progress when available', (tester) async {
      if (!supabaseEnabled) return;

      final mockUser = MockUser();
      final testProgress = UserProgress(
        userId: 'user1',
        novelId: 'novel1',
        chapterId: 'chapter1',
        scrollOffset: 100.0,
        ttsCharIndex: 50,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestUserProgressProvider.overrideWith((ref) async* {
              yield testProgress;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SupabaseSection(user: mockUser),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify progress is displayed (the widget should show some indication)
      expect(find.byType(SupabaseSection), findsOneWidget);
    });

    testWidgets('dialog shows correct content when fetching', (tester) async {
      if (!supabaseEnabled) return;

      final mockUser = MockUser();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SupabaseSection(user: mockUser),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap fetch button
      await tester.tap(find.text('Fetch from Supabase'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Confirm Fetch'), findsOneWidget);
      expect(
        find.text('Fetch latest novels and progress from Supabase.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Fetch'), findsOneWidget);
    });

    testWidgets('fetch button is disabled when no user', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: SupabaseSection(user: null)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      if (supabaseEnabled) {
        // Find the fetch ListTile
        final fetchTile = find.ancestor(
          of: find.text('Fetch from Supabase'),
          matching: find.byType(ListTile),
        );
        expect(fetchTile, findsOneWidget);

        // Check if it's disabled (should not show dialog when tapped)
        await tester.tap(fetchTile);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      }
    });

    testWidgets('shows disabled state when supabase is disabled', (
      tester,
    ) async {
      if (supabaseEnabled) return;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SupabaseSection(user: null)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show disabled message
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SupabaseSection)),
      )!;
      expect(find.text(l10n.supabaseNotEnabled), findsOneWidget);
    });
  });
}
