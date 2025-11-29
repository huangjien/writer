import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';

import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakeLocal extends LocalStorageRepository {
  ChapterCache? cached;
  ChapterCache? saved;
  String? removedId;
  bool throwOnRemove = false;
  @override
  Future<ChapterCache?> getChapter(String chapterId) async => cached;
  @override
  Future<void> saveChapter(ChapterCache chapter) async {
    saved = chapter;
  }

  @override
  Future<void> removeChapter(String chapterId) async {
    removedId = chapterId;
    if (throwOnRemove) throw Exception('fail remove');
  }
}

void main() {
  late MockSupabaseClient client;
  late MockSupabaseQueryBuilder qb;

  setUp(() {
    client = MockSupabaseClient();
    qb = MockSupabaseQueryBuilder();
    when(() => client.from(any())).thenAnswer((_) => qb);
  });

  test('getChapters maps list response', () async {
    final rows = [
      {'id': 'c1', 'novel_id': 'n1', 'title': 'T1', 'idx': 1},
      {'id': 'c2', 'novel_id': 'n1', 'title': 'T2', 'idx': 2},
    ];
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));
    final repo = ChapterRepository(client, FakeLocal());
    final list = await repo.getChapters('n1');
    expect(list.length, 2);
    expect(list.first.id, 'c1');
  });

  test(
    'getChapter returns cache when present, otherwise fetches and caches',
    () async {
      final local = FakeLocal();
      final repo = ChapterRepository(client, local);
      local.cached = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'T',
        content: 'X',
        lastUpdated: DateTime.now(),
      );
      final cached = await repo.getChapter(
        const Chapter(id: 'c1', novelId: 'n1', idx: 1),
      );
      expect(cached.content, 'X');

      local.cached = null;
      when(() => qb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder<List<Map<String, dynamic>>>([
          {'content': 'New'},
        ]),
      );
      final fetched = await repo.getChapter(
        const Chapter(id: 'c2', novelId: 'n1', idx: 2),
      );
      expect(fetched.content, 'New');
      expect(local.saved!.chapterId, 'c2');
      expect(local.saved!.content, 'New');
    },
  );

  test('updateChapter updates remote and caches content', () async {
    final local = FakeLocal();
    final repo = ChapterRepository(client, local);
    when(
      () => qb.update(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(null));
    final ch = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'T',
      content: 'C',
    );
    await repo.updateChapter(ch);
    expect(local.saved!.chapterId, 'c1');
    expect(local.saved!.content, 'C');
    verify(() => qb.update({'title': 'T', 'content': 'C'})).called(1);
  });

  test('getNextIdx returns 1 when none, otherwise max+1', () async {
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
    final repo = ChapterRepository(client, FakeLocal());
    final first = await repo.getNextIdx('n1');
    expect(first, 1);

    final rows = [
      {'idx': 5},
    ];
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));
    final next = await repo.getNextIdx('n1');
    expect(next, 6);
  });

  test('createChapter inserts and caches placeholder content', () async {
    final local = FakeLocal();
    final repo = ChapterRepository(client, local);
    final singleMap = {
      'id': 'c9',
      'novel_id': 'n1',
      'idx': 9,
      'title': 'T',
      'content': '',
    };
    when(
      () => qb.insert(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([singleMap]));
    when(
      () => qb.select(),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([singleMap]));
    final created = await repo.createChapter(novelId: 'n1', idx: 9, title: 'T');
    expect(created.id, 'c9');
    expect(local.saved!.chapterId, 'c9');
    verify(() => qb.insert(any())).called(1);
  });

  test(
    'deleteChapter deletes remote and tries to remove local cache',
    () async {
      final local = FakeLocal()..throwOnRemove = true;
      final repo = ChapterRepository(client, local);
      when(
        () => qb.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));
      await repo.deleteChapter('c1');
      verify(() => qb.delete()).called(1);
      expect(local.removedId, 'c1');
    },
  );
}
