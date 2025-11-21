import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/repositories/novel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeNovelRepository extends NovelRepository {
  FakeNovelRepository() : super(Supabase.instance.client);
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
      'app_metadata': {},
      'user_metadata': {},
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

      // Initialize Supabase client (no network operations are required here).
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

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
            // Override repository to capture delete calls.
            novelRepositoryProvider.overrideWith((ref) => fakeRepo),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

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
      await tester.pump();

      // Repository called and item hidden locally with SnackBar.
      expect(fakeRepo.called, isTrue);
      expect(fakeRepo.deletedId, equals('n-1'));

      // Count updates and SnackBar shown.
      expect(find.text('1 / 2 Novels'), findsOneWidget);
      expect(find.text('Removed from Library'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Undo restores visibility.
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(find.text('2 / 2 Novels'), findsOneWidget);
      expect(find.text('Quiet City Nights'), findsOneWidget);
    },
  );
}
