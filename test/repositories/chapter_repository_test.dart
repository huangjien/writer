import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/offline_operation.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/common/errors/offline_exception.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class MockNetworkMonitor extends Mock implements NetworkMonitor {}

class MockOfflineQueueService extends Mock implements OfflineQueueService {}

void main() {
  late MockRemoteRepository remote;
  late MockLocalStorageRepository mockLocal;
  late MockNetworkMonitor mockNetworkMonitor;
  late MockOfflineQueueService mockOfflineQueue;
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
    registerFallbackValue(
      OfflineOperation(
        id: 'test-id',
        type: OperationType.updateChapter,
        chapterId: 'test-chapter',
        novelId: 'test-novel',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    remote = MockRemoteRepository();
    mockLocal = MockLocalStorageRepository();
    mockNetworkMonitor = MockNetworkMonitor();
    mockOfflineQueue = MockOfflineQueueService();
    when(() => mockLocal.getChapter(any())).thenAnswer((_) async => null);
    when(() => mockLocal.saveChapter(any())).thenAnswer((_) async {});
    when(() => mockLocal.removeChapter(any())).thenAnswer((_) async {});
    when(() => mockNetworkMonitor.isConnected).thenAnswer((_) async => true);
    when(() => mockOfflineQueue.enqueue(any())).thenAnswer((_) async {});
    repo = ChapterRepository(
      remote,
      mockLocal,
      offlineQueue: mockOfflineQueue,
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

      const chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
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

      const chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
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

      const chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');

      expect(() => repo.getChapter(chap), throwsA(isA<SocketException>()));
    });

    test(
      'updateChapter updates row and saves cache when content present',
      () async {
        when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

        const chap = Chapter(
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
      verify(
        () => remote.patch('novels/n1/chapters/reorder', {
          'updates': [
            {'chapter_id': 'c1', 'idx': 4},
            {'chapter_id': 'c2', 'idx': 5},
          ],
        }, retryUnauthorized: false),
      ).called(1);
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
      when(() => remote.delete(any())).thenAnswer((_) async => {});
      when(
        () => mockLocal.removeChapter('c1'),
      ).thenThrow(Exception('Cache remove fail'));

      await repo.deleteChapter('c1');
      // Should not throw
      verify(() => remote.delete('chapters/c1')).called(1);
    });

    test('getChapters handles invalid response format', () async {
      when(
        () => remote.get('novels/n1/chapters'),
      ).thenAnswer((_) async => 'invalid');
      final chapters = await repo.getChapters('n1');
      expect(chapters, isEmpty);
    });

    test('getChapter handles invalid response format', () async {
      when(() => remote.get('chapters/c1')).thenAnswer((_) async => 'invalid');
      const chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');

      expect(() => repo.getChapter(chap), throwsException);
    });

    test(
      'getChapter returns chapter with null content when network returns no content',
      () async {
        when(() => remote.get('chapters/c1')).thenAnswer((_) async {
          return {'content': null, 'sha': null};
        });

        const chap = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'T1');
        final res = await repo.getChapter(chap);

        expect(res.content, isNull);
        expect(res.sha, isNull);

        // Should not save to cache when content is null
        verifyNever(() => mockLocal.saveChapter(any()));
      },
    );

    group('SHA generation', () {
      test('updateChapter generates SHA for content', () async {
        when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

        const chap = Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'T1',
          content: 'test content',
        );

        await repo.updateChapter(chap);

        final captured = verify(
          () => remote.patch('chapters/c1', captureAny()),
        ).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body, contains('sha'));
        expect(body['sha'], isNotNull);
      });

      test('createChapter generates SHA for content', () async {
        final created = <String, dynamic>{
          'id': 'c9',
          'novel_id': 'n1',
          'idx': 9,
          'title': 'New',
          'content': 'test content',
        };
        when(() => remote.post(any(), any())).thenAnswer((_) async => created);

        await repo.createChapter(
          novelId: 'n1',
          idx: 9,
          title: 'New',
          content: 'test content',
        );

        final captured = verify(
          () => remote.post('chapters', captureAny()),
        ).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body, contains('sha'));
        expect(body['sha'], isNotNull);
      });

      test('updateChapter handles null content without SHA', () async {
        when(() => remote.patch(any(), any())).thenAnswer((_) async => {});

        const chap = Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'T1',
          content: null,
        );

        await repo.updateChapter(chap);

        final captured = verify(
          () => remote.patch('chapters/c1', captureAny()),
        ).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body, isNot(contains('sha')));
      });
    });

    group('Error handling', () {
      test('bulkShiftIdx handles getChapters error gracefully', () async {
        when(
          () => remote.get('novels/n1/chapters'),
        ).thenThrow(Exception('Network error'));

        expect(() => repo.bulkShiftIdx('n1', 1, 3), throwsException);
      });

      test('createChapter throws exception on invalid response', () async {
        when(
          () => remote.post(any(), any()),
        ).thenAnswer((_) async => 'invalid');

        expect(
          () => repo.createChapter(novelId: 'n1', idx: 1),
          throwsException,
        );
      });

      test('updateChapter handles network error gracefully', () async {
        when(
          () => remote.patch(any(), any()),
        ).thenThrow(Exception('Network error'));

        const chap = Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'T1',
          content: 'content',
        );

        expect(() => repo.updateChapter(chap), throwsException);
      });

      test('updateChapterIdx handles network error gracefully', () async {
        when(
          () => remote.patch(any(), any()),
        ).thenThrow(Exception('Network error'));

        expect(() => repo.updateChapterIdx('c1', 5), throwsException);
      });
    });

    group('Offline functionality', () {
      setUp(() {
        // Override the default setup for offline tests
        when(
          () => mockNetworkMonitor.isConnected,
        ).thenAnswer((_) async => false);
        // Ensure offline queue is mocked for offline tests
        when(() => mockOfflineQueue.enqueue(any())).thenAnswer((_) async {});

        // Re-create repository with offline settings
        repo = ChapterRepository(
          remote,
          mockLocal,
          offlineQueue: mockOfflineQueue,
          networkMonitor: mockNetworkMonitor,
        );
      });

      group('updateChapter offline', () {
        test('queues update operation when offline', () async {
          const chap = Chapter(
            id: 'c1',
            novelId: 'n1',
            idx: 1,
            title: 'Updated Title',
            content: 'Updated content',
          );

          try {
            await repo.updateChapter(chap);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          verify(() => mockLocal.saveChapter(any())).called(1);

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          final operation = captured.first as OfflineOperation;
          expect(operation.type, OperationType.updateChapter);
          expect(operation.chapterId, 'c1');
          expect(operation.novelId, 'n1');
          expect(operation.data!['title'], 'Updated Title');
          expect(operation.data!['content'], 'Updated content');
        });

        test('handles update without content when offline', () async {
          const chap = Chapter(
            id: 'c1',
            novelId: 'n1',
            idx: 1,
            title: 'Updated Title',
            content: null,
          );

          try {
            await repo.updateChapter(chap);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          // Use captureAny to see what was actually called
          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          verifyNever(() => mockLocal.saveChapter(any()));
        });

        test('generates SHA for content when offline', () async {
          const chap = Chapter(
            id: 'c1',
            novelId: 'n1',
            idx: 1,
            title: 'Title',
            content: 'test content',
          );

          try {
            await repo.updateChapter(chap);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          final operation = captured.first as OfflineOperation;
          expect(operation.data!['sha'], isNotNull);
          expect(operation.data!['sha'], isA<String>());
        });
      });

      group('updateChapterIdx offline', () {
        test('queues index update operation when offline', () async {
          final cache = ChapterCache(
            chapterId: 'c1',
            novelId: 'n1',
            idx: 1,
            title: 'Original Title',
            content: 'Original content',
            lastUpdated: DateTime.now(),
          );
          when(() => mockLocal.getChapter('c1')).thenAnswer((_) async => cache);

          try {
            await repo.updateChapterIdx('c1', 5);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          verify(() => mockLocal.saveChapter(any())).called(1);

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          final operation = captured.first as OfflineOperation;
          expect(operation.type, OperationType.updateChapterIdx);
          expect(operation.chapterId, 'c1');
          expect(operation.novelId, 'n1');
          expect(operation.data!['chapter_id'], 'c1');
          expect(operation.data!['new_idx'], 5);
        });

        test('handles missing cache gracefully when offline', () async {
          when(() => mockLocal.getChapter('c1')).thenAnswer((_) async => null);

          try {
            await repo.updateChapterIdx('c1', 5);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          verifyNever(() => mockLocal.saveChapter(any()));

          final operation = captured.first as OfflineOperation;
          expect(operation.type, OperationType.updateChapterIdx);
          expect(operation.chapterId, 'c1');
          expect(operation.data!['chapter_id'], 'c1');
          expect(operation.data!['new_idx'], 5);
        });
      });

      group('createChapter offline', () {
        test(
          'queues create operation and saves to cache when offline',
          () async {
            try {
              await repo.createChapter(
                novelId: 'n1',
                idx: 1,
                title: 'New Chapter',
                content: 'New content',
              );
              fail('Expected OfflineException');
            } catch (e) {
              expect(e, isA<OfflineException>());
            }

            final captured = verify(
              () => mockOfflineQueue.enqueue(captureAny()),
            ).captured;
            expect(captured.length, 1);
            verify(() => mockLocal.saveChapter(any())).called(1);
            final operation = captured.first as OfflineOperation;
            expect(operation.type, OperationType.createChapter);
            expect(operation.novelId, 'n1');
            expect(operation.data!['novel_id'], 'n1');
            expect(operation.data!['idx'], 1);
            expect(operation.data!['title'], 'New Chapter');
            expect(operation.data!['content'], 'New content');
            expect(operation.data!['sha'], isNotNull);
          },
        );

        test('generates temporary local ID when offline', () async {
          final startTime = DateTime.now().millisecondsSinceEpoch;

          try {
            await repo.createChapter(novelId: 'n1', idx: 1);
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          final operation = captured.first as OfflineOperation;
          expect(operation.chapterId, startsWith('local_'));
          // The timestamp should be close to our start time (within 2 seconds)
          final timestampStr = operation.chapterId!.replaceFirst('local_', '');
          final timestamp = int.parse(timestampStr);
          expect(timestamp, greaterThanOrEqualTo(startTime));
          expect(timestamp, lessThan(startTime + 2000));
        });

        test('handles creation without content when offline', () async {
          try {
            await repo.createChapter(
              novelId: 'n1',
              idx: 1,
              title: 'Untitled',
              content: null,
            );
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
          final operation = captured.first as OfflineOperation;
          expect(operation.data!['content'], isNull);
          expect(operation.data!['sha'], isNotNull);
        });
      });

      group('deleteChapter offline', () {
        test(
          'queues delete operation and removes from cache when offline',
          () async {
            try {
              await repo.deleteChapter('c1');
              fail('Expected OfflineException');
            } catch (e) {
              expect(e, isA<OfflineException>());
            }

            verify(() => mockLocal.removeChapter('c1')).called(1);

            final captured = verify(
              () => mockOfflineQueue.enqueue(captureAny()),
            ).captured;
            expect(captured.length, 1);
            final operation = captured.first as OfflineOperation;
            expect(operation.type, OperationType.deleteChapter);
            expect(operation.chapterId, 'c1');
            expect(operation.data!['chapter_id'], 'c1');
          },
        );

        test('handles cache removal failure gracefully when offline', () async {
          when(
            () => mockLocal.removeChapter('c1'),
          ).thenThrow(Exception('Cache error'));

          try {
            await repo.deleteChapter('c1');
            fail('Expected OfflineException');
          } catch (e) {
            expect(e, isA<OfflineException>());
          }

          final captured = verify(
            () => mockOfflineQueue.enqueue(captureAny()),
          ).captured;
          expect(captured.length, 1);
        });
      });
    });
  });
}
