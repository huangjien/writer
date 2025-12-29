import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/sync_state.dart';

void main() {
  group('SyncState', () {
    test('copyWith should update fields correctly', () {
      const state = SyncState(status: SyncStatus.synced, pendingOperations: 0);

      final updated = state.copyWith(
        status: SyncStatus.syncing,
        pendingOperations: 5,
        errorMessage: 'Error',
      );

      expect(updated.status, SyncStatus.syncing);
      expect(updated.pendingOperations, 5);
      expect(updated.errorMessage, 'Error');
    });

    test('equality should work correctly', () {
      final time = DateTime.now();
      final s1 = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        lastSyncTime: time,
      );
      final s2 = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        lastSyncTime: time,
      );
      final s3 = SyncState(
        status: SyncStatus.error,
        pendingOperations: 0,
        lastSyncTime: time,
      );

      expect(s1, s2);
      expect(s1, isNot(s3));
    });

    test('hashCode should be consistent with equality', () {
      final time = DateTime.now();
      final s1 = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        lastSyncTime: time,
      );
      final s2 = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        lastSyncTime: time,
      );

      expect(s1.hashCode, s2.hashCode);
    });
  });
}
