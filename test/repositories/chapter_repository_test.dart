import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class MockNetworkMonitor extends Mock implements NetworkMonitor {}

void main() {
  late MockRemoteRepository remote;
  late MockLocalStorageRepository mockLocal;
  late MockNetworkMonitor mockNetworkMonitor;
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
    remote = MockRemoteRepository();
    mockLocal = MockLocalStorageRepository();
    mockNetworkMonitor = MockNetworkMonitor();
    when(() => mockLocal.getChapter(any())).thenAnswer((_) async => null);
    when(() => mockLocal.saveChapter(any())).thenAnswer((_) async {});
    when(() => mockLocal.removeChapter(any())).thenAnswer((_) async {});
    when(() => mockNetworkMonitor.isConnected).thenAnswer((_) async => true);
    repo = ChapterRepository(
      remote,
      mockLocal,
      networkMonitor: mockNetworkMonitor,
    );
  });

  group('ChapterRepository', () {
    test('getChapters returns list of chapters ordered by idx', () async {
      final rows = [
        {'id': 'c1', 'novel_id': 'n1', 'title': 'T1', 'idx': 1},
        {'id': 'c2', 'novel_id': 'n1', 'title': 'T2', 'idx': 2},
      ];
      when(
        () => remote.get('novels/n1/chapters'),
      ).thenAnswer((_) async => rows);

      final chapters = await repo.getChapters('n1');
      expect(chapters.length, 2);
      expect(chapters.first.id, 'c1');
      expect(chapters.last.id, 'c2');
      verify(() => remote.get('novels/n1/chapters')).called(1);
    });

    test('getChapter prefers network and updates cache on success', () async {
      when(() => remote.get('chapters/c1')).thenAnswer((_) async {
        return {'content': 'remote', 'sha': 'abc'};
      });

      final chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
      final res = await repo.getChapter(chap);

      expect(res.content, 'remote');
      expect(res.sha, 'abc');

      // Should save to cache
      verify(() => mockLocal.saveChapter(any())).called(1);
    });

    test('getChapter falls back to cache on network failure', () async {
      // Setup: Network fails
      when(
        () => remote.get('chapters/c1'),
      ).thenThrow(const SocketException('No Internet'));

      // Setup: Cache exists
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
      // Verify both were called
      verify(() => remote.get('chapters/c1')).called(1);
      verify(() => mockLocal.getChapter('c1')).called(1);
    });

    test('getChapter rethrows network error on cache miss', () async {
      when(
        () => remote.get('chapters/c1'),
      ).thenThrow(const SocketException('No Internet'));
      when(() => mockLocal.getChapter('c1')).thenAnswer((_) async => null);

      final chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');

      expect(() => repo.getChapter(chap), throwsA(isA<SocketException>()));
    });

    test(
      'updateChapter updates row and saves cache when content present',
      () async {
        when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

        final chap = Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'T1',
          content: 'new',
        );
        await repo.updateChapter(chap);

        verify(() => remote.patch('chapters/c1', any())).called(1);
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test(
      'updateChapterIdx updates idx and refreshes cache when available',
      () async {
        when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

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
        verify(() => remote.patch('chapters/c1', {'idx': 5})).called(1);
        verify(() => mockLocal.saveChapter(any())).called(1);
      },
    );

    test('bulkShiftIdx shifts each row by delta', () async {
      when(() => remote.get('novels/n1/chapters')).thenAnswer((_) async {
        return [
          {'id': 'c1', 'novel_id': 'n1', 'title': 'T1', 'idx': 1},
          {'id': 'c2', 'novel_id': 'n1', 'title': 'T2', 'idx': 2},
        ];
      });
      when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

      await repo.bulkShiftIdx('n1', 1, 3);
      verify(() => remote.patch('chapters/c1', {'idx': 4})).called(1);
      verify(() => remote.patch('chapters/c2', {'idx': 5})).called(1);
    });

    test('getNextIdx returns 1 when none, else max+1', () async {
      when(() => remote.get('novels/n1/chapters')).thenAnswer((_) async => []);
      final n1 = await repo.getNextIdx('n1');
      expect(n1, 1);

      when(() => remote.get('novels/n1/chapters')).thenAnswer((_) async {
        return [
          {'id': 'c1', 'novel_id': 'n1', 'title': 'T1', 'idx': 7},
        ];
      });
      final n2 = await repo.getNextIdx('n1');
      expect(n2, 8);
    });

    test(
      'createChapter inserts and returns created; caches placeholder',
      () async {
        final created = <String, dynamic>{
          'id': 'c9',
          'novel_id': 'n1',
          'idx': 9,
          'title': 'New',
          'content': '',
        };
        when(() => remote.post(any(), any())).thenAnswer((_) async => created);

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
      when(() => remote.delete(any())).thenAnswer((_) async {});

      await repo.deleteChapter('c1');
      verify(() => remote.delete('chapters/c1')).called(1);
      verify(() => mockLocal.removeChapter('c1')).called(1);
    });

    test('updateChapterIdx handles cache update failure gracefully', () async {
      when(() => remote.patch(any(), any())).thenAnswer((_) async => {});
      when(
        () => mockLocal.getChapter('c1'),
      ).thenThrow(Exception('Cache Error'));

      await repo.updateChapterIdx('c1', 2);
      // Should not throw
      verify(() => remote.patch('chapters/c1', {'idx': 2})).called(1);
    });

    test('getNextIdx returns 1 on getChapters error', () async {
      when(() => remote.get('novels/n1/chapters')).thenThrow(Exception('err'));
      expect(await repo.getNextIdx('n1'), 1);
    });

    test('deleteChapter handles local cache failure gracefully', () async {
      when(() => remote.delete(any())).thenAnswer((_) async {});
      when(
        () => mockLocal.removeChapter('c1'),
      ).thenThrow(Exception('Cache remove fail'));

      await repo.deleteChapter('c1');
      // Should not throw
      verify(() => remote.delete('chapters/c1')).called(1);
    });
  });
}
