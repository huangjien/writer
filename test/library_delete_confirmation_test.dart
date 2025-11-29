import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Flutter-specific options for Supabase.initialize

class FakeNovelRepository extends NovelRepository {
  FakeNovelRepository()
    : super(
        SupabaseClient(
          supabaseUrl,
          supabaseAnonKey,
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  bool called = false;
  String? deletedId;
  @override
  Future<void> deleteNovel(String novelId) async {
    called = true;
    deletedId = novelId;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Creates a minimal session using fromJson for testing purposes.
Session _fakeSession() {
  return Session.fromJson({
    'access_token': 'test',
    'token_type': 'bearer',
    'expires_in': 3600,
    'refresh_token': 'refresh',
    'user': {
      'id': 'user-id',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'user@example.com',
      'phone': '',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
  })!;
}

void main() {
  testWidgets(
    'When signed in, tapping remove shows confirm dialog and calls delete',
    (tester) async {
      // Skip this test unless Supabase is enabled via dart-define.
      if (!supabaseEnabled) {
        return; // Test runner will treat as pass if body returns early.
      }

      SharedPreferences.setMockInitialValues({});

      // Supabase is initialized in flutter_test_config when enabled.

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
        const Novel(
          id: 'n-2',
          title: 'The Whispering Forest',
          author: 'A. Storyteller',
          description: 'A gentle adventure through a mysterious forest.',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      final fakeRepo = FakeNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provide a non-null session to exercise the confirmation path.
            supabaseSessionProvider.overrideWith((ref) => _fakeSession()),
            // Override novels fetch to return our fixture list.
            novelsProvider.overrideWith((ref) async => novels),
            // Ensure library union resolves without network.
            memberNovelsProvider.overrideWith((ref) async => const <Novel>[]),
            // Override repository to capture delete calls.
            novelRepositoryProvider.overrideWith((ref) => fakeRepo),
            // Avoid network-backed providers that can hang during settle.
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            chaptersProvider.overrideWith(
              (ref, novelId) async => const <Chapter>[],
            ),
            recentUserProgressProvider.overrideWith(
              (ref) => Stream.value(const <UserProgress>[]),
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

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      // Tap remove on the first tile.
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsWidgets);
      await tester.tap(deleteButtons.first);
      await tester.pump();

      // Confirmation dialog appears with expected text.
      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(
        find.text(
          "This will delete 'Quiet City Nights' from Supabase. Are you sure?",
        ),
        findsOneWidget,
      );
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Confirm deletion.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Repository called and item hidden locally with SnackBar.
      expect(fakeRepo.called, isTrue);
      expect(fakeRepo.deletedId, equals('n-1'));

      // Count updates and SnackBar shown.
      expect(find.text('1 / 2 Novels'), findsOneWidget);
      expect(find.text('Removed from Library'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Undo restores visibility.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2 Novels'), findsOneWidget);
      expect(find.text('Quiet City Nights'), findsOneWidget);
    },
  );
}
