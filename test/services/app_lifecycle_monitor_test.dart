import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/services/app_lifecycle_monitor.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/services/background_sync_service.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockSyncService extends Mock implements SyncService {}

class MockBackgroundSyncService extends Mock implements BackgroundSyncService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLifecycleMonitor', () {
    late ProviderContainer container;
    late MockSyncService mockSyncService;
    late MockBackgroundSyncService mockBackgroundSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
      mockBackgroundSyncService = MockBackgroundSyncService();
      final mockPrefs = MockSharedPreferences();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          syncServiceProvider.overrideWithValue(mockSyncService),
          backgroundSyncServiceProvider.overrideWithValue(
            mockBackgroundSyncService,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should create widget without child', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should create widget with child', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: AppLifecycleMonitor(
            child: Container(key: const Key('test-child')),
          ),
        ),
      );

      expect(find.byKey(const Key('test-child')), findsOneWidget);
    });

    testWidgets('should start sync monitoring on initialization', (
      tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      verify(() => mockSyncService.startMonitoring()).called(1);
    });

    testWidgets('should stop sync monitoring on disposal', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      await tester.pumpWidget(Container());

      verify(() => mockSyncService.stopMonitoring()).called(1);
    });

    testWidgets(
      'should handle exceptions gracefully when starting monitoring',
      (tester) async {
        when(
          () => mockSyncService.startMonitoring(),
        ).thenThrow(Exception('Test error'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppLifecycleMonitor(),
          ),
        );

        // Should not throw
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should handle exceptions gracefully when stopping monitoring',
      (tester) async {
        when(
          () => mockSyncService.stopMonitoring(),
        ).thenThrow(Exception('Test error'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppLifecycleMonitor(),
          ),
        );

        await tester.pumpWidget(Container());

        // Should not throw
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should handle provider not being available', (tester) async {
      final containerWithoutSync = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(MockSharedPreferences()),
          syncServiceProvider.overrideWith(
            (ref) => throw Exception('Sync service unavailable'),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: containerWithoutSync,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Should not throw when provider is not available
      expect(tester.takeException(), isNull);

      containerWithoutSync.dispose();
    });

    testWidgets('should handle multiple start/stop cycles', (tester) async {
      // Multiple create/destroy cycles
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppLifecycleMonitor(),
          ),
        );

        await tester.pumpWidget(Container());
      }

      verify(() => mockSyncService.startMonitoring()).called(3);
      verify(() => mockSyncService.stopMonitoring()).called(3);
    });

    testWidgets('should build child widget when provided', (tester) async {
      final childWidget = Container(key: const Key('test-child-text'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: AppLifecycleMonitor(child: childWidget),
        ),
      );

      expect(find.byKey(const Key('test-child-text')), findsOneWidget);
    });

    testWidgets('should build SizedBox when no child provided', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('AppLifecycleMonitor error handling', () {
    testWidgets('should debugPrint errors in debug mode', (tester) async {
      final mockSyncService = MockSyncService();
      when(mockSyncService.startMonitoring).thenThrow(Exception('Debug error'));

      // Capture debug print calls
      final debugPrints = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) debugPrints.add(message);
      };

      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: ProviderContainer(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(
                  MockSharedPreferences(),
                ),
                syncServiceProvider.overrideWithValue(mockSyncService),
              ],
            ),
            child: const AppLifecycleMonitor(),
          ),
        );

        expect(
          debugPrints.any(
            (msg) => msg.contains('Failed to start sync monitoring'),
          ),
          isTrue,
        );
      } finally {
        debugPrint = originalDebugPrint;
      }
    });
  });

  group('AppLifecycleMonitor edge cases', () {
    testWidgets('should handle disposal before initialization', (tester) async {
      final testContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(MockSharedPreferences()),
          syncServiceProvider.overrideWithValue(MockSyncService()),
        ],
      );

      // Create and dispose quickly
      const widget = AppLifecycleMonitor();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: testContainer, child: widget),
      );

      await tester.pumpWidget(Container());

      // Should not throw
      expect(tester.takeException(), isNull);

      testContainer.dispose();
    });

    testWidgets('should handle rapid widget changes', (tester) async {
      final localMockSyncService = MockSyncService();
      final testContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(MockSharedPreferences()),
          syncServiceProvider.overrideWithValue(localMockSyncService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const AppLifecycleMonitor(),
        ),
      );

      reset(localMockSyncService);

      // Rapid widget changes
      await tester.pumpWidget(Container());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const AppLifecycleMonitor(),
        ),
      );
      await tester.pumpWidget(Container());

      verify(localMockSyncService.startMonitoring).called(1);
      verify(localMockSyncService.stopMonitoring).called(2);

      testContainer.dispose();
    });
  });

  group('AppLifecycleMonitor lifecycle state changes', () {
    late ProviderContainer container;
    late MockSyncService mockSyncService;
    late MockBackgroundSyncService mockBackgroundSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
      mockBackgroundSyncService = MockBackgroundSyncService();
      when(() => mockBackgroundSyncService.startMonitoring()).thenReturn(null);
      when(() => mockBackgroundSyncService.stopMonitoring()).thenReturn(null);
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(MockSharedPreferences()),
          syncServiceProvider.overrideWithValue(mockSyncService),
          backgroundSyncServiceProvider.overrideWithValue(
            mockBackgroundSyncService,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should start monitoring when app resumes', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate app resuming
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );
      await tester.pump();

      verify(() => mockSyncService.startMonitoring()).called(1);
      verifyNever(() => mockSyncService.stopMonitoring());
    });

    testWidgets('should stop monitoring when app pauses', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate app pausing
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.paused'),
        (data) {},
      );
      await tester.pump();

      verify(() => mockSyncService.stopMonitoring()).called(1);
      verifyNever(() => mockSyncService.startMonitoring());
    });

    testWidgets('should stop monitoring when app becomes inactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate app becoming inactive
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.inactive'),
        (data) {},
      );
      await tester.pump();

      verify(() => mockSyncService.stopMonitoring()).called(1);
      verifyNever(() => mockSyncService.startMonitoring());
    });

    testWidgets('should stop monitoring when app is hidden', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate app being hidden
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.hidden'),
        (data) {},
      );
      await tester.pump();

      verify(() => mockSyncService.stopMonitoring()).called(1);
      verifyNever(() => mockSyncService.startMonitoring());
    });

    testWidgets('should stop monitoring when app is detached', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate app being detached
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.detached'),
        (data) {},
      );
      await tester.pump();

      verify(() => mockSyncService.stopMonitoring()).called(1);
      verifyNever(() => mockSyncService.startMonitoring());
    });

    testWidgets('should handle multiple lifecycle state changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppLifecycleMonitor(),
        ),
      );

      // Clear initial calls
      clearInteractions(mockSyncService);

      // Simulate lifecycle sequence: resume -> pause -> resume
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );
      await tester.pump();

      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.paused'),
        (data) {},
      );
      await tester.pump();

      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );
      await tester.pump();

      // Should start monitoring multiple times
      verify(
        () => mockSyncService.startMonitoring(),
      ).called(greaterThanOrEqualTo(2));
      // Should stop monitoring at least once
      verify(
        () => mockSyncService.stopMonitoring(),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
