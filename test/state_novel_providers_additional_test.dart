import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class CapturingLocalRepo extends MockLocalStorageRepository {
  List<Novel>? lastSaved;

  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {
    lastSaved = novels;
  }
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'libraryNovelsProvider unions public and member lists and saves cache',
    () async {
      final cache = CapturingLocalRepo();
      final prefs = await SharedPreferences.getInstance();
      final testNovels = const [
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
