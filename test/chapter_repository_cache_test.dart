import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';

class FailingRemoteRepository extends RemoteRepository {
  FailingRemoteRepository() : super('http://test/');

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    throw Exception('offline');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('getChapter returns cached Chapter when available', () async {
    final local = LocalStorageRepository();
    await local.saveChapter(
      ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Cached Title',
        content: 'Cached Content',
        lastUpdated: DateTime.utc(2024, 1, 1),
      ),
    );

    final repo = ChapterRepository(FailingRemoteRepository(), local);
    final base = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'Base',
      content: null,
    );
    final got = await repo.getChapter(base);
    expect(got.content, 'Cached Content');
    expect(got.title, 'Cached Title');
  });
}
