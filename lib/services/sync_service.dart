import 'dart:async';
import '../models/offline_operation.dart';
import '../models/sync_state.dart';
import '../repositories/remote_repository.dart';
import '../services/offline_queue_service.dart';
import '../services/network_monitor.dart';
import '../services/retry_policy.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final OfflineQueueService _offlineQueue;
  final RemoteRepository _remote;
  final NetworkMonitor _networkMonitor;
  late final StreamController<SyncState> _syncStateController;
  final Future<SharedPreferences> Function() _prefs;

  SyncService({
    required OfflineQueueService offlineQueue,
    required RemoteRepository remote,
    required NetworkMonitor networkMonitor,
    Future<SharedPreferences> Function()? prefs,
  }) : _offlineQueue = offlineQueue,
       _remote = remote,
       _networkMonitor = networkMonitor,
       _prefs = prefs ?? SharedPreferences.getInstance,
       _syncStateController = StreamController<SyncState>();

  /// Stream of sync state updates
  Stream<SyncState> get syncStatusStream => _syncStateController.stream;

  /// Current sync state
  SyncState get currentSyncState {
    // Return the last emitted state or a default synced state
    return SyncState(
      status: SyncStatus.synced,
      pendingOperations: 0,
      errorMessage: null,
      lastSyncTime: null,
    );
  }

  /// Get pending operations count
  Future<int> get pendingOperationsCount async {
    return await _offlineQueue.getPendingCount();
  }

  /// Start monitoring and syncing
  void startMonitoring() {
    // Start network monitoring
    _networkMonitor.startMonitoring();

    // Listen to connectivity changes and trigger sync
    _networkMonitor.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _scheduleSync();
      }
    });
  }

  /// Stop monitoring and syncing
  void stopMonitoring() {
    _networkMonitor.stopMonitoring();
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    final operations = await _offlineQueue.getPendingOperations();
    if (operations.isEmpty) return;

    _emitSyncState(
      status: SyncStatus.syncing,
      pendingOperations: operations.length,
      errorMessage: null,
    );

    for (final op in operations) {
      final success = await _syncOperation(op);
      if (success) {
        await _offlineQueue.markCompleted(op.id);
      } else {
        // Retry with backoff if failed
        if (op.retryCount < RetryPolicy.maxRetries) {
          final delay = RetryPolicy.getDelay(op.retryCount);
          await Future.delayed(delay);
          await _syncOperation(op);
        } else {
          await _offlineQueue.markFailed(op.id, 'Max retries exceeded');
        }
      }
    }

    // Clear completed operations
    await _offlineQueue.clearCompleted();

    _emitSyncState(
      status: SyncStatus.synced,
      pendingOperations: 0,
      errorMessage: null,
      lastSyncTime: DateTime.now(),
    );
  }

  /// Sync a single operation
  Future<bool> _syncOperation(OfflineOperation op) async {
    try {
      switch (op.type) {
        case OperationType.createChapter:
          return await _syncCreate(op);
        case OperationType.updateChapter:
          return await _syncUpdate(op);
        case OperationType.deleteChapter:
          return await _syncDelete(op);
        case OperationType.updateChapterIdx:
          return await _syncMove(op);
      }
    } catch (e) {
      return false;
    }
  }

  /// Sync create operation
  Future<bool> _syncCreate(OfflineOperation op) async {
    final data = op.data!;
    final body = {
      'novel_id': data['novelId'],
      'idx': data['idx'],
      'title': data['title'],
      'content': data['content'],
      'language_code': 'en',
    };

    final res = await _remote.post('chapters', body);
    if (res is Map<String, dynamic>) {
      // Update operation with server ID
      await _updateOperationWithServerId(op.id, res['id']);
      return true;
    }
    return false;
  }

  /// Sync update operation
  Future<bool> _syncUpdate(OfflineOperation op) async {
    final data = op.data!;
    final chapterId = op.chapterId!;
    final body = {'title': data['title'], 'content': data['content']};

    // Calculate SHA for conflict detection
    String? sha;
    if (data['content'] != null) {
      final bytes = utf8.encode(data['content'] as String);
      sha = sha256.convert(bytes).toString();
    }

    final res = await _remote.patch('chapters/$chapterId', body);
    if (res is Map<String, dynamic>) {
      // Update operation SHA
      await _updateOperationWithServerId(op.id, sha ?? '');
      return true;
    }
    return false;
  }

  /// Sync delete operation
  Future<bool> _syncDelete(OfflineOperation op) async {
    final chapterId = op.chapterId!;
    await _remote.delete('chapters/$chapterId');
    return true;
  }

  /// Sync move operation (update chapter index)
  Future<bool> _syncMove(OfflineOperation op) async {
    final data = op.data!;
    final chapterId = op.chapterId!;
    final body = {'idx': data['idx']};

    await _remote.patch('chapters/$chapterId', body);
    return true;
  }

  /// Update operation with server ID after successful sync
  Future<void> _updateOperationWithServerId(
    String opId,
    String serverId,
  ) async {
    final prefs = await _prefs();
    final opJson = prefs.getString('offline_op_$opId');
    if (opJson == null) return;

    try {
      final opMap = jsonDecode(opJson) as Map<String, dynamic>;
      final data = opMap['data'] as Map<String, dynamic>?;
      final updatedData = Map<String, dynamic>.from(data ?? {});
      updatedData['serverId'] = serverId;

      final updatedOp = OfflineOperation.fromJson(
        opMap,
      ).copyWith(data: updatedData);
      await prefs.setString('offline_op_$opId', jsonEncode(updatedOp.toJson()));
    } catch (_) {
      // Ignore errors
    }
  }

  /// Schedule sync with debounce
  void _scheduleSync() {
    // Debounce sync by 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      await syncPendingOperations();
    });
  }

  /// Emit sync state
  void _emitSyncState({
    required SyncStatus status,
    required int pendingOperations,
    required String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    _syncStateController.add(
      SyncState(
        status: status,
        pendingOperations: pendingOperations,
        errorMessage: errorMessage,
        lastSyncTime: lastSyncTime,
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _syncStateController.close();
  }
}
