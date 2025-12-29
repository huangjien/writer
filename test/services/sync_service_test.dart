import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/models/offline_operation.dart';
import 'dart:async';

@GenerateNiceMocks([
  MockSpec<OfflineQueueService>(),
  MockSpec<RemoteRepository>(),
  MockSpec<NetworkMonitor>(),
])
import 'sync_service_test.mocks.dart';

void main() {
  late MockOfflineQueueService mockQueue;
  late MockRemoteRepository mockRemote;
  late MockNetworkMonitor mockNetwork;
  late SyncService syncService;

  setUp(() {
    mockQueue = MockOfflineQueueService();
    mockRemote = MockRemoteRepository();
    mockNetwork = MockNetworkMonitor();

    // Default stubs
    when(mockQueue.getPendingCount()).thenAnswer((_) async => 0);
    when(mockQueue.getPendingOperations()).thenAnswer((_) async => []);

    // Create a StreamController for connectivity
    final controller = StreamController<bool>.broadcast();
    when(mockNetwork.connectivityStream).thenAnswer((_) => controller.stream);

    SharedPreferences.setMockInitialValues({});

    syncService = SyncService(
      offlineQueue: mockQueue,
      remote: mockRemote,
      networkMonitor: mockNetwork,
    );
  });

  group('SyncService', () {
    test('startMonitoring should start network monitoring', () {
      syncService.startMonitoring();
      verify(mockNetwork.startMonitoring()).called(1);
    });

    test('stopMonitoring should stop network monitoring', () {
      syncService.stopMonitoring();
      verify(mockNetwork.stopMonitoring()).called(1);
    });

    test('currentSyncState should return default state initially', () {
      expect(syncService.currentSyncState.status, SyncStatus.synced);
    });

    test('pendingOperationsCount should delegate to queue', () async {
      when(mockQueue.getPendingCount()).thenAnswer((_) async => 5);
      expect(await syncService.pendingOperationsCount, 5);
    });

    test('syncPendingOperations should do nothing if no operations', () async {
      when(mockQueue.getPendingOperations()).thenAnswer((_) async => []);

      await syncService.syncPendingOperations();

      verifyNever(mockRemote.patch(any, any));
      verifyNever(mockRemote.post(any, any));
      verifyNever(mockRemote.delete(any));
    });

    test('syncPendingOperations should sync create operation', () async {
      final op = OfflineOperation(
        id: '1',
        novelId: 'n1',
        type: OperationType.createChapter,
        data: {
          'novelId': 'n1',
          'idx': 1,
          'title': 'Chapter 1',
          'content': 'Content',
        },
        createdAt: DateTime.now(),
      );

      when(mockQueue.getPendingOperations()).thenAnswer((_) async => [op]);
      when(
        mockRemote.post('chapters', any),
      ).thenAnswer((_) async => {'id': 'server_id'});
      when(mockQueue.markCompleted('1')).thenAnswer((_) async => {});

      await syncService.syncPendingOperations();

      verify(
        mockRemote.post(
          'chapters',
          argThat(containsPair('title', 'Chapter 1')),
        ),
      ).called(1);
      verify(mockQueue.markCompleted('1')).called(1);
    });
  });
}
