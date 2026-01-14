import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/sync_service_provider.dart';

class _AlwaysOnlineConnectivityChecker implements ConnectivityChecker {
  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    yield const <ConnectivityResult>[ConnectivityResult.wifi];
  }
}

class _InMemoryStorageService implements StorageService {
  final Map<String, String?> _store = {};

  @override
  String? getString(String key) => _store[key];

  @override
  Set<String> getKeys() => _store.keys.toSet();

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> setString(String key, String? value) async {
    _store[key] = value;
  }
}

void main() {
  test('sync providers are constructible with overrides', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        remoteRepositoryProvider.overrideWithValue(
          RemoteRepository('http://example.com/', authToken: () async => null),
        ),
        offlineQueueServiceProvider.overrideWithValue(OfflineQueueService()),
        networkMonitorProvider.overrideWithValue(
          NetworkMonitor(_AlwaysOnlineConnectivityChecker()),
        ),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(_InMemoryStorageService()),
        ),
      ],
    );

    final service = container.read(syncServiceProvider);
    expect(service, isNotNull);

    final current = container.read(syncStateValueProvider);
    expect(current.status, SyncStatus.synced);

    final stream = container.read(syncStateProvider);
    expect(stream, isA<AsyncValue<SyncState>>());

    final isSyncing = container.read(isSyncingProvider);
    expect(isSyncing, false);

    final hasPending = container.read(hasPendingOperationsProvider);
    expect(hasPending, false);

    final pendingCount = await container.read(
      pendingOperationsCountProvider.future,
    );
    expect(pendingCount, 0);
    service.dispose();
    container.dispose();
  });
}
