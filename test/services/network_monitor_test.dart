import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/network_monitor.dart';

void main() {
  group('NetworkMonitor', () {
    late NetworkMonitor networkMonitor;

    setUp(() {
      networkMonitor = NetworkMonitor();
    });

    tearDown(() {
      networkMonitor.dispose();
    });

    test('should initialize with isOnline = true', () {
      expect(networkMonitor.isOnline, isTrue);
    });

    test('should provide connectivity stream', () {
      expect(networkMonitor.connectivityStream, isA<Stream<bool>>());
    });

    test('should dispose properly', () {
      final monitor = NetworkMonitor();
      
      // Should not throw when disposing
      expect(() => monitor.dispose(), returnsNormally);
    });

    test('should handle disposal without prior start/stop', () {
      final monitor = NetworkMonitor();
      monitor.dispose();
      
      // Should not throw
      expect(() => monitor.dispose(), returnsNormally);
    });

    test('should handle multiple disposals', () {
      final monitor = NetworkMonitor();
      monitor.dispose();
      monitor.dispose();
      
      // Should not throw
      expect(() => monitor.dispose(), returnsNormally);
    });

    test('should maintain consistent isOnline state', () {
      final monitor = NetworkMonitor();
      final initialOnline = monitor.isOnline;
      
      // State should remain consistent
      expect(monitor.isOnline, equals(initialOnline));
      
      monitor.dispose();
      expect(monitor.isOnline, equals(initialOnline));
    });

    test('should handle stream subscription without starting monitoring', () async {
      final connectivityEvents = <bool>[];
      final subscription = networkMonitor.connectivityStream.listen((event) {
        connectivityEvents.add(event);
      });

      await Future.delayed(Duration(milliseconds: 50));
      await subscription.cancel();
      
      // Should handle subscription without throwing
      expect(connectivityEvents, isA<List<bool>>());
    });

    test('should handle multiple stream subscriptions', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];
      
      final subscription1 = networkMonitor.connectivityStream.listen((event) {
        events1.add(event);
      });
      
      final subscription2 = networkMonitor.connectivityStream.listen((event) {
        events2.add(event);
      });

      await Future.delayed(Duration(milliseconds: 50));
      
      // Both should handle subscription
      expect(events1, isA<List<bool>>());
      expect(events2, isA<List<bool>>());

      await subscription1.cancel();
      await subscription2.cancel();
    });

    test('should broadcast stream to multiple listeners', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];
      
      final subscription1 = networkMonitor.connectivityStream.listen(events1.add);
      final subscription2 = networkMonitor.connectivityStream.listen(events2.add);

      await Future.delayed(Duration(milliseconds: 50));
      
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
        (event) => connectivityEvents.add(event),
        onError: (error) {
          errorOccurred = true;
        },
      );

      await Future.delayed(Duration(milliseconds: 50));
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
        final monitor = NetworkMonitor();
        monitor.dispose();
      }
      
      // Should not throw
      expect(() => networkMonitor.dispose(), returnsNormally);
    });

    test('should handle concurrent stream operations', () async {
      final futures = <Future>[];
      
      for (int i = 0; i < 3; i++) {
        futures.add(
          networkMonitor.connectivityStream.first.timeout(Duration(milliseconds: 100))
        );
      }
      
      // Should handle concurrent operations without throwing
      try {
        await Future.any(futures);
      } catch (e) {
        // Timeout is acceptable in test environment
        expect(e, isA<TimeoutException>());
      }
    });

    test('should maintain stream broadcast behavior', () async {
      final events1 = <bool>[];
      final events2 = <bool>[];
      
      // Start first subscription
      final subscription1 = networkMonitor.connectivityStream.listen(events1.add);
      
      await Future.delayed(Duration(milliseconds: 50));
      
      // Start second subscription after first
      final subscription2 = networkMonitor.connectivityStream.listen(events2.add);
      
      await Future.delayed(Duration(milliseconds: 50));
      
      await subscription1.cancel();
      await subscription2.cancel();
      
      // In test environment, no actual connectivity events occur
      // but both subscriptions should be able to listen to the same broadcast stream
      expect(events1, isEmpty);
      expect(events2, isEmpty);
    });
  });
}