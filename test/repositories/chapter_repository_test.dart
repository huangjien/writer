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

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQuery;
  late MockLocalStorageRepository mockLocal;
  late ChapterRepository repo;

  setUpAll(() {
    registerFallbackValue(
      ChapterCache(
        chapterId: 'x',
        novelId: 'n',
        idx: 0,
        title: 't',
        content: '',
        lastUpdated: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQuery = MockSupabaseQueryBuilder();
    mockLocal = MockLocalStorageRepository();
    when(() => mockClient.from('chapters')).thenAnswer((_) => mockQuery);
    when(() => mockLocal.getChapter(any())).thenAnswer((_) async => null);
    when(() => mockLocal.saveChapter(any())).thenAnswer((_) async {});
    when(() => mockLocal.removeChapter(any())).thenAnswer((_) async {});
    repo = ChapterRepository(mockClient, mockLocal);
  });

  group('ChapterRepository', () {
    test('getChapters returns list of chapters ordered by idx', () async {
      final rows = [
        {'id': 'c1', 'novel_id': 'n1', 'title': 'T1', 'idx': 1},
        {'id': 'c2', 'novel_id': 'n1', 'title': 'T2', 'idx': 2},
      ];
      when(
        () => mockQuery.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));

      final chapters = await repo.getChapters('n1');
      expect(chapters.length, 2);
      expect(chapters.first.id, 'c1');
      expect(chapters.last.id, 'c2');
    });

    test('getChapter returns cache hit without Supabase call', () async {
      final cache = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'T1',
        content: 'cached',
        lastUpdated: DateTime.now(),
      );
      when(() => mockLocal.getChapter('c1')).thenAnswer((_) async => cache);

      final chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
      final res = await repo.getChapter(chap);
      expect(res.content, 'cached');
      verifyNever(() => mockQuery.select('content, sha'));
    });

    test(
      'getChapter cache miss fetches from Supabase and saves cache',
      () async {
        when(() => mockLocal.getChapter('c1')).thenAnswer((_) async => null);
        final row = [
          {'content': 'remote', 'sha': 'abc'},
        ];
        when(
          () => mockQuery.select('content, sha'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(row));

        final chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
        final res = await repo.getChapter(chap);
        expect(res.content, 'remote');
        expect(res.sha, 'abc');
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test(
      'updateChapter updates row and saves cache when content present',
      () async {
        when(
          () => mockQuery.update(any()),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

        final chap = Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'T1',
          content: 'new',
        );
        await repo.updateChapter(chap);

        verify(() => mockClient.from('chapters')).called(1);
        verify(() => mockQuery.update(any())).called(1);
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test(
      'updateChapterIdx updates idx and refreshes cache when available',
      () async {
        when(
          () => mockQuery.update(any()),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

        when(() => mockLocal.getChapter('c1')).thenAnswer(
          (_) async => ChapterCache(
            chapterId: 'c1',
            novelId: 'n1',
            idx: 1,
            title: 'T1',
            content: 'x',
            lastUpdated: DateTime.now(),
          ),
        );

        await repo.updateChapterIdx('c1', 5);
        verify(() => mockQuery.update({'idx': 5})).called(1);
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test('bulkShiftIdx shifts each row by delta', () async {
      final rows = [
        {'id': 'c1', 'idx': 1},
        {'id': 'c2', 'idx': 2},
      ];
      when(
        () => mockQuery.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));
      when(
        () => mockQuery.update(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repo.bulkShiftIdx('n1', 1, 3);
      verify(() => mockClient.from('chapters')).called(greaterThan(0));
      verify(() => mockQuery.update(any())).called(2);
    });

    test('getNextIdx returns 1 when none, else max+1', () async {
      when(
        () => mockQuery.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([]));
      final n1 = await repo.getNextIdx('n1');
      expect(n1, 1);

      when(() => mockQuery.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {'idx': 7},
        ]),
      );
      final n2 = await repo.getNextIdx('n1');
      expect(n2, 8);
    });

    test(
      'createChapter inserts and returns created; caches placeholder',
      () async {
        final created = {
          'id': 'c9',
          'novel_id': 'n1',
          'idx': 9,
          'title': 'New',
          'content': '',
        };
        when(
          () => mockQuery.insert(any()),
        ).thenAnswer((_) => FakePostgrestFilterBuilder([created]));

        final res = await repo.createChapter(
          novelId: 'n1',
          idx: 9,
          title: 'New',
          content: null,
        );
        expect(res.id, 'c9');
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test('deleteChapter deletes and clears cache', () async {
      when(
        () => mockQuery.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repo.deleteChapter('c1');
      verify(() => mockClient.from('chapters')).called(1);
      verify(() => mockQuery.delete()).called(1);
      verify(() => mockLocal.removeChapter('c1')).called(1);
    });
  });
}
