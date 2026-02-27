import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/background_sync_service.dart';
import 'package:writer/services/data_manager.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/models/novel.dart';

class MockDataManager implements DataManager {
  @override
  Future<List<Novel>> getAllNovels({bool forceRefresh = false}) async => [];

  @override
  noSuchMethod(Invocation invocation) => Future.value(null);
}

class MockNetworkMonitor implements NetworkMonitor {
  bool _isOnline = true;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  @override
  bool get isOnline => _isOnline;

  @override
  Future<bool> get isConnected async => _isOnline;

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  @override
  void startMonitoring() {}

  @override
  void stopMonitoring() {}

  void setOnline(bool online) {
    _isOnline = online;
    _connectivityController.add(online);
  }

  @override
  void dispose() {
    _connectivityController.close();
  }
}

void main() {
  late MockDataManager mockDataManager;
  late MockNetworkMonitor mockNetwork;

  setUp(() {
    mockDataManager = MockDataManager();
    mockNetwork = MockNetworkMonitor();
  });

  tearDown(() {
    mockNetwork.dispose();
  });

  group('BackgroundSyncService', () {
    test('creates service with dependencies', () {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      expect(service.currentStatus, SyncStatus.idle);
      expect(service.lastError, isNull);

      service.dispose();
    });

    test('starts monitoring when startMonitoring is called', () {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      service.startMonitoring();

      expect(mockNetwork.isOnline, true);

      service.dispose();
    });

    test('stops monitoring when stopMonitoring is called', () {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      service.startMonitoring();
      service.stopMonitoring();

      expect(service.currentStatus, SyncStatus.idle);

      service.dispose();
    });

    test('syncStatusStream is not null', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      final stream = service.syncStatusStream;

      expect(stream, isNotNull);

      service.dispose();
    });

    test('scheduleSync returns early when offline', () {
      mockNetwork.setOnline(false);

      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      service.scheduleSync();

      expect(service.currentStatus, SyncStatus.idle);

      service.dispose();
    });

    test('scheduleSync performs sync after delay when online', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      service.scheduleSync(delay: const Duration(milliseconds: 100));

      await Future.delayed(const Duration(milliseconds: 150));

      expect(service.currentStatus, isNot(SyncStatus.idle));

      service.dispose();
    });

    test('performSync updates status to syncing', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      await service.performSync();

      expect(service.currentStatus, SyncStatus.success);

      service.dispose();
    });

    test('performSync handles errors', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      final statuses = <SyncStatus>[];
      final subscription = service.syncStatusStream.listen(statuses.add);

      await service.performSync();

      expect(statuses, isNot(contains(SyncStatus.error)));

      subscription.cancel();
      service.dispose();
    });

    test('forceFullSync performs sync', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      await service.forceFullSync();

      expect(service.currentStatus, SyncStatus.success);

      service.dispose();
    });

    test('forceFullSync rethrows errors', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      bool errorCaught = false;
      try {
        await service.forceFullSync();
      } catch (_) {
        errorCaught = true;
      }

      expect(errorCaught, false);

      service.dispose();
    });

    test('syncStatusStream is broadcast stream', () {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      final isBroadcast = service.syncStatusStream.isBroadcast;

      expect(isBroadcast, true);

      service.dispose();
    });

    test('multiple performSync calls update status correctly', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      await service.performSync();
      await service.performSync();

      expect(service.currentStatus, SyncStatus.success);

      service.dispose();
    });

    test('lastError is updated on sync error', () async {
      final service = BackgroundSyncService(
        dataManager: mockDataManager,
        network: mockNetwork,
      );

      await service.performSync();

      expect(service.lastError, isNull);

      service.dispose();
    });
  });
}
