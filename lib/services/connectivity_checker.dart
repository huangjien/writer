import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity monitoring
///
/// This abstraction allows for easy testing by providing mock implementations.
abstract class ConnectivityChecker {
  /// Check if currently connected (synchronous check)
  Future<bool> checkConnectivity();

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// Real implementation using connectivity_plus
class RealConnectivityChecker implements ConnectivityChecker {
  final Connectivity _connectivity;

  RealConnectivityChecker({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
