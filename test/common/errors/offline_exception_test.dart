import 'package:flutter_test/flutter_test.dart';
import 'package:writer/common/errors/offline_exception.dart';

void main() {
  group('OfflineException', () {
    test('should return correct string representation without operationId', () {
      const exception = OfflineException('Connection failed');
      expect(exception.toString(), 'OfflineException: Connection failed');
    });

    test('should return correct string representation with operationId', () {
      const exception = OfflineException('Sync failed', operationId: 'op-123');
      expect(
        exception.toString(),
        'OfflineException: Sync failed (operationId: op-123)',
      );
    });
  });

  group('SyncException', () {
    test('should return correct string representation without operationId', () {
      const exception = SyncException('Sync error');
      expect(exception.toString(), 'SyncException: Sync error');
    });

    test(
      'should return correct string representation with operationId and statusCode',
      () {
        const exception = SyncException(
          'Server error',
          operationId: 'op-456',
          statusCode: 500,
        );
        expect(
          exception.toString(),
          'SyncException: Server error (operationId: op-456, statusCode: 500)',
        );
      },
    );
  });
}
