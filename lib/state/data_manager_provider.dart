import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/services/data_manager.dart';
import './providers.dart';
import './network_monitor_provider.dart';
import 'package:writer/repositories/remote_repository.dart';
import './storage_service_provider.dart';

final dataManagerProvider = Provider<DataManager>((ref) {
  final local = ref.watch(localStorageRepositoryProvider);
  final remote = ref.watch(remoteRepositoryProvider);
  final network = ref.watch(networkMonitorProvider);
  final storage = ref.watch(storageServiceProvider);
  final performanceBaseline = ref.watch(performanceBaselineServiceProvider);
  return DataManager(
    local: local,
    remote: remote,
    network: network,
    storage: storage,
    performanceBaseline: performanceBaseline,
  );
});
