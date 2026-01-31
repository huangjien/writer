import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_manager.dart';
import '../services/network_monitor.dart';
import '../state/data_manager_provider.dart';
import '../state/network_monitor_provider.dart';

enum SyncStatus { idle, syncing, success, error }

class BackgroundSyncService {
  final DataManager _dataManager;
  final NetworkMonitor _network;
  Timer? _syncTimer;
  StreamSubscription? _networkSubscription;
  SyncStatus _currentStatus = SyncStatus.idle;
  String? _lastError;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  BackgroundSyncService({
    required DataManager dataManager,
    required NetworkMonitor network,
  }) : _dataManager = dataManager,
       _network = network;

  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  SyncStatus get currentStatus => _currentStatus;

  String? get lastError => _lastError;

  void startMonitoring() {
    _network.startMonitoring();

    _networkSubscription = _network.connectivityStream.listen((isOnline) {
      if (isOnline) {
        scheduleSync(delay: const Duration(seconds: 3));
      }
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (_network.isOnline) {
        performSync();
      }
    });
  }

  void stopMonitoring() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
    _syncTimer?.cancel();
    _syncTimer = null;
    _network.stopMonitoring();
  }

  Future<void> scheduleSync({Duration delay = Duration.zero}) async {
    if (!_network.isOnline) return;

    Future.delayed(delay, () async {
      await performSync();
    });
  }

  Future<void> performSync() async {
    if (!_network.isOnline) return;

    try {
      _updateStatus(SyncStatus.syncing);

      await _dataManager.getAllNovels(forceRefresh: true);

      _updateStatus(SyncStatus.success);
    } on Object catch (e) {
      _lastError = e.toString();
      _updateStatus(SyncStatus.error, error: e.toString());
    }
  }

  Future<void> forceFullSync() async {
    if (!_network.isOnline) return;

    try {
      _updateStatus(SyncStatus.syncing);

      await _dataManager.getAllNovels(forceRefresh: true);

      _updateStatus(SyncStatus.success);
    } catch (e) {
      _lastError = e.toString();
      _updateStatus(SyncStatus.error, error: e.toString());
      rethrow;
    }
  }

  void _updateStatus(SyncStatus status, {String? error}) {
    _currentStatus = status;
    if (error != null) {
      _lastError = error;
    }
    _statusController.add(status);
  }

  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final dataManager = ref.watch(dataManagerProvider);
  final network = ref.watch(networkMonitorProvider);

  final service = BackgroundSyncService(
    dataManager: dataManager,
    network: network,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
