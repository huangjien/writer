import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/admin/admin_logs_utils.dart';

void main() {
  group('parseAdminLogs', () {
    test('parses valid JSON logs', () {
      const logsString = '''
{"level":"INFO","message":"Test 1","timestamp":"2024-03-13T12:00:00Z"}
{"level":"ERROR","message":"Error occurred","timestamp":"2024-03-13T12:01:00Z"}
{"level":"WARNING","message":"Warning message","timestamp":"2024-03-13T12:02:00Z"}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 3);
      expect(result[0]['level'], 'INFO');
      expect(result[0]['message'], 'Test 1');
      expect(result[1]['level'], 'ERROR');
      expect(result[2]['level'], 'WARNING');
    });

    test('handles empty lines', () {
      const logsString = '''
{"level":"INFO","message":"Test 1"}

{"level":"ERROR","message":"Error"}


{"level":"WARNING","message":"Warning"}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 3);
    });

    test('handles malformed JSON lines', () {
      const logsString = '''
{"level":"INFO","message":"Valid log"}
This is not a JSON line
{"level":"ERROR","message":"Another valid"}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 3);
      expect(result[0]['level'], 'INFO');
      expect(result[1]['raw'], 'This is not a JSON line');
      expect(result[1]['level'], 'INFO');
      expect(result[2]['level'], 'ERROR');
    });

    test('handles completely invalid JSON', () {
      const logsString = '''
{"invalid": "missing quote}
Not JSON at all
{"level":"DEBUG","valid":"true"}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 3);
      expect(result[0]['raw'], '{"invalid": "missing quote}');
      expect(result[1]['raw'], 'Not JSON at all');
      expect(result[2]['level'], 'DEBUG');
    });

    test('returns empty list for empty string', () {
      final result = parseAdminLogs('');
      expect(result, isEmpty);
    });

    test('returns empty list for whitespace only', () {
      final result = parseAdminLogs('   \n\n  \n');
      expect(result, isEmpty);
    });

    test('handles logs with extra fields', () {
      const logsString = '''
{"level":"INFO","message":"Test","timestamp":"2024-03-13T12:00:00Z","extra":"field","number":42}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 1);
      expect(result[0]['extra'], 'field');
      expect(result[0]['number'], 42);
    });

    test('preserves log entry structure', () {
      const logsString = '''
{"level":"INFO","message":"Test","user_id":"123","action":"login"}''';

      final result = parseAdminLogs(logsString);

      expect(result.length, 1);
      expect(result[0]['user_id'], '123');
      expect(result[0]['action'], 'login');
    });
  });

  group('getAdminLogLevelColor', () {
    testWidgets('returns error color for ERROR level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'ERROR');
              expect(color, ThemeData.light().colorScheme.error);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns error color for CRITICAL level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'CRITICAL');
              expect(color, ThemeData.light().colorScheme.error);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns warning color for WARNING level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'WARNING');
              expect(color, const Color(0xFF9A5200));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns primary color for INFO level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'INFO');
              expect(color, ThemeData.light().colorScheme.primary);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns neutral color for DEBUG level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'DEBUG');
              expect(color, ThemeData.light().colorScheme.onSurfaceVariant);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns default color for unknown level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'UNKNOWN');
              expect(color, ThemeData.light().colorScheme.onSurface);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('handles lowercase level strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'error');
              expect(color, ThemeData.light().colorScheme.error);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('handles mixed case level strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelColor(context, 'WaRnInG');
              expect(color, const Color(0xFF9A5200));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns dark theme colors in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final errorColor = getAdminLogLevelColor(context, 'ERROR');
              expect(errorColor, const Color(0xFFFFB4AB));

              final warningColor = getAdminLogLevelColor(context, 'WARNING');
              expect(warningColor, const Color(0xFFFFD8A8));

              final infoColor = getAdminLogLevelColor(context, 'INFO');
              expect(infoColor, const Color(0xFF9CB9FF));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('getAdminLogLevelBackgroundColor', () {
    testWidgets('returns error container for ERROR level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'ERROR');
              expect(color, ThemeData.light().colorScheme.errorContainer);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns error container for CRITICAL level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(
                context,
                'CRITICAL',
              );
              expect(color, ThemeData.light().colorScheme.errorContainer);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns warning background for WARNING level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'WARNING');
              expect(color, const Color(0xFFFFE8CC));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns primary container for INFO level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'INFO');
              expect(color, ThemeData.light().colorScheme.primaryContainer);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns surface container for DEBUG level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'DEBUG');
              expect(
                color,
                ThemeData.light().colorScheme.surfaceContainerHighest,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns default surface for unknown level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'UNKNOWN');
              expect(color, ThemeData.light().colorScheme.surface);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('handles lowercase level strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = getAdminLogLevelBackgroundColor(context, 'error');
              expect(color, ThemeData.light().colorScheme.errorContainer);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns dark theme colors in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final errorBg = getAdminLogLevelBackgroundColor(context, 'ERROR');
              expect(errorBg, const Color(0xFF5C1D1D).withValues(alpha: 0.3));

              final warningBg = getAdminLogLevelBackgroundColor(
                context,
                'WARNING',
              );
              expect(warningBg, const Color(0xFF5C3800).withValues(alpha: 0.3));

              final infoBg = getAdminLogLevelBackgroundColor(context, 'INFO');
              expect(infoBg, const Color(0xFF1A2F5C).withValues(alpha: 0.3));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('alpha values are correctly applied in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final errorBg = getAdminLogLevelBackgroundColor(context, 'ERROR');
              expect(errorBg.a, lessThan(1.0));
              expect(errorBg.a, greaterThan(0.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
