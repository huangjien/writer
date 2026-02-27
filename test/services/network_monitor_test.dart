import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/connectivity_checker.dart';

class MockConnectivityChecker implements ConnectivityChecker {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast(
    sync: true,
  );
  bool _isConnected = true;

  @override
  Future<bool> checkConnectivity() async => _isConnected;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void setConnected(bool connected) {
    _isConnected = connected;
  }

  void emitConnectivityChange(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  void dispose() => _controller.close();
}

void main() {
  group('NetworkMonitor', () {
    late NetworkMonitor networkMonitor;
    late MockConnectivityChecker mockChecker;

    setUp(() {
      mockChecker = MockConnectivityChecker();
      networkMonitor = NetworkMonitor(mockChecker);
    });

    tearDown(() {
      networkMonitor.dispose();
      mockChecker.dispose();
    });

    test('should initialize with isOnline = true', () {
      expect(networkMonitor.isOnline, isTrue);
    });

    test('should provide connectivity stream', () {
      expect(networkMonitor.connectivityStream, isA<Stream<bool>>());
    });

    test('should dispose properly', () {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);

      // Should not throw when disposing
      expect(monitor.dispose, returnsNormally);
      checker.dispose();
    });

    test('should handle disposal without prior start/stop', () {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      monitor.dispose();

      // Should not throw
      expect(monitor.dispose, returnsNormally);
      checker.dispose();
    });

    test('should handle multiple disposals', () {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      monitor.dispose();
      monitor.dispose();

      // Should not throw
      expect(monitor.dispose, returnsNormally);
      checker.dispose();
    });

    test('should maintain consistent isOnline state', () {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final initialOnline = monitor.isOnline;

      // State should remain consistent
      expect(monitor.isOnline, equals(initialOnline));

      monitor.dispose();
      expect(monitor.isOnline, equals(initialOnline));
      checker.dispose();
    });

    test(
      'should handle stream subscription without starting monitoring',
      () async {
        final connectivityEvents = <bool>[];
        final subscription = networkMonitor.connectivityStream.listen(
          connectivityEvents.add,
        );

        await pumpEventQueue();
        await subscription.cancel();

        // Should handle subscription without throwing
        expect(connectivityEvents, isA<List<bool>>());
      },
    );

    test('should handle multiple stream subscriptions', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];

      final subscription1 = networkMonitor.connectivityStream.listen(
        events1.add,
      );

      final subscription2 = networkMonitor.connectivityStream.listen(
        events2.add,
      );

      await pumpEventQueue();

      // Both should handle subscription
      expect(events1, isA<List<bool>>());
      expect(events2, isA<List<bool>>());

      await subscription1.cancel();
      await subscription2.cancel();
    });

    test('should broadcast stream to multiple listeners', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];

      final subscription1 = networkMonitor.connectivityStream.listen(
        events1.add,
      );
      final subscription2 = networkMonitor.connectivityStream.listen(
        events2.add,
      );

      await pumpEventQueue();

      // Both should receive the same events
      expect(events1.length, equals(events2.length));
      if (events1.isNotEmpty && events2.isNotEmpty) {
        expect(events1.last, equals(events2.last));
      }

