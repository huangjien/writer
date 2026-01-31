import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/storage_service.dart';

class MockStorageService implements StorageService {
  String? _sessionId;

  @override
  String? getString(String key) =>
      key == 'backend_session_id' ? _sessionId : null;

  @override
  Future<void> setString(String key, String? value) async {
    if (key == 'backend_session_id') {
      _sessionId = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    if (key == 'backend_session_id') {
      _sessionId = null;
    }
  }

  @override
  Set<String> getKeys() => {'backend_session_id'};
}

class FakeNovelRepository extends NovelRepository {
  FakeNovelRepository() : super(_NoopRemoteRepository());
  bool called = false;
  String? deletedId;
  @override
  Future<void> deleteNovel(String novelId) async {
    called = true;
    deletedId = novelId;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _NoopRemoteRepository implements RemoteRepository {
  @override
  String get baseUrl => 'http://test/';

  @override
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = false,
  }) async {}

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchCharacterProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchSceneProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsage?> getCurrentMonthUsage() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAdminLogs({int lines = 1000}) async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsageHistory?> getUsageHistory({
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeLocalStorageRepository extends LocalStorageRepository {
  _FakeLocalStorageRepository(super.storage);

  List<Novel> _cachedNovels = const [];

  @override
  Future<List<Novel>> getLibraryNovels() async => _cachedNovels;

  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {
    _cachedNovels = novels;
  }
}

void main() {
  testWidgets(
    'When signed in, tapping remove shows confirm dialog and calls delete',
    (tester) async {
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
      final sessionNotifier = SessionNotifier(MockStorageService())
        ..state = 'test-session';
      final fakeLocal = _FakeLocalStorageRepository(MockStorageService());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override novels fetch to return our fixture list.
            libraryNovelsProviderV2.overrideWith((ref) async => novels),
            // Ensure library union resolves without network.
            memberNovelsProviderV2.overrideWith((ref) async => const <Novel>[]),
            // Override repository to capture delete calls.
            novelRepositoryProvider.overrideWith((ref) => fakeRepo),
            sessionProvider.overrideWith((ref) => sessionNotifier),
            localStorageRepositoryProvider.overrideWithValue(fakeLocal),
            // Avoid network-backed providers that can hang during settle.
            lastProgressProvider.overrideWith((ref, novelId) async => null),
            chaptersProviderV2.overrideWith(
              (ref, novelId) async => const <Chapter>[],
            ),
            recentUserProgressProvider.overrideWith(
              (ref) async => const <UserProgress>[],
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

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      // Tap remove on the first tile.
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsWidgets);
      await tester.tap(deleteButtons.first);
      await tester.pump();

      // Confirmation dialog appears with expected text.
      expect(find.text(AppLocalizationsEn().confirmDelete), findsOneWidget);
      expect(
        find.text(
          AppLocalizationsEn().confirmDeleteDescription('Quiet City Nights'),
        ),
        findsOneWidget,
      );
      expect(find.text(AppLocalizationsEn().delete), findsOneWidget);
      expect(find.text(AppLocalizationsEn().cancel), findsOneWidget);

      // Confirm deletion.
      await tester.tap(find.text(AppLocalizationsEn().delete));
      await tester.pumpAndSettle();

      // Repository called and item hidden locally with SnackBar.
      expect(fakeRepo.called, isTrue);
      expect(fakeRepo.deletedId, equals('n-1'));

      // Count updates and SnackBar shown.
      expect(find.text('1 / 2 Novels'), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().removedNovel('Quiet City Nights')),
        findsOneWidget,
      );
      expect(find.text('Undo'), findsOneWidget);

      // Undo restores visibility.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2 Novels'), findsOneWidget);
      expect(find.text('Quiet City Nights'), findsOneWidget);
    },
  );
}
