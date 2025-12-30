import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
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

void main() {
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
        isSignedInProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);
    final novels = await container.read(novelsProvider.future);
    expect(novels.length, 1);
    final ch = await container.read(chaptersProvider('n1').future);
    expect(ch.length, 1);
  });
}