      await subscription1.cancel();
      await subscription2.cancel();
    });

    test('should handle stream errors gracefully', () async {
      final connectivityEvents = <bool>[];
      bool errorOccurred = false;

      final subscription = networkMonitor.connectivityStream.listen(
        connectivityEvents.add,
        onError: (error) {
          errorOccurred = true;
        },
      );

      await pumpEventQueue();
      await subscription.cancel();

      // Should handle without throwing
      expect(connectivityEvents, isA<List<bool>>());
      // We don't expect errors in normal operation
      expect(errorOccurred, isFalse);
    });

    test('should handle connectivityStream after disposal', () {
      networkMonitor.dispose();

      // Should still return a stream (closed one)
      expect(() => networkMonitor.connectivityStream, returnsNormally);
      expect(networkMonitor.connectivityStream, isA<Stream<bool>>());
    });

    test('should handle rapid disposal', () {
      for (int i = 0; i < 5; i++) {
        final checker = MockConnectivityChecker();
        final monitor = NetworkMonitor(checker);
        monitor.dispose();
        checker.dispose();
      }

      // Should not throw
      expect(() => networkMonitor.dispose(), returnsNormally);
    });

    test('should handle concurrent stream operations', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      monitor.startMonitoring();

      final futures = List.generate(3, (_) => monitor.connectivityStream.first);
      await pumpEventQueue();

      checker.emitConnectivityChange([ConnectivityResult.none]);
      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();

      await Future.wait(futures);
      monitor.dispose();
      checker.dispose();
    });

    test('should maintain stream broadcast behavior', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];

      // Start first subscription
      final subscription1 = networkMonitor.connectivityStream.listen(
        events1.add,
      );

      await pumpEventQueue();

      // Start second subscription after first
      final subscription2 = networkMonitor.connectivityStream.listen(
        events2.add,
      );

      await pumpEventQueue();

      await subscription1.cancel();
      await subscription2.cancel();

      // In test environment, no actual connectivity events occur
      // but both subscriptions should be able to listen to the same broadcast stream
      expect(events1, isEmpty);
      expect(events2, isEmpty);
    });

    test('startMonitoring begins listening to connectivity changes', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);

      // Start monitoring
      monitor.startMonitoring();

      // Emit a connectivity change
      checker.emitConnectivityChange([ConnectivityResult.wifi]);

      // Wait for the change to propagate
      await pumpEventQueue();

      // Verify the monitor received the change
      expect(monitor.isOnline, isTrue);

      monitor.dispose();
      checker.dispose();
    });

    test('startMonitoring updates initial connectivity state', () async {
      final checker = MockConnectivityChecker();
      checker.setConnected(false);
      final monitor = NetworkMonitor(checker);

      // Start monitoring
      monitor.startMonitoring();

      // Wait for initial check
      await pumpEventQueue();
      await pumpEventQueue();

      // Verify the monitor reflects the initial state
      expect(monitor.isOnline, isFalse);

      monitor.dispose();
      checker.dispose();
    });

    test('onConnectivityChanged updates isOnline state', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final connectivityEvents = <bool>[];

      final subscription = monitor.connectivityStream.listen(
        connectivityEvents.add,
      );

      // Start monitoring
      monitor.startMonitoring();

      // Emit offline event
      checker.emitConnectivityChange([ConnectivityResult.none]);
      await pumpEventQueue();
      expect(monitor.isOnline, isFalse);

      // Emit online event
      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();
      expect(monitor.isOnline, isTrue);

      // Emit multiple connectivity types (all online)
      checker.emitConnectivityChange([
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
      ]);
      await pumpEventQueue();
      expect(monitor.isOnline, isTrue);

      await subscription.cancel();
      monitor.dispose();
      checker.dispose();
    });

    test('isConnected returns current connectivity status', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);

      // Initially connected
      expect(await monitor.isConnected, isTrue);

      // Change to disconnected
      checker.setConnected(false);
      expect(await monitor.isConnected, isFalse);

      // Change back to connected
      checker.setConnected(true);
      expect(await monitor.isConnected, isTrue);

      monitor.dispose();
      checker.dispose();
    });

    test('connectivityStream emits initial state on startMonitoring', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final events = <bool>[];

      final subscription = monitor.connectivityStream.listen(events.add);

      // Start monitoring
      monitor.startMonitoring();

      // Wait for initial state
      await pumpEventQueue();
      await pumpEventQueue();

      // Should have received initial state
      expect(events, isNotEmpty);
      expect(events.first, isTrue);

      await subscription.cancel();
      monitor.dispose();
      checker.dispose();
    });

    test('handles ConnectivityResult.none correctly', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final events = <bool>[];

      final subscription = monitor.connectivityStream.listen(events.add);

      monitor.startMonitoring();

      // Emit none (offline)
      checker.emitConnectivityChange([ConnectivityResult.none]);
      await pumpEventQueue();

      expect(monitor.isOnline, isFalse);
      expect(events.last, isFalse);

      // Emit wifi (online)
      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();

      expect(monitor.isOnline, isTrue);
      expect(events.last, isTrue);

      await subscription.cancel();
      monitor.dispose();
      checker.dispose();
    });

    test('handles mixed connectivity results', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final events = <bool>[];

      final subscription = monitor.connectivityStream.listen(events.add);

      monitor.startMonitoring();

      // Emit mixed results (none + wifi) - should be online
      checker.emitConnectivityChange([
        ConnectivityResult.none,
        ConnectivityResult.wifi,
      ]);
      await pumpEventQueue();

      expect(monitor.isOnline, isTrue);

      // Emit only none
      checker.emitConnectivityChange([ConnectivityResult.none]);
      await pumpEventQueue();

      expect(monitor.isOnline, isFalse);

      await subscription.cancel();
      monitor.dispose();
      checker.dispose();
    });

    test('does not emit duplicate connectivity states', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);
      final events = <bool>[];

      final subscription = monitor.connectivityStream.listen(events.add);

      monitor.startMonitoring();

      // Emit same state multiple times
      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();

      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();

      checker.emitConnectivityChange([ConnectivityResult.wifi]);
      await pumpEventQueue();

      // Should only have initial + one change (no duplicates)
      expect(events.length, lessThanOrEqualTo(2));

      await subscription.cancel();
      monitor.dispose();
      checker.dispose();
    });

    test('startMonitoring begins listening to connectivity changes', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);

      // Start monitoring
      monitor.startMonitoring();

      // Emit a connectivity change
      checker.emitConnectivityChange([ConnectivityResult.wifi]);

      // Wait for the change to propagate
      await pumpEventQueue();

      // Verify the monitor received the change
      expect(monitor.isOnline, isTrue);

      monitor.dispose();
      checker.dispose();
    });

    test('stopMonitoring without startMonitoring does not throw', () async {
      final checker = MockConnectivityChecker();
      final monitor = NetworkMonitor(checker);

      // Stop without starting
      expect(monitor.stopMonitoring, returnsNormally);

      monitor.dispose();
      checker.dispose();
    });
  });
}
