import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/network_monitor.dart';
import '../services/offline_queue_service.dart';
import '../services/connectivity_checker.dart';

/// Provider for NetworkMonitor singleton
final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  final monitor = NetworkMonitor(RealConnectivityChecker());
  ref.onDispose(() {
    monitor.stopMonitoring();
  });
  return monitor;
});

/// Provider for the OfflineQueueService singleton.
/// This service manages offline operations queue.
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});

/// Stream provider for connectivity status
/// Emits true when online, false when offline
final connectivityProvider = StreamProvider<bool>((ref) {
  final monitor = ref.watch(networkMonitorProvider);
  return monitor.connectivityStream;
});

/// Provider for current connectivity status (latest value from stream)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.value ?? true; // Default to online
});
