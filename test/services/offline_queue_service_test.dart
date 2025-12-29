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
  });
}
