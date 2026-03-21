import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNovelRepository extends NovelRepository {
  FakeNovelRepository() : super(RemoteRepository('http://example.com'));
  List<Novel> novels = const [
    Novel(
      id: 'n1',
      title: 'A',
      author: 'X',
      description: 'D',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    ),
  ];
  List<Chapter> chapters = const [
    Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T', content: 'C'),
  ];
  @override
  Future<List<Novel>> fetchPublicNovels() async => novels;
  @override
  Future<List<Novel>> fetchMemberNovels({
    int limit = 50,
    int offset = 0,
  }) async => novels;
  @override
  Future<Novel?> getNovel(String novelId) async =>
      novels.firstWhere((n) => n.id == novelId);
  @override
  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async => chapters;
}

class MockNetworkMonitor implements NetworkMonitor {
  @override
  bool get isOnline => true;

  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get connectivityStream => const Stream.empty();

  @override
  void startMonitoring() {}

  @override
  void stopMonitoring() {}

  @override
  void dispose() {}
}

void main() {
  group('novel_providers_v2', () {
    test('novels and chapters providers return from repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          chaptersProviderV2('n1').overrideWith((ref) => fake.chapters),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(novelsProvider.future);
      expect(novels.length, 1);
      final ch = await container.read(chaptersProviderV2('n1').future);
      expect(ch.length, 1);
    });

    test('novelsProviderV2 returns local novels when not signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          isSignedInProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(novelsProviderV2.future);
      expect(novels, isA<List<Novel>>());
    });

    test(
      'memberNovelsProviderV2 returns empty list when not signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storageService = LocalStorageService(prefs);
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            localStorageRepositoryProvider.overrideWith(
              (_) => LocalStorageRepository(storageService),
            ),
            isSignedInProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);
        final novels = await container.read(memberNovelsProviderV2.future);
        expect(novels, isEmpty);
      },
    );

    test('memberNovelsProviderV2 returns only non-public novels', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(memberNovelsProviderV2.future);
      expect(novels, isEmpty);
    });

    test(
      'libraryNovelsProviderV2 returns local novels when not signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storageService = LocalStorageService(prefs);
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            localStorageRepositoryProvider.overrideWith(
              (_) => LocalStorageRepository(storageService),
            ),
            isSignedInProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);
        final novels = await container.read(libraryNovelsProviderV2.future);
        expect(novels, isA<List<Novel>>());
      },
    );

    test('chaptersProviderV2 returns empty list when not signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final chapters = await container.read(chaptersProviderV2('n1').future);
      expect(chapters, isEmpty);
    });

    test('novelsProviderV2 reuses libraryNovelsProviderV2 result', () async {
      const novels = [
        Novel(
          id: 'public-1',
          title: 'Public',
          author: 'Author',
          description: 'Description',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        Novel(
          id: 'member-1',
          title: 'Member',
          author: 'Author',
          description: 'Description',
          coverUrl: null,
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
        ],
      );
      addTearDown(container.dispose);

      final resolved = await container.read(novelsProviderV2.future);
      expect(resolved, novels);
    });

    test(
      'memberNovelsProviderV2 filters from libraryNovelsProviderV2',
      () async {
        const novels = [
          Novel(
            id: 'public-1',
            title: 'Public',
            author: 'Author',
            description: 'Description',
            coverUrl: null,
            languageCode: 'en',
            isPublic: true,
          ),
          Novel(
            id: 'member-1',
            title: 'Member',
            author: 'Author',
            description: 'Description',
            coverUrl: null,
            languageCode: 'en',
            isPublic: false,
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            libraryNovelsProviderV2.overrideWith((ref) async => novels),
          ],
        );
        addTearDown(container.dispose);

        final resolved = await container.read(memberNovelsProviderV2.future);
        expect(resolved.length, 1);
        expect(resolved.first.id, 'member-1');
      },
    );
  });

  group('novel_providers', () {
    test('novelsProvider returns empty list when not signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => FakeNovelRepository()),
          isSignedInProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(novelsProvider.future);
      expect(novels, isEmpty);
    });

    test('novelsProvider returns public novels when signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(novelsProvider.future);
      expect(novels.length, 1);
    });

    test(
      'memberNovelsProvider returns empty list when not signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storageService = LocalStorageService(prefs);
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            localStorageRepositoryProvider.overrideWith(
              (_) => LocalStorageRepository(storageService),
            ),
            novelRepositoryProvider.overrideWith((_) => FakeNovelRepository()),
            isSignedInProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);
        final novels = await container.read(memberNovelsProvider.future);
        expect(novels, isEmpty);
      },
    );

    test('memberNovelsProvider returns member novels when signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final novels = await container.read(memberNovelsProvider.future);
      expect(novels.length, 1);
    });

    test(
      'libraryNovelsProvider returns cached novels when not signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storageService = LocalStorageService(prefs);
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            localStorageRepositoryProvider.overrideWith(
              (_) => LocalStorageRepository(storageService),
            ),
            novelRepositoryProvider.overrideWith((_) => FakeNovelRepository()),
            isSignedInProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);
        final novels = await container.read(libraryNovelsProvider.future);
        expect(novels, isA<List<Novel>>());
      },
    );

    test('novelProvider returns novel from repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final novel = await container.read(novelProvider('n1').future);
      expect(novel?.id, 'n1');
    });

    test('chaptersProvider returns empty list when not signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final chapters = await container.read(chaptersProvider('n1').future);
      expect(chapters, isEmpty);
    });

    test('chaptersProvider returns chapters when signed in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final fake = FakeNovelRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith(
            (_) => LocalStorageRepository(storageService),
          ),
          novelRepositoryProvider.overrideWith((_) => fake),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      final chapters = await container.read(chaptersProvider('n1').future);
      expect(chapters.length, 1);
    });
  });
}
