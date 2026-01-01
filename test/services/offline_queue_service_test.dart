import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/models/offline_operation.dart';
import 'dart:convert';

void main() {
  late OfflineQueueService queueService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    queueService = OfflineQueueService();
  });

  group('OfflineQueueService', () {
    test('enqueue should add operation to queue', () async {
      final op = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op);

      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getString('offline_ops_queue');
      expect(queue, isNotNull);
      expect(jsonDecode(queue!), ['1']);

      final opJson = prefs.getString('offline_op_1');
      expect(opJson, isNotNull);
      final storedOp = OfflineOperation.fromJson(jsonDecode(opJson!));
      expect(storedOp.id, '1');
      expect(storedOp.type, OperationType.createChapter);
    });

    test('getPendingOperations should return enqueued operations', () async {
      final op1 = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test 1'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final op2 = OfflineOperation(
        id: '2',
        novelId: 'novel-1',
        type: OperationType.updateChapter,
        data: {'title': 'Test 2'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op1);
      await queueService.enqueue(op2);

      final pending = await queueService.getPendingOperations();
      expect(pending.length, 2);
      expect(pending[0].id, '1');
      expect(pending[1].id, '2');
    });

    test('markCompleted should set isPending to false', () async {
      final op = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op);
      await queueService.markCompleted('1');

      final prefs = await SharedPreferences.getInstance();
      final opJson = prefs.getString('offline_op_1');
      final storedOp = OfflineOperation.fromJson(jsonDecode(opJson!));
      expect(storedOp.isPending, false);

      final pending = await queueService.getPendingOperations();
      expect(pending, isEmpty);
    });

    test('markFailed should set error and keep isPending true', () async {
      final op = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op);
      await queueService.markFailed('1', 'Error message');

      final prefs = await SharedPreferences.getInstance();
      final opJson = prefs.getString('offline_op_1');
      final storedOp = OfflineOperation.fromJson(jsonDecode(opJson!));
      expect(storedOp.isPending, true);
      expect(storedOp.lastError, 'Error message');

      final pending = await queueService.getPendingOperations();
      expect(pending.length, 1);
      expect(pending[0].lastError, 'Error message');
    });

    test('incrementRetry should increase retry count', () async {
      final op = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op);
      await queueService.incrementRetry('1');
      await queueService.incrementRetry('1');

      final prefs = await SharedPreferences.getInstance();
      final opJson = prefs.getString('offline_op_1');
      final storedOp = OfflineOperation.fromJson(jsonDecode(opJson!));
      expect(storedOp.retryCount, 2);
    });

    test(
      'clearCompleted should remove completed operations from queue',
      () async {
        final op1 = OfflineOperation(
          id: '1',
          novelId: 'novel-1',
          type: OperationType.createChapter,
          data: {'title': 'Test 1'},
          createdAt: DateTime.now(),
        );
        final op2 = OfflineOperation(
          id: '2',
          novelId: 'novel-1',
          type: OperationType.updateChapter,
          data: {'title': 'Test 2'},
          createdAt: DateTime.now(),
        );

        await queueService.enqueue(op1);
        await queueService.enqueue(op2);
        await queueService.markCompleted('1');

        await queueService.clearCompleted();

        final pending = await queueService.getPendingOperations();
        expect(pending.length, 1);
        expect(pending[0].id, '2');
      },
    );

    test('getPendingCount should return count of pending operations', () async {
      final op1 = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test 1'},
        createdAt: DateTime.now(),
      );
      final op2 = OfflineOperation(
        id: '2',
        novelId: 'novel-1',
        type: OperationType.updateChapter,
        data: {'title': 'Test 2'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op1);
      await queueService.enqueue(op2);
      await queueService.markCompleted('1');

      final count = await queueService.getPendingCount();
      expect(count, 1);
    });

    test(
      'removeOperation should remove operation from queue and storage',
      () async {
        final op = OfflineOperation(
          id: '1',
          novelId: 'novel-1',
          type: OperationType.createChapter,
          data: {'title': 'Test'},
          createdAt: DateTime.now(),
        );

        await queueService.enqueue(op);
        await queueService.removeOperation('1');

        final prefs = await SharedPreferences.getInstance();
        final queue = prefs.getString('offline_ops_queue');
        expect(queue, '[]');

        final opJson = prefs.getString('offline_op_1');
        expect(opJson, isNull);

        final pending = await queueService.getPendingOperations();
        expect(pending, isEmpty);
      },
    );

    test(
      'should handle invalid JSON gracefully in getPendingOperations',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('offline_ops_queue', '["1", "2"]');
        await prefs.setString('offline_op_1', '{"invalid": json}');
        await prefs.setString(
          'offline_op_2',
          '{"id": "2", "type": "updateChapter", "data": {}, "createdAt": "2023-01-01T00:00:00.000Z", "isPending": true, "novelId": "novel-1", "chapterId": "2", "retryCount": 0, "lastError": null}',
        );

        final pending = await queueService.getPendingOperations();
        expect(pending.length, 1);
        expect(pending[0].id, '2');
      },
    );

    test('should handle missing queue key gracefully', () async {
      final pending = await queueService.getPendingOperations();
      expect(pending, isEmpty);
    });

    test('should handle operations marked as not pending', () async {
      final op1 = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test 1'},
        createdAt: DateTime.now(),
        isPending: false,
      );
      final op2 = OfflineOperation(
        id: '2',
        novelId: 'novel-1',
        type: OperationType.updateChapter,
        data: {'title': 'Test 2'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(op1);
      await queueService.enqueue(op2);

      final pending = await queueService.getPendingOperations();
      expect(pending.length, 1);
      expect(pending[0].id, '2');
    });

    test('should sort operations by creation time', () async {
      final op1 = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test 1'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      final op2 = OfflineOperation(
        id: '2',
        novelId: 'novel-1',
        type: OperationType.updateChapter,
        data: {'title': 'Test 2'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );
      final op3 = OfflineOperation(
        id: '3',
        novelId: 'novel-1',
        type: OperationType.deleteChapter,
        data: {'chapter_id': '3'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      // Enqueue in random order
      await queueService.enqueue(op2);
      await queueService.enqueue(op3);
      await queueService.enqueue(op1);

      final pending = await queueService.getPendingOperations();
      expect(pending.length, 3);
      expect(pending[0].id, '1'); // Oldest
      expect(pending[1].id, '2'); // Middle
      expect(pending[2].id, '3'); // Newest
    });

    test('should handle markCompleted on non-existent operation', () async {
      await queueService.markCompleted('non-existent');
      // Should not throw
    });

    test('should handle markFailed on non-existent operation', () async {
      await queueService.markFailed('non-existent', 'Error');
      // Should not throw
    });

    test('should handle incrementRetry on non-existent operation', () async {
      await queueService.incrementRetry('non-existent');
      // Should not throw
    });

    test('should handle custom SharedPreferences function', () async {
      final customService = OfflineQueueService(
        prefs: () async => SharedPreferences.getInstance(),
      );

      final op = OfflineOperation(
        id: '1',
        novelId: 'novel-1',
        type: OperationType.createChapter,
        data: {'title': 'Test'},
        createdAt: DateTime.now(),
      );

      await customService.enqueue(op);

      final pending = await customService.getPendingOperations();
      expect(pending.length, 1);
      expect(pending[0].id, '1');
    });
  });
}
