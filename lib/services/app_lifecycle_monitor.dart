import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/sync_service_provider.dart';

/// Monitors app lifecycle events to start/stop sync monitoring
/// Starts sync when app comes to foreground, stops when in background
class AppLifecycleMonitor extends ConsumerStatefulWidget {
  final Widget? child;

  const AppLifecycleMonitor({super.key, this.child});

  @override
  ConsumerState<AppLifecycleMonitor> createState() =>
      _AppLifecycleMonitorState();
}

class _AppLifecycleMonitorState extends ConsumerState<AppLifecycleMonitor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start monitoring when app launches
    _startSyncMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop monitoring when widget is disposed
    _stopSyncMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - start sync
        _startSyncMonitoring();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - stop monitoring
        _stopSyncMonitoring();
        break;
    }
  }

  void _startSyncMonitoring() {
    try {
      final syncService = ref.read(syncServiceProvider);
      syncService.startMonitoring();
    } catch (e) {
      // Provider might not be initialized yet, ignore
      if (kDebugMode) {
        debugPrint('Failed to start sync monitoring: $e');
      }
    }
  }

  void _stopSyncMonitoring() {
    try {
      final syncService = ref.read(syncServiceProvider);
      syncService.stopMonitoring();
    } catch (e) {
      // Provider might not be initialized, ignore
      if (kDebugMode) {
        debugPrint('Failed to stop sync monitoring: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
