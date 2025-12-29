import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/offline_operation.dart';

void main() {
  group('OfflineOperation', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'op-1',
        'type': 'createChapter',
        'chapterId': 'c-1',
        'novelId': 'n-1',
        'data': {'title': 'New Chapter'},
        'createdAt': '2023-01-01T12:00:00.000Z',
        'retryCount': 1,
        'lastError': 'Network error',
        'isPending': true,
        'baseSha': 'sha123',
      };

      final op = OfflineOperation.fromJson(json);

      expect(op.id, 'op-1');
      expect(op.type, OperationType.createChapter);
      expect(op.chapterId, 'c-1');
      expect(op.novelId, 'n-1');
      expect(op.data, {'title': 'New Chapter'});
      expect(op.createdAt, DateTime.utc(2023, 1, 1, 12, 0, 0));
      expect(op.retryCount, 1);
      expect(op.lastError, 'Network error');
      expect(op.isPending, true);
      expect(op.baseSha, 'sha123');
    });

    test('toJson should serialize correctly', () {
      final op = OfflineOperation(
        id: 'op-1',
        type: OperationType.updateChapter,
        chapterId: 'c-1',
        novelId: 'n-1',
        data: {'content': 'Updated'},
        createdAt: DateTime.utc(2023, 1, 1, 12, 0, 0),
        retryCount: 2,
        lastError: 'Timeout',
        isPending: false,
        baseSha: 'sha456',
      );

      final json = op.toJson();

      expect(json['id'], 'op-1');
      expect(json['type'], 'updateChapter');
      expect(json['chapterId'], 'c-1');
      expect(json['novelId'], 'n-1');
      expect(json['data'], {'content': 'Updated'});
      expect(json['createdAt'], '2023-01-01T12:00:00.000Z');
      expect(json['retryCount'], 2);
      expect(json['lastError'], 'Timeout');
      expect(json['isPending'], false);
      expect(json['baseSha'], 'sha456');
    });

    test('copyWith should update fields correctly', () {
      final op = OfflineOperation(
        id: 'op-1',
        type: OperationType.createChapter,
        novelId: 'n-1',
        createdAt: DateTime.now(),
      );

      final updated = op.copyWith(
        retryCount: 1,
        lastError: 'Failed',
        isPending: false,
      );

      expect(updated.id, op.id);
      expect(updated.retryCount, 1);
      expect(updated.lastError, 'Failed');
      expect(updated.isPending, false);
    });

    test('equality should work correctly', () {
      final date = DateTime.now();
      final op1 = OfflineOperation(
        id: 'op-1',
        type: OperationType.createChapter,
        novelId: 'n-1',
        createdAt: date,
      );
      final op2 = OfflineOperation(
        id: 'op-1',
        type: OperationType.createChapter,
        novelId: 'n-1',
        createdAt: date,
      );
      final op3 = OfflineOperation(
        id: 'op-2',
        type: OperationType.createChapter,
        novelId: 'n-1',
        createdAt: date,
      );

      expect(op1, op2);
      expect(op1, isNot(op3));
    });
  });
}
