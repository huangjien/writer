import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/main.dart' as app_main;
import 'package:novel_reader/repositories/novel_repository.dart';

class FakeNovelRepository extends NovelRepository {
  FakeNovelRepository() : super(SupabaseClient('http://example.com', 'anon'));
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
    final fake = FakeNovelRepository();
    final container = ProviderContainer(
      overrides: [
        novelRepositoryProvider.overrideWith((_) => fake),
        app_main.localStorageRepositoryProvider.overrideWith(
          (_) => throw UnimplementedError(),
        ),
      ],
    );
    final novels = await container.read(novelsProvider.future);
    expect(novels.length, 1);
    final ch = await container.read(chaptersProvider('n1').future);
    expect(ch.length, 1);
  });
}
