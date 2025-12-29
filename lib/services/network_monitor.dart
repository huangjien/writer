import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  final StreamController<bool> _connectivityController;
  bool _isOnline = true;
  Timer? _debounceTimer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkMonitor()
    : _connectivityController = StreamController<bool>.broadcast();

  /// Current online status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes (debounced by 2 seconds)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if currently connected (synchronous check)
  Future<bool> get isConnected async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Start monitoring network connectivity
  void startMonitoring() {
    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    _updateConnectivity();
  }

  /// Stop monitoring network connectivity
  void stopMonitoring() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Determine if we have any network connection
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    // Update status if changed
    if (hasConnection != _isOnline) {
      _isOnline = hasConnection;
      _connectivityController.add(_isOnline);
    }
  }

  void _updateConnectivity() async {
    final connectivity = Connectivity();
    final List<ConnectivityResult> results = await connectivity
        .checkConnectivity();
    _onConnectivityChanged(results);
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _connectivityController.close();
  }
}
