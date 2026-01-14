import 'dart:async';
import '../models/offline_operation.dart';
import '../models/sync_state.dart';
import '../repositories/local_storage_repository.dart';
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
  final LocalStorageRepository? _localStorage;
  final Duration _syncDebounceDuration;
  final Future<void> Function(Duration) _delay;
  late final StreamController<SyncState> _syncStateController;
  final Future<SharedPreferences> Function() _prefs;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncDebounceTimer;
  SyncState _currentSyncState = const SyncState(
    status: SyncStatus.synced,
    pendingOperations: 0,
    errorMessage: null,
    lastSyncTime: null,
  );

  SyncService({
    required OfflineQueueService offlineQueue,
    required RemoteRepository remote,
    required NetworkMonitor networkMonitor,
    LocalStorageRepository? localStorage,
    Future<SharedPreferences> Function()? prefs,
    Duration syncDebounceDuration = const Duration(seconds: 2),
    Future<void> Function(Duration)? delay,
  }) : _offlineQueue = offlineQueue,
       _remote = remote,
       _networkMonitor = networkMonitor,
       _localStorage = localStorage,
       _prefs = prefs ?? SharedPreferences.getInstance,
       _syncDebounceDuration = syncDebounceDuration,
       _delay = delay ?? Future<void>.delayed,
       _syncStateController = StreamController<SyncState>() {
    // Initialize with current network status
    _initializeSyncState().then((_) {});
  }

  /// Stream of sync state updates
  Stream<SyncState> get syncStatusStream => _syncStateController.stream;

  /// Current sync state
  SyncState get currentSyncState {
    return _currentSyncState;
  }

  /// Get pending operations count
  Future<int> get pendingOperationsCount async {
    return await _offlineQueue.getPendingCount();
  }

  /// Initialize sync state based on current network status
  Future<void> _initializeSyncState() async {
    final isOnline = _networkMonitor.isOnline;
    final pendingCount = await _offlineQueue.getPendingCount();

    if (!isOnline) {
      _currentSyncState = SyncState(
        status: SyncStatus.offline,
        pendingOperations: pendingCount,
        errorMessage: null,
        lastSyncTime: null,
      );
    } else if (pendingCount > 0) {
      _currentSyncState = SyncState(
        status: SyncStatus.syncing,
        pendingOperations: pendingCount,
        errorMessage: null,
        lastSyncTime: null,
      );
    } else {
      _currentSyncState = const SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      );
    }

    // Emit the initial state
    _syncStateController.add(_currentSyncState);
  }

  /// Start monitoring and syncing
  void startMonitoring() {
    // Start network monitoring
    _networkMonitor.startMonitoring();

    // Listen to connectivity changes and trigger sync
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _networkMonitor.connectivityStream.listen((
      isOnline,
    ) async {
      if (isOnline) {
        _scheduleSync();
      } else {
        // Update state to offline when network is lost
        final pendingCount = await _offlineQueue.getPendingCount();
        _emitSyncState(
          status: SyncStatus.offline,
          pendingOperations: pendingCount,
          errorMessage: null,
          lastSyncTime: null,
        );
      }
    });
  }

  /// Stop monitoring and syncing
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
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

    String? lastError;
    for (final op in operations) {
      var retryCount = op.retryCount;
      while (true) {
        final result = await _syncOperation(op);
        if (result.success) {
          await _offlineQueue.markCompleted(op.id);
          break;
        }

        final error = result.error ?? 'Sync failed';
        lastError = error;
        retryCount += 1;
        await _offlineQueue.incrementRetry(op.id);

        if (!RetryPolicy.canRetry(retryCount)) {
          await _offlineQueue.markFailed(op.id, error);
          break;
        }

        await _offlineQueue.markFailed(op.id, error);
        await _delay(RetryPolicy.getDelay(retryCount));
      }
    }

    // Clear completed operations
    await _offlineQueue.clearCompleted();

    final remaining = await _offlineQueue.getPendingCount();
    if (remaining > 0) {
      _emitSyncState(
        status: SyncStatus.error,
        pendingOperations: remaining,
        errorMessage: lastError,
        lastSyncTime: DateTime.now(),
      );
    } else {
      _emitSyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: DateTime.now(),
      );
    }
  }

  /// Sync a single operation
  Future<({bool success, String? error})> _syncOperation(
    OfflineOperation op,
  ) async {
    try {
      switch (op.type) {
        case OperationType.createChapter:
          return (success: await _syncCreate(op), error: null);
        case OperationType.updateChapter:
          return (success: await _syncUpdate(op), error: null);
        case OperationType.deleteChapter:
          return (success: await _syncDelete(op), error: null);
        case OperationType.updateChapterIdx:
          return (success: await _syncMove(op), error: null);
      }
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  String? _stringFromData(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final k in keys) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  int? _intFromData(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final k in keys) {
      final v = data[k];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    }
    return null;
  }

  /// Sync create operation
  Future<bool> _syncCreate(OfflineOperation op) async {
    final data = op.data ?? const <String, dynamic>{};
    final idx = _intFromData(data, const ['idx']) ?? 1;
    final title = _stringFromData(data, const ['title']) ?? 'Untitled';
    final content = _stringFromData(data, const ['content']) ?? '';
    final languageCode =
        _stringFromData(data, const ['language_code', 'languageCode']) ?? 'en';

    final body = {
      'novel_id': op.novelId,
      'idx': idx,
      'title': title,
      'content': content,
      'language_code': languageCode,
    };

    final res = await _remote.post('chapters', body);
    if (res is Map<String, dynamic>) {
      final serverId = res['id'];
      if (serverId is String && serverId.isNotEmpty) {
        await _updateOperationWithServerId(op.id, serverId);
        final localId = op.chapterId;
        if (localId != null &&
            localId.isNotEmpty &&
            localId != serverId &&
            localId.startsWith('local_')) {
          await _offlineQueue.replaceChapterId(fromId: localId, toId: serverId);
          final localStorage = _localStorage;
          if (localStorage != null) {
            await localStorage.renameChapterId(from: localId, to: serverId);
          }
        }
      }
      return true;
    }
    return false;
  }

  /// Sync update operation
  Future<bool> _syncUpdate(OfflineOperation op) async {
    final data = op.data ?? const <String, dynamic>{};
    final storedServerId = _stringFromData(data, const ['serverId']);
    final chapterId = storedServerId ?? op.chapterId;
    if (chapterId == null || chapterId.isEmpty) {
      throw StateError('Missing chapterId for update operation');
    }
    final title = _stringFromData(data, const ['title']);
    final content = _stringFromData(data, const ['content']);
    final body = {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
    };

    // Calculate SHA for conflict detection
    String? sha;
    if (content != null) {
      final bytes = utf8.encode(content);
      sha = sha256.convert(bytes).toString();
    }
    if (sha != null) body['sha'] = sha;

    await _remote.patch('chapters/$chapterId', body);
    return true;
  }

  /// Sync delete operation
  Future<bool> _syncDelete(OfflineOperation op) async {
    final chapterId = op.chapterId;
    if (chapterId == null || chapterId.isEmpty) {
      throw StateError('Missing chapterId for delete operation');
    }
    await _remote.delete('chapters/$chapterId');
    return true;
  }

  /// Sync move operation (update chapter index)
  Future<bool> _syncMove(OfflineOperation op) async {
    final data = op.data ?? const <String, dynamic>{};
    final storedServerId = _stringFromData(data, const ['serverId']);
    final chapterId = storedServerId ?? op.chapterId;
    if (chapterId == null || chapterId.isEmpty) {
      throw StateError('Missing chapterId for move operation');
    }
    final newIdx = _intFromData(data, const ['idx', 'new_idx', 'newIdx']);
    if (newIdx == null) {
      throw StateError('Missing idx for move operation');
    }
    final body = {'idx': newIdx};

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
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(_syncDebounceDuration, () {
      unawaited(syncPendingOperations());
    });
  }

  /// Emit sync state
  void _emitSyncState({
    required SyncStatus status,
    required int pendingOperations,
    required String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    _currentSyncState = SyncState(
      status: status,
      pendingOperations: pendingOperations,
      errorMessage: errorMessage,
      lastSyncTime: lastSyncTime,
    );
    _syncStateController.add(_currentSyncState);
  }

  /// Dispose resources
  void dispose() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _syncStateController.close();
  }
}
