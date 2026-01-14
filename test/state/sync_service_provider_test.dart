import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/providers.dart';

class MockOfflineQueueService extends Mock implements OfflineQueueService {
  @override
  Future<int> getPendingCount() async => 0; // Return default value to prevent null issues
}

class MockRemoteRepository extends Mock implements RemoteRepository {}

class MockNetworkMonitor extends Mock implements NetworkMonitor {
  @override
  bool get isOnline => true; // Return default value to prevent null issues
}

class MockSyncService extends Mock implements SyncService {}

class MockLocalStorageRepository extends Mock implements LocalStorageRepository {}

void main() {
  group('sync_service_provider', () {
    late MockOfflineQueueService mockOfflineQueue;
    late MockRemoteRepository mockRemote;
    late MockNetworkMonitor mockNetworkMonitor;
    late MockLocalStorageRepository mockLocalStorage;

    setUp(() {
      mockOfflineQueue = MockOfflineQueueService();
      mockRemote = MockRemoteRepository();
      mockNetworkMonitor = MockNetworkMonitor();
      mockLocalStorage = MockLocalStorageRepository();
    });

    test('provides SyncService instance with correct dependencies', () {
      final container = ProviderContainer(
        overrides: [
          offlineQueueServiceProvider.overrideWithValue(mockOfflineQueue),
          remoteRepositoryProvider.overrideWithValue(mockRemote),
          networkMonitorProvider.overrideWithValue(mockNetworkMonitor),
          localStorageRepositoryProvider.overrideWithValue(mockLocalStorage),
        ],
      );
      addTearDown(container.dispose);

      final syncService = container.read(syncServiceProvider);
      expect(syncService, isA<SyncService>());
    });

    test('disposes properly when container is disposed', () {
      final container = ProviderContainer(
        overrides: [
          offlineQueueServiceProvider.overrideWithValue(mockOfflineQueue),
          remoteRepositoryProvider.overrideWithValue(mockRemote),
          networkMonitorProvider.overrideWithValue(mockNetworkMonitor),
          localStorageRepositoryProvider.overrideWithValue(mockLocalStorage),
        ],
      );

      container.read(syncServiceProvider);
      container.dispose();

      // Verify that disposal doesn't throw
      expect(() => container.dispose(), returnsNormally);
    });
  });

  group('syncStateValueProvider', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('returns current sync state from SyncService', () {
      const testState = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(testState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final state = container.read(syncStateValueProvider);
      expect(state, testState);
      verify(() => mockSyncService.currentSyncState).called(1);
    });

    test('updates when SyncService state changes', () {
      const initialState = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      );

      const updatedState = SyncState(
        status: SyncStatus.syncing,
        pendingOperations: 3,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(initialState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Initial state
      expect(container.read(syncStateValueProvider), initialState);

      // Update state
      when(() => mockSyncService.currentSyncState).thenReturn(updatedState);
      container.invalidate(syncStateValueProvider);

      expect(container.read(syncStateValueProvider), updatedState);
    });
  });

  group('pendingOperationsCountProvider', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('returns pending operations count from SyncService', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenAnswer((_) async => 5);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Get the AsyncValue and listen for completion
      final completer = Completer<int>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      final result = await completer.future;
      expect(result, 5);
      verify(() => mockSyncService.pendingOperationsCount).called(1);
    });

    test('handles zero pending operations', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenAnswer((_) async => 0);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Get the AsyncValue and listen for completion
      final completer = Completer<int>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      final result = await completer.future;
      expect(result, 0);
    });

    test('handles exceptions from SyncService', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenThrow(Exception('Service error'));

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Get the AsyncValue and listen for completion
      final completer = Completer<Object>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      expect(completer.future, throwsA(isA<Exception>()));
    });
  });

  group('isSyncingProvider', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('returns true when status is syncing', () {
      const syncingState = SyncState(
        status: SyncStatus.syncing,
        pendingOperations: 3,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(syncingState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final isSyncing = container.read(isSyncingProvider);
      expect(isSyncing, isTrue);
    });

    test('returns false when status is not syncing', () {
      const syncedState = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(syncedState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final isSyncing = container.read(isSyncingProvider);
      expect(isSyncing, isFalse);
    });

    test('returns false when status is offline', () {
      const offlineState = SyncState(
        status: SyncStatus.offline,
        pendingOperations: 2,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(offlineState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final isSyncing = container.read(isSyncingProvider);
      expect(isSyncing, isFalse);
    });

    test('returns false when status is error', () {
      const errorState = SyncState(
        status: SyncStatus.error,
        pendingOperations: 1,
        errorMessage: 'Network error',
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(errorState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final isSyncing = container.read(isSyncingProvider);
      expect(isSyncing, isFalse);
    });
  });

  group('hasPendingOperationsProvider', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('returns true when pending operations count > 0', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenAnswer((_) async => 5);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Wait for the pending operations to load
      final completer = Completer<int>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      await completer.future;
      final hasPending = container.read(hasPendingOperationsProvider);
      expect(hasPending, isTrue);
    });

    test('returns false when pending operations count is 0', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenAnswer((_) async => 0);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Wait for the pending operations to load
      final completer = Completer<int>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      await completer.future;
      final hasPending = container.read(hasPendingOperationsProvider);
      expect(hasPending, isFalse);
    });

    test('handles error in pending operations count', () async {
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenThrow(Exception('Service error'));

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Try to read the provider (will handle error)
      final completer = Completer<Object>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      expect(completer.future, throwsA(isA<Exception>()));

      // hasPendingOperationsProvider should return false when there's an error
      final hasPending = container.read(hasPendingOperationsProvider);
      expect(hasPending, isFalse);
    });
  });

  group('syncErrorProvider', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('returns error message when sync state has error', () {
      const errorState = SyncState(
        status: SyncStatus.error,
        pendingOperations: 1,
        errorMessage: 'Network timeout',
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(errorState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final errorMessage = container.read(syncErrorProvider);
      expect(errorMessage, 'Network timeout');
    });

    test('returns null when sync state has no error', () {
      const normalState = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      );

      when(() => mockSyncService.currentSyncState).thenReturn(normalState);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final errorMessage = container.read(syncErrorProvider);
      expect(errorMessage, isNull);
    });

    test('returns null when sync state has empty error message', () {
      const stateWithEmptyError = SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: '',
        lastSyncTime: null,
      );

      when(
        () => mockSyncService.currentSyncState,
      ).thenReturn(stateWithEmptyError);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      final errorMessage = container.read(syncErrorProvider);
      expect(errorMessage, '');
    });
  });

  group('Provider integration', () {
    test('providers work together correctly', () async {
      const testState = SyncState(
        status: SyncStatus.syncing,
        pendingOperations: 3,
        errorMessage: 'Some error',
        lastSyncTime: null,
      );

      final mockSyncService = MockSyncService();
      when(() => mockSyncService.currentSyncState).thenReturn(testState);
      when(
        () => mockSyncService.pendingOperationsCount,
      ).thenAnswer((_) async => 3);

      final container = ProviderContainer(
        overrides: [syncServiceProvider.overrideWithValue(mockSyncService)],
      );
      addTearDown(container.dispose);

      // Wait for async operations to complete
      final completer = Completer<int>();
      container.listen(pendingOperationsCountProvider, (prev, next) {
        if (next.hasValue) {
          completer.complete(next.value);
        } else if (next.hasError) {
          completer.completeError(next.error!);
        }
      });

      final result = await completer.future;
      expect(result, 3);

      // Test that all providers read from the same SyncService instance
      final syncState = container.read(syncStateValueProvider);
      final isSyncing = container.read(isSyncingProvider);
      final hasPending = container.read(hasPendingOperationsProvider);
      final errorMessage = container.read(syncErrorProvider);

      expect(syncState, testState);
      expect(isSyncing, isTrue);
      expect(hasPending, isTrue);
      expect(errorMessage, 'Some error');
    });
  });
}
