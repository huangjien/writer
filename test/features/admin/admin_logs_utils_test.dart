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
      expect(result[1]['level'], 'INFO'); // Default level for malformed
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
    late BuildContext context;

    setUp(() {
      // Create a test context with light theme
      final theme = ThemeData.light();
      context = _createTestContext(theme);
    });

    test('returns error color for ERROR level', () {
      final color = getAdminLogLevelColor(context, 'ERROR');
      expect(color, const Color(0xFFFFB4AB));
    });

    test('returns error color for CRITICAL level', () {
      final color = getAdminLogLevelColor(context, 'CRITICAL');
      expect(color, const Color(0xFFFFB4AB));
    });

    test('returns warning color for WARNING level', () {
      final color = getAdminLogLevelColor(context, 'WARNING');
      expect(color, const Color(0xFF9A5200));
    });

    test('returns primary color for INFO level', () {
      final color = getAdminLogLevelColor(context, 'INFO');
      expect(color, ThemeData.light().colorScheme.primary);
    });

    test('returns neutral color for DEBUG level', () {
      final color = getAdminLogLevelColor(context, 'DEBUG');
      expect(color, ThemeData.light().colorScheme.onSurfaceVariant);
    });

    test('returns default color for unknown level', () {
      final color = getAdminLogLevelColor(context, 'UNKNOWN');
      expect(color, ThemeData.light().colorScheme.onSurface);
    });

    test('handles lowercase level strings', () {
      final color = getAdminLogLevelColor(context, 'error');
      expect(color, const Color(0xFFFFB4AB));
    });

    test('handles mixed case level strings', () {
      final color = getAdminLogLevelColor(context, 'WaRnInG');
      expect(color, const Color(0xFF9A5200));
    });

    test('returns dark theme colors in dark mode', () {
      final darkTheme = ThemeData.dark();
      final darkContext = _createTestContext(darkTheme);

      final errorColor = getAdminLogLevelColor(darkContext, 'ERROR');
      expect(errorColor, const Color(0xFFFFB4AB));

      final warningColor = getAdminLogLevelColor(darkContext, 'WARNING');
      expect(warningColor, const Color(0xFFFFD8A8));

      final infoColor = getAdminLogLevelColor(darkContext, 'INFO');
      expect(infoColor, const Color(0xFF9CB9FF));
    });
  });

  group('getAdminLogLevelBackgroundColor', () {
    late BuildContext context;

    setUp(() {
      final theme = ThemeData.light();
      context = _createTestContext(theme);
    });

    test('returns error container for ERROR level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'ERROR');
      expect(color, ThemeData.light().colorScheme.errorContainer);
    });

    test('returns error container for CRITICAL level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'CRITICAL');
      expect(color, ThemeData.light().colorScheme.errorContainer);
    });

    test('returns warning background for WARNING level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'WARNING');
      expect(color, const Color(0xFFFFE8CC));
    });

    test('returns primary container for INFO level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'INFO');
      expect(color, ThemeData.light().colorScheme.primaryContainer);
    });

    test('returns surface container for DEBUG level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'DEBUG');
      expect(color, ThemeData.light().colorScheme.surfaceContainerHighest);
    });

    test('returns default surface for unknown level', () {
      final color = getAdminLogLevelBackgroundColor(context, 'UNKNOWN');
      expect(color, ThemeData.light().colorScheme.surface);
    });

    test('handles lowercase level strings', () {
      final color = getAdminLogLevelBackgroundColor(context, 'error');
      expect(color, ThemeData.light().colorScheme.errorContainer);
    });

    test('returns dark theme colors in dark mode', () {
      final darkTheme = ThemeData.dark();
      final darkContext = _createTestContext(darkTheme);

      final errorBg = getAdminLogLevelBackgroundColor(darkContext, 'ERROR');
      expect(errorBg, const Color(0xFF5C1D1D).withValues(alpha: 0.3));

      final warningBg = getAdminLogLevelBackgroundColor(darkContext, 'WARNING');
      expect(warningBg, const Color(0xFF5C3800).withValues(alpha: 0.3));

      final infoBg = getAdminLogLevelBackgroundColor(darkContext, 'INFO');
      expect(infoBg, const Color(0xFF1A2F5C).withValues(alpha: 0.3));
    });

    test('alpha values are correctly applied in dark mode', () {
      final darkTheme = ThemeData.dark();
      final darkContext = _createTestContext(darkTheme);

      final errorBg = getAdminLogLevelBackgroundColor(darkContext, 'ERROR');
      expect(errorBg.alpha, lessThan(1.0));
      expect(errorBg.alpha, greaterThan(0.0));
    });
  });
}

BuildContext _createTestContext(ThemeData theme) {
  return _TestBuildContext(theme);
}

class _TestBuildContext implements BuildContext {
  final ThemeData theme;

  _TestBuildContext(this.theme);

  @override
  Widget get widget => throw UnimplementedError();

  @override
  bool get mounted => true;

  @override
  InheritedWidget inheritFromElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) {
    if (ancestor.widget is _RootTheme) {
      return theme;
    }
    throw UnimplementedError();
  }

  @override
  Element? get element => throw UnimplementedError();

  @override
  Iterable<InheritedWidget> get inheritedElements =>
      throw UnimplementedError();

  @override
  BuildOwner? get owner => throw UnimplementedError();

  @override
  RenderObject? get renderObject => throw UnimplementedError();

  @override
  RenderObject? get findRenderObject => throw UnimplementedError();

  @override
  Size get size => Size.zero;

  @override
  Offset get paintBounds => Offset.zero;
}

class _RootTheme extends InheritedWidget {
  final ThemeData data;

  const _RootTheme({required this.data, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(_RootTheme oldWidget) => true;
}
