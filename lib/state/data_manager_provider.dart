import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_manager.dart';
import './providers.dart';
import './network_monitor_provider.dart';
import '../repositories/remote_repository.dart';
import './storage_service_provider.dart';

final dataManagerProvider = Provider<DataManager>((ref) {
  final local = ref.watch(localStorageRepositoryProvider);
  final remote = ref.watch(remoteRepositoryProvider);
  final network = ref.watch(networkMonitorProvider);
  final storage = ref.watch(storageServiceProvider);
  return DataManager(
    local: local,
    remote: remote,
    network: network,
    storage: storage,
  );
});
