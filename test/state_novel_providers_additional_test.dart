import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/services/data_manager.dart';
import 'package:writer/state/data_manager_provider.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class CapturingLocalRepo extends MockLocalStorageRepository {
  List<Novel>? lastSaved;

  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {
    lastSaved = novels;
  }
}

class MockNovelRepository extends Mock implements NovelRepository {}

class MockDataManager extends Mock implements DataManager {}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(const Chapter(id: 'c1', novelId: 'n1', idx: 0));
  });
  test(
    'libraryNovelsProvider unions public and member lists and saves cache',
    () async {
      final cache = CapturingLocalRepo();
      final prefs = await SharedPreferences.getInstance();
      const testNovels = [
        Novel(
          id: 'n1',
          title: 'A',
          author: 'X',
          description: 'D',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        Novel(
          id: 'n2',
          title: 'B',
          author: null,
          description: null,
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWith((_) => true),
          authStateProvider.overrideWith((_) => 'session'),
          localStorageRepositoryProvider.overrideWith((_) => cache),
          libraryNovelsProviderV2.overrideWith((ref) async => testNovels),
        ],
      );
      final union = await container.read(libraryNovelsProviderV2.future);
      expect(union.map((n) => n.id).toSet(), {'n1', 'n2'});
    },
  );

  test('novelProvider returns a single novel by id', () async {
    final container = ProviderContainer(
      overrides: [
        novelsProvider.overrideWith((ref) async => const []),
        novelRepositoryProvider.overrideWith((ref) => FakeNovelSingle()),
      ],
    );
    final n = await container.read(novelProvider('nx').future);
    expect(n?.id, 'nx');
  });

  test(
    'libraryNovelsProvider merges cached novels when memberNovelsProvider errors',
    () async {
      final local = CapturingLocalRepo();
      final repo = MockNovelRepository();
      const publicNovels = [
        Novel(
          id: 'p1',
          title: 'Public',
          author: null,
          description: null,
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
      ];
      const cachedNovels = [
        Novel(
          id: 'c1',
          title: 'Cached',
          author: null,
          description: null,
          coverUrl: null,
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      when(repo.fetchPublicNovels).thenAnswer((_) async => publicNovels);
      when(local.getLibraryNovels).thenAnswer((_) async => cachedNovels);

      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          authStateProvider.overrideWithValue('session'),
          novelRepositoryProvider.overrideWithValue(repo),
          localStorageRepositoryProvider.overrideWithValue(local),
          memberNovelsProvider.overrideWith((ref) => throw Exception('fail')),
        ],
      );
      addTearDown(container.dispose);

      final union = await container.read(libraryNovelsProvider.future);
      expect(union.map((n) => n.id).toSet(), {'p1', 'c1'});
    },
  );

  test(
    'libraryNovelsProvider returns public list when member errors and cache empty',
    () async {
      final local = CapturingLocalRepo();
      final repo = MockNovelRepository();
      const publicNovels = [
        Novel(
          id: 'p1',
          title: 'Public',
          author: null,
          description: null,
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      when(repo.fetchPublicNovels).thenAnswer((_) async => publicNovels);
      when(local.getLibraryNovels).thenAnswer((_) async => const []);

      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          authStateProvider.overrideWithValue('session'),
          novelRepositoryProvider.overrideWithValue(repo),
          localStorageRepositoryProvider.overrideWithValue(local),
          memberNovelsProvider.overrideWith((ref) => throw Exception('fail')),
        ],
      );
      addTearDown(container.dispose);

      final union = await container.read(libraryNovelsProvider.future);
      expect(union.map((n) => n.id).toList(), ['p1']);
    },
  );

  test(
    'recentProgressDetailsProviderV2 builds details from data manager',
    () async {
      final manager = MockDataManager();
      const novel = Novel(
        id: 'n1',
        title: 'Novel',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: false,
      );
      const chapter = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'Ch');
      final progress = UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0,
        ttsCharIndex: 0,
        updatedAt: DateTime(2026, 1, 1),
      );

      when(() => manager.getNovel('n1')).thenAnswer((_) async => novel);
      when(() => manager.getChapter(any())).thenAnswer((_) async => chapter);

      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          authStateProvider.overrideWithValue('session'),
          dataManagerProvider.overrideWithValue(manager),
          recentUserProgressProvider.overrideWith((ref) async => [progress]),
        ],
      );
      addTearDown(container.dispose);

      final details = await container.read(
        recentProgressDetailsProviderV2.future,
      );
      expect(details, hasLength(1));
      expect(details.first.novel.id, 'n1');
      expect(details.first.chapter.id, 'c1');
    },
  );

  test('novelsProviderV2 returns cached novels when not signed in', () async {
    final local = CapturingLocalRepo();
    const cached = [
      Novel(
        id: 'c1',
        title: 'Cached',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: false,
      ),
    ];
    when(local.getLibraryNovels).thenAnswer((_) async => cached);

    final manager = MockDataManager();
    when(manager.getAllNovels).thenAnswer((_) async => const []);

    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWithValue(false),
        authStateProvider.overrideWithValue('session'),
        localStorageRepositoryProvider.overrideWithValue(local),
        dataManagerProvider.overrideWithValue(manager),
      ],
    );
    addTearDown(container.dispose);

    final novels = await container.read(novelsProviderV2.future);
    expect(novels.map((n) => n.id).toList(), ['c1']);
    verifyNever(manager.getAllNovels);
  });

  test('novelsProviderV2 returns data manager novels when signed in', () async {
    final local = CapturingLocalRepo();
    when(local.getLibraryNovels).thenAnswer((_) async => const []);

    final manager = MockDataManager();
    const fromManager = [
      Novel(
        id: 'd1',
        title: 'From Manager',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: false,
      ),
    ];
    when(manager.getAllNovels).thenAnswer((_) async => fromManager);

    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWithValue(true),
        authStateProvider.overrideWithValue('session'),
        localStorageRepositoryProvider.overrideWithValue(local),
        dataManagerProvider.overrideWithValue(manager),
      ],
    );
    addTearDown(container.dispose);

    final novels = await container.read(novelsProviderV2.future);
    expect(novels.map((n) => n.id).toList(), ['d1']);
    verify(manager.getAllNovels).called(1);
  });

  test('novelsProvider returns empty when not signed in', () async {
    final repo = MockNovelRepository();
    when(repo.fetchPublicNovels).thenAnswer((_) async => const []);

    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWithValue(false),
        authStateProvider.overrideWith((ref) => null),
        novelRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final novels = await container.read(novelsProvider.future);
    expect(novels, isEmpty);
    verifyNever(repo.fetchPublicNovels);
  });

  test('memberNovelsProvider returns empty when not signed in', () async {
    final repo = MockNovelRepository();
    when(repo.fetchMemberNovels).thenAnswer((_) async => const []);

    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWithValue(false),
        authStateProvider.overrideWithValue('session'),
        novelRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final novels = await container.read(memberNovelsProvider.future);
    expect(novels, isEmpty);
    verifyNever(repo.fetchMemberNovels);
  });

  test(
    'recentProgressDetailsProvider skips missing novel and missing chapter',
    () async {
      final progress = UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0,
        ttsCharIndex: 0,
        updatedAt: DateTime(2026, 1, 1),
      );
      const novel = Novel(
        id: 'n1',
        title: 'Novel',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: false,
      );
      const chapter = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'Ch');

      final repoMissingNovel = MockNovelRepository();
      when(() => repoMissingNovel.getNovel('n1')).thenAnswer((_) async => null);
      when(
        () => repoMissingNovel.getChapter('c1'),
      ).thenAnswer((_) async => chapter);

      final container = ProviderContainer(
        overrides: [
          recentUserProgressProvider.overrideWith((ref) async => [progress]),
          novelRepositoryProvider.overrideWithValue(repoMissingNovel),
        ],
      );
      addTearDown(container.dispose);

      final detailsMissingNovel = await container.read(
        recentProgressDetailsProvider.future,
      );
      expect(detailsMissingNovel, isEmpty);

      final repoMissingChapter = MockNovelRepository();
      when(
        () => repoMissingChapter.getNovel('n1'),
      ).thenAnswer((_) async => novel);
      when(
        () => repoMissingChapter.getChapter('c1'),
      ).thenAnswer((_) async => null);

      final container2 = ProviderContainer(
        overrides: [
          recentUserProgressProvider.overrideWith((ref) async => [progress]),
          novelRepositoryProvider.overrideWithValue(repoMissingChapter),
        ],
      );
      addTearDown(container2.dispose);

      final detailsMissingChapter = await container2.read(
        recentProgressDetailsProvider.future,
      );
      expect(detailsMissingChapter, isEmpty);
    },
  );
}

class FakeNovelSingle extends NovelRepository {
  FakeNovelSingle() : super(RemoteRepository('http://example.com'));
  @override
  Future<Novel?> getNovel(String novelId) async {
    return Novel(
      id: novelId,
      title: 'T',
      author: 'A',
      description: 'D',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
  }
}
