import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:writer/services/connectivity_checker.dart';

/// Monitor for network connectivity
///
/// This class monitors network connectivity using the ConnectivityChecker abstraction.
class NetworkMonitor {
  final ConnectivityChecker _connectivityChecker;
  final StreamController<bool> _connectivityController;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  int _connectivityEventCount = 0;

  NetworkMonitor(this._connectivityChecker)
    : _connectivityController = StreamController<bool>.broadcast();

  /// Current online status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if currently connected (synchronous check)
  Future<bool> get isConnected async {
    return await _connectivityChecker.checkConnectivity();
  }

  /// Start monitoring network connectivity
  void startMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityChecker.onConnectivityChanged
        .listen(_onConnectivityChanged);
    _updateConnectivity();
  }

  /// Stop monitoring network connectivity
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    if (!_connectivityController.isClosed) {
      _connectivityController.close();
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Don't process if controller is closed
    if (_connectivityController.isClosed) return;
    _connectivityEventCount++;

    // Determine if we have any network connection
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    // Update status if changed
    if (hasConnection != _isOnline) {
      _isOnline = hasConnection;
      if (!_connectivityController.isClosed) {
        _connectivityController.add(_isOnline);
      }
    }
  }

  Future<void> _updateConnectivity() async {
    final expectedEventCount = _connectivityEventCount;
    // Initial check
    final isOnline = await _connectivityChecker.checkConnectivity();
    if (expectedEventCount != _connectivityEventCount) return;
    _isOnline = isOnline;
    if (!_connectivityController.isClosed) {
      _connectivityController.add(_isOnline);
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    if (!_connectivityController.isClosed) {
      _connectivityController.close();
    }
  }
}
