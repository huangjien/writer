import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/models/sync_state.dart';

/// Provider for the SyncService singleton.
/// This service handles syncing offline operations to the remote server.
final syncServiceProvider = Provider<SyncService>((ref) {
  final offlineQueue = ref.watch(offlineQueueServiceProvider);
  final remote = ref.watch(remoteRepositoryProvider);
  final networkMonitor = ref.watch(networkMonitorProvider);
  final syncService = SyncService(
    offlineQueue: offlineQueue,
    remote: remote,
    networkMonitor: networkMonitor,
    ref: ref,
  );
  return syncService;
});

/// Stream provider for sync state.
/// Emits updates when sync status changes (syncing, synced, error, offline).
final syncStateProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatusStream;
});

/// Provider for the current sync state value (latest value from the stream).
/// Use this when you need a single value instead of a stream.
final syncStateValueProvider = Provider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.currentSyncState;
});

/// Provider for the number of pending operations.
final pendingOperationsCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.pendingOperationsCount;
});

/// Provider for whether the app is currently syncing.
final isSyncingProvider = Provider<bool>((ref) {
  final syncState = ref.watch(syncStateValueProvider);
  return syncState.status == SyncStatus.syncing;
});

/// Provider for whether there are any pending operations.
final hasPendingOperationsProvider = Provider<bool>((ref) {
  final countAsync = ref.watch(pendingOperationsCountProvider);
  return (countAsync.value ?? 0) > 0;
});

/// Provider for the last sync error message, if any.
final syncErrorProvider = Provider<String?>((ref) {
  final syncState = ref.watch(syncStateValueProvider);
  return syncState.errorMessage;
});
