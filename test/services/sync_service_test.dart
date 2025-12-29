import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'dart:convert';

import 'package:writer/services/sync_service.dart';
import 'package:writer/models/offline_operation.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/retry_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks(<Type>[
  OfflineQueueService,
  RemoteRepository,
  NetworkMonitor,
  SharedPreferences,
])

void main() {
  group('SyncService', () {
    late SyncService syncService;
    late MockOfflineQueueService mockOfflineQueue;
    late MockRemoteRepository mockRemote;
    late MockNetworkMonitor mockNetworkMonitor;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockOfflineQueue = MockOfflineQueueService();
      mockRemote = MockRemoteRepository();
      mockNetworkMonitor = MockNetworkMonitor();
      mockPrefs = MockSharedPreferences();
      
      syncService = SyncService(
        offlineQueue: mockOfflineQueue,
        remote: mockRemote,
        networkMonitor: mockNetworkMonitor,
        prefs: () async => mockPrefs,
      );
    });

    tearDown(() {
      syncService.dispose();
    });

    group('initialization', () {
      test('should initialize with default sync state', () {
        final state = syncService.currentSyncState;
        expect(state.status, SyncStatus.synced);
        expect(state.pendingOperations, 0);
        expect(state.errorMessage, null);
        expect(state.lastSyncTime, null);
      });

      test('should provide sync status stream', () {
        expect(syncService.syncStatusStream, isA<Stream<SyncState>>());
      });
    });

    group('network monitoring', () {
      test('should start network monitoring when startMonitoring is called', () {
        // Mock connectivityStream
        when(mockNetworkMonitor.connectivityStream)
            .thenAnswer((_) => Stream.empty());
        
        syncService.startMonitoring();
        verify(mockNetworkMonitor.startMonitoring()).called(1);
      });

      test('should stop network monitoring when stopMonitoring is called', () {
        // Mock connectivityStream
        when(mockNetworkMonitor.connectivityStream)
            .thenAnswer((_) => Stream.empty());
        
        syncService.stopMonitoring();
        verify(mockNetworkMonitor.stopMonitoring()).called(1);
      });

      test('should trigger sync when network becomes online', () async {
        // Setup connectivity stream
        final connectivityController = StreamController<bool>();
        when(mockNetworkMonitor.connectivityStream)
            .thenAnswer((_) => connectivityController.stream);

        // Mock pending operations
        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => []);

        syncService.startMonitoring();

        // Simulate network coming online
        connectivityController.add(true);

        // Wait for debounce
        await Future.delayed(Duration(milliseconds: 2100));

        verify(mockOfflineQueue.getPendingOperations()).called(1);
        
        await connectivityController.close();
      });
    });

    group('pending operations', () {
      test('should return pending operations count', () async {
        when(mockOfflineQueue.getPendingCount())
            .thenAnswer((_) async => 5);

        final count = await syncService.pendingOperationsCount;
        expect(count, 5);
        verify(mockOfflineQueue.getPendingCount()).called(1);
      });

      test('should return 0 when no pending operations exist', () async {
        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => []);

        await syncService.syncPendingOperations();

        verify(mockOfflineQueue.getPendingOperations()).called(1);
        verifyNever(mockRemote.post(any, any));
      });
    });

    group('sync operations', () {
      test('should sync create chapter operation successfully', () async {
        final operation = OfflineOperation(
          id: 'op1',
          type: OperationType.createChapter,
          novelId: 'novel1',
          data: {
            'novelId': 'novel1',
            'idx': 1,
            'title': 'Test Chapter',
            'content': 'Test content',
          },
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.post('chapters', any))
            .thenAnswer((_) async => {'id': 'server123'});
        
        when(mockPrefs.getString('offline_op_op1'))
            .thenAnswer((_) => jsonEncode(operation.toJson()));
        when(mockPrefs.setString(any, any))
            .thenAnswer((_) async => true);

        await syncService.syncPendingOperations();

        verify(mockRemote.post('chapters', {
          'novel_id': 'novel1',
          'idx': 1,
          'title': 'Test Chapter',
          'content': 'Test content',
          'language_code': 'en',
        })).called(1);
        
        verify(mockOfflineQueue.markCompleted('op1')).called(1);
        verify(mockOfflineQueue.clearCompleted()).called(1);
      });

      test('should sync update chapter operation successfully', () async {
        final operation = OfflineOperation(
          id: 'op2',
          type: OperationType.updateChapter,
          chapterId: 'chapter123',
          novelId: 'novel1',
          data: {
            'title': 'Updated Chapter',
            'content': 'Updated content',
          },
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.patch('chapters/chapter123', any))
            .thenAnswer((_) async => {'id': 'chapter123'});
        
        when(mockPrefs.getString('offline_op_op2'))
            .thenAnswer((_) => jsonEncode(operation.toJson()));
        when(mockPrefs.setString(any, any))
            .thenAnswer((_) async => true);

        await syncService.syncPendingOperations();

        verify(mockRemote.patch('chapters/chapter123', {
          'title': 'Updated Chapter',
          'content': 'Updated content',
        })).called(1);
        
        verify(mockOfflineQueue.markCompleted('op2')).called(1);
      });

      test('should sync delete chapter operation successfully', () async {
        final operation = OfflineOperation(
          id: 'op3',
          type: OperationType.deleteChapter,
          chapterId: 'chapter123',
          novelId: 'novel1',
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.delete('chapters/chapter123'))
            .thenAnswer((_) async => {});

        await syncService.syncPendingOperations();

        verify(mockRemote.delete('chapters/chapter123')).called(1);
        verify(mockOfflineQueue.markCompleted('op3')).called(1);
      });

      test('should sync move chapter operation successfully', () async {
        final operation = OfflineOperation(
          id: 'op4',
          type: OperationType.updateChapterIdx,
          chapterId: 'chapter123',
          novelId: 'novel1',
          data: {'idx': 2},
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.patch('chapters/chapter123', any))
            .thenAnswer((_) async => {});

        await syncService.syncPendingOperations();

        verify(mockRemote.patch('chapters/chapter123', {'idx': 2})).called(1);
        verify(mockOfflineQueue.markCompleted('op4')).called(1);
      });
    });

    group('error handling', () {
      test('should handle sync failure with retry', () async {
        final operation = OfflineOperation(
          id: 'op5',
          type: OperationType.createChapter,
          novelId: 'novel1',
          data: {
            'novelId': 'novel1',
            'idx': 1,
            'title': 'Test Chapter',
            'content': 'Test content',
          },
          createdAt: DateTime.now(),
          retryCount: 0,
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        // First call fails, second succeeds
        var callCount = 0;
        when(mockRemote.post('chapters', any)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return {'id': 'server123'};
        });
        
        when(mockPrefs.getString('offline_op_op5'))
            .thenAnswer((_) => jsonEncode(operation.toJson()));
        when(mockPrefs.setString(any, any))
            .thenAnswer((_) async => true);
        when(mockOfflineQueue.markCompleted('op5'))
            .thenAnswer((_) async => {});
        when(mockOfflineQueue.clearCompleted())
            .thenAnswer((_) async => {});

        await syncService.syncPendingOperations();

        verify(mockRemote.post('chapters', any)).called(2);
        verify(mockOfflineQueue.markCompleted('op5')).called(1);
        verify(mockOfflineQueue.clearCompleted()).called(1);
      });

      test('should mark operation as failed after max retries', () async {
        final operation = OfflineOperation(
          id: 'op6',
          type: OperationType.createChapter,
          novelId: 'novel1',
          data: {
            'novelId': 'novel1',
            'idx': 1,
            'title': 'Test Chapter',
            'content': 'Test content',
          },
          createdAt: DateTime.now(),
          retryCount: RetryPolicy.maxRetries,
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.post('chapters', any))
            .thenThrow(Exception('Persistent network error'));

        await syncService.syncPendingOperations();

        verify(mockRemote.post('chapters', any)).called(1);
        verify(mockOfflineQueue.markFailed('op6', 'Max retries exceeded')).called(1);
      });
    });

    group('sync state management', () {
      test('should emit syncing state during sync', () async {
        final operation = OfflineOperation(
          id: 'op7',
          type: OperationType.createChapter,
          novelId: 'novel1',
          data: {
            'novelId': 'novel1',
            'idx': 1,
            'title': 'Test Chapter',
            'content': 'Test content',
          },
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.post('chapters', any))
            .thenAnswer((_) async => {'id': 'server123'});
        
        when(mockPrefs.getString('offline_op_op7'))
            .thenAnswer((_) => jsonEncode(operation.toJson()));
        when(mockPrefs.setString(any, any))
            .thenAnswer((_) async => true);

        final states = <SyncState>[];
        final subscription = syncService.syncStatusStream.listen(states.add);

        await syncService.syncPendingOperations();
        
        // Add small delay to ensure all stream events are captured
        await Future.delayed(Duration(milliseconds: 10));

        // Should have at least syncing and synced states
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states.any((state) => state.status == SyncStatus.syncing), isTrue);
        expect(states.any((state) => state.status == SyncStatus.synced), isTrue);
        
        await subscription.cancel();
      });

      test('should emit synced state with last sync time', () async {
        final operation = OfflineOperation(
          id: 'op8',
          type: OperationType.createChapter,
          novelId: 'novel1',
          data: {
            'novelId': 'novel1',
            'idx': 1,
            'title': 'Test Chapter',
            'content': 'Test content',
          },
          createdAt: DateTime.now(),
        );

        when(mockOfflineQueue.getPendingOperations())
            .thenAnswer((_) async => [operation]);
        
        when(mockRemote.post('chapters', any))
            .thenAnswer((_) async => {'id': 'server123'});
        
        when(mockPrefs.getString('offline_op_op8'))
            .thenAnswer((_) => jsonEncode(operation.toJson()));
        when(mockPrefs.setString(any, any))
            .thenAnswer((_) async => true);

        final states = <SyncState>[];
        final subscription = syncService.syncStatusStream.listen(states.add);

        final beforeSync = DateTime.now();
        await syncService.syncPendingOperations();
        final afterSync = DateTime.now();
        
        // Add small delay to ensure all stream events are captured
        await Future.delayed(Duration(milliseconds: 10));

        await subscription.cancel();

        final syncedStates = states.where((state) => state.status == SyncStatus.synced);
        expect(syncedStates.isNotEmpty, isTrue);
        
        final finalState = syncedStates.last;
        expect(finalState.lastSyncTime, isNotNull);
        expect(finalState.lastSyncTime!.isAfter(beforeSync), isTrue);
        expect(finalState.lastSyncTime!.isBefore(afterSync), isTrue);
      });
    });

    group('dispose', () {
      test('should close sync state controller on dispose', () {
        // Should not throw when disposing
        expect(() => syncService.dispose(), returnsNormally);
      });
    });
  });
}