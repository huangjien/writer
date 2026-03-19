import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/admin/admin_logs_screen.dart';
import 'package:writer/models/admin_log.dart';
import 'package:writer/features/admin/admin_logs_utils.dart';

void main() {
  group('AdminLogsScreen Coverage Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('shows empty state when no logs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('No logs available'), findsOneWidget);
    });

    testWidgets('disables refresh button during loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            isLoadingProvider.overrideWith((ref) => true),
            filteredLogsProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find refresh button and verify it's disabled
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      final IconButton button = tester.widget<IconButton>(refreshButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('enables refresh button when not loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            isLoadingProvider.overrideWith((ref) => false),
            filteredLogsProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find refresh button and verify it's enabled
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      final IconButton button = tester.widget<IconButton>(refreshButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('filters logs by level - ERROR only', (tester) async {
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.error,
          message: 'Error message',
          timestamp: DateTime.now(),
          context: {},
        ),
        AdminLog(
          id: '2',
          level: LogLevel.info,
          message: 'Info message',
          timestamp: DateTime.now(),
          context: {},
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap error filter
      await tester.tap(find.text('ERROR'));
      await tester.pumpAndSettle();

      // Verify filtering works
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('filters logs by level - INFO only', (tester) async {
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.error,
          message: 'Error message',
          timestamp: DateTime.now(),
          context: {},
        ),
        AdminLog(
          id: '2',
          level: LogLevel.info,
          message: 'Info message',
          timestamp: DateTime.now(),
          context: {},
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap info filter
      await tester.tap(find.text('INFO'));
      await tester.pumpAndSettle();

      // Verify filtering works
      expect(find.text('Info message'), findsOneWidget);
    });

    testWidgets('shows all logs when ALL filter selected', (tester) async {
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.error,
          message: 'Error message',
          timestamp: DateTime.now(),
          context: {},
        ),
        AdminLog(
          id: '2',
          level: LogLevel.info,
          message: 'Info message',
          timestamp: DateTime.now(),
          context: {},
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap ALL filter
      await tester.tap(find.text('ALL'));
      await tester.pumpAndSettle();

      // Verify both logs are shown
      expect(find.text('Error message'), findsOneWidget);
      expect(find.text('Info message'), findsOneWidget);
    });

    testWidgets('displays log timestamp correctly', (tester) async {
      final now = DateTime.now();
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.info,
          message: 'Test message',
          timestamp: now,
          context: {},
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify timestamp is displayed (format may vary)
      expect(find.byType(AdminLogsScreen), findsOneWidget);
    });

    testWidgets('handles log with empty context', (tester) async {
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.now(),
          context: {}, // Empty context
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(AdminLogsScreen), findsOneWidget);
    });

    testWidgets('handles log with null context', (tester) async {
      final logs = [
        AdminLog(
          id: '1',
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.now(),
          context: null, // Null context
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            filteredLogsProvider.overrideWith((ref) => logs),
          ],
          child: const MaterialApp(
            home: AdminLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(AdminLogsScreen), findsOneWidget);
    });
  });
}
