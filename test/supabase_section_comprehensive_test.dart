import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

// Mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  group('SupabaseSection comprehensive tests', () {
    testWidgets(
      'My Novels navigation works when Supabase is disabled',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return InheritedGoRouter(
                    goRouter: mockGoRouter,
                    child: const SingleChildScrollView(
                      child: SupabaseSection(user: null),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the section is shown
        expect(find.text('Supabase Settings'), findsOneWidget);
        expect(find.text('Supabase not enabled'), findsOneWidget);

        // Tap on My Novels
        await tester.tap(find.text('My Novels'));
        await tester.pumpAndSettle();

        // Verify navigation was called
        verify(() => mockGoRouter.goNamed('myNovels')).called(1);
      },
      skip: supabaseEnabled,
    );

    testWidgets(
      'My Novels navigation works when Supabase is enabled',
      (tester) async {
        final mockUser = MockUser();

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return InheritedGoRouter(
                    goRouter: mockGoRouter,
                    child: SingleChildScrollView(
                      child: SupabaseSection(user: mockUser),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the section is shown
        expect(find.text('Supabase Settings'), findsOneWidget);
        expect(find.text('Fetch from Supabase'), findsOneWidget);

        // Tap on My Novels
        await tester.tap(find.text('My Novels'));
        await tester.pumpAndSettle();

        // Verify navigation was called
        verify(() => mockGoRouter.goNamed('myNovels')).called(1);
      },
      skip: !supabaseEnabled,
    );

    testWidgets('Fetch dialog shows correct content', (tester) async {
      final mockUser = MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelsProvider.overrideWith((ref) async => const <Novel>[]),
            latestUserProgressProvider.overrideWith((ref) async* {
              yield null;
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

      // Tap on Fetch from Supabase
      await tester.tap(find.text('Fetch from Supabase'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Confirm Fetch'), findsOneWidget);
      expect(
        find.text(
          'This will fetch the latest novels and progress from Supabase.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Fetch'), findsOneWidget);
    }, skip: !supabaseEnabled);

    testWidgets('Fetch button is disabled when user is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelsProvider.overrideWith((ref) async => const <Novel>[]),
            latestUserProgressProvider.overrideWith((ref) async* {
              yield null;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(child: SupabaseSection(user: null)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Fetch from Supabase is present but disabled
      final fetchTile = find.widgetWithText(ListTile, 'Fetch from Supabase');
      expect(fetchTile, findsOneWidget);

      // Tap on it - should not show dialog since onTap is null
      await tester.tap(fetchTile);
      await tester.pumpAndSettle();

      // Verify no dialog is shown
      expect(find.text('Confirm Fetch'), findsNothing);
    }, skip: !supabaseEnabled);

    testWidgets('Novels and Progress section displays correctly', (
      tester,
    ) async {
      final mockUser = MockUser();
      final testNovels = [
        Novel(
          id: 'novel1',
          title: 'Test Novel',
          description: 'Test Description',
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelsProvider.overrideWith((ref) async => testNovels),
            latestUserProgressProvider.overrideWith((ref) async* {
              yield UserProgress(
                userId: 'user1',
                novelId: 'novel1',
                chapterId: 'chapter1',
                scrollOffset: 100.0,
                ttsCharIndex: 50,
                updatedAt: DateTime.now(),
              );
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

      // Verify Novels and Progress section
      expect(find.text('Novels and Progress'), findsOneWidget);
      // Should show summary with novel count and progress info
      expect(find.textContaining('1 novels, progress: novel1'), findsOneWidget);
    }, skip: !supabaseEnabled);

    testWidgets('Novels and Progress section handles null progress', (
      tester,
    ) async {
      final mockUser = MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelsProvider.overrideWith((ref) async => const <Novel>[]),
            latestUserProgressProvider.overrideWith((ref) async* {
              yield null;
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

      // Verify Novels and Progress section
      expect(find.text('Novels and Progress'), findsOneWidget);
      // Should show summary with 0 novels and N/A for progress
      expect(find.textContaining('0 novels, progress: N/A'), findsOneWidget);
    }, skip: !supabaseEnabled);
  });
}
