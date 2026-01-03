import 'package:flutter/foundation.dart';

/// A logger service that restricts exception info and suppresses repeated exceptions.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Configuration - much more aggressive limits for test logs
  static const int _maxStackTraceLines = 5;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxExceptionsPerWindow = 3;
  static const int _maxConsecutiveStackFrames = 2;
  static const int _maxLineLength = 200;

  // State for rate limiting
  final Map<String, int> _exceptionCounts = {};
  final Map<String, DateTime> _lastExceptionTime = {};

  // State for log line processing
  int _consecutiveStackFrames = 0;

  /// Processes a log message (which may contain multiple lines) and calls [output]
  /// for lines that should be printed.
  /// Handles stack trace truncation and line length limiting.
  void processLogLine(String text, void Function(String) output) {
    // Handle multi-line messages (like stack traces printed in one go)
    if (text.contains('\n')) {
      final lines = text.split('\n');
      for (final line in lines) {
        _processSingleLine(line, output);
      }
    } else {
      _processSingleLine(text, output);
    }
  }

  void _processSingleLine(String line, void Function(String) output) {
    // Aggressive filtering for common noisy patterns
    final trimmed = line.trim();

    // Skip empty lines
    if (trimmed.isEmpty) return;

    // Skip Flutter framework exception headers (very noisy)
    if (trimmed.startsWith('══╡ EXCEPTION CAUGHT BY')) return;
    if (trimmed.startsWith('══════════════════════════════════════')) return;
    if (trimmed.startsWith('The following assertion was thrown')) return;
    if (trimmed.startsWith('The test description was:')) return;
    if (trimmed.startsWith('Test failed. See exception logs above.')) return;
    if (trimmed.startsWith('To run this test again:')) return;

    // Skip common rendering/layout exception patterns
    if (trimmed.contains('RenderFlex children have non-zero flex')) {
      return;
    }
    if (trimmed.contains('When a row is in a parent that does not provide')) {
      return;
    }
    if (trimmed.contains('These two directives are mutually exclusive')) return;
    if (trimmed.contains('Consider setting mainAxisSize')) return;
    if (trimmed.contains('The affected RenderFlex is:')) return;
    if (trimmed.contains('creator: Row ← ReaderEditActions')) return;

    // Skip test framework noise
    if (trimmed.startsWith('[Settings]')) return;
    if (trimmed.contains('TestWidgetsFlutterBinding')) return;
    if (trimmed.startsWith('FlutterError')) return;

    // Truncate long lines
    String processedLine = line;
    if (line.length > _maxLineLength) {
      processedLine = '${line.substring(0, _maxLineLength)}... (truncated)';
    }

    // Check if it's a stack frame
    if (trimmed.startsWith('#')) {
      _consecutiveStackFrames++;
      if (_consecutiveStackFrames <= _maxConsecutiveStackFrames) {
        output(processedLine);
      }
      // Else suppress - don't even print the suppression message to reduce noise
    } else {
      // Reset stack frame counter
      _consecutiveStackFrames = 0;
      output(processedLine);
    }
  }

  /// Determines if an error should be logged based on rate limiting.
  bool shouldLog(dynamic error) {
    return _shouldLog(error);
  }

  /// Truncates a stack trace and returns a new StackTrace object.
  StackTrace truncateStackTrace(StackTrace stack) {
    final lines = stack.toString().split('\n');
    if (lines.length <= _maxStackTraceLines) {
      return stack;
    }
    final truncated =
        '${lines.take(_maxStackTraceLines).join('\n')}\n... (truncated, showing first $_maxStackTraceLines frames)';
    return StackTrace.fromString(truncated);
  }

  /// Logs an error with restricted stack trace and rate limiting.
  void logError(dynamic error, [StackTrace? stackTrace]) {
    if (!_shouldLog(error)) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final errorStr = error.toString();

    // Truncate stack trace if present
    String? formattedStack;
    if (stackTrace != null) {
      final lines = stackTrace.toString().split('\n');
      if (lines.length > _maxStackTraceLines) {
        formattedStack =
            '${lines.take(_maxStackTraceLines).join('\n')}\n... (truncated, showing first $_maxStackTraceLines frames)';
      } else {
        formattedStack = stackTrace.toString();
      }
    }

    // Use debugPrint to output to console (visible in tests)
    debugPrint('[$timestamp] ERROR: $errorStr');
    if (formattedStack != null) {
      debugPrint(formattedStack);
    }
  }

  /// Determines if an error should be logged based on rate limiting.
  bool _shouldLog(dynamic error) {
    final key = error.toString(); // Simple key based on error message
    final now = DateTime.now();

    if (!_lastExceptionTime.containsKey(key)) {
      _lastExceptionTime[key] = now;
      _exceptionCounts[key] = 1;
      return true;
    }

    final lastTime = _lastExceptionTime[key]!;
    if (now.difference(lastTime) > _rateLimitWindow) {
      // Reset window
      _lastExceptionTime[key] = now;
      _exceptionCounts[key] = 1;
      return true;
    }

    // Within window
    final count = _exceptionCounts[key]!;
    if (count < _maxExceptionsPerWindow) {
      _exceptionCounts[key] = count + 1;
      return true;
    } else if (count == _maxExceptionsPerWindow) {
      // Log suppression warning once
      _exceptionCounts[key] = count + 1;
      debugPrint(
        'RATE LIMITED: "$key" (similar messages suppressed for ${_rateLimitWindow.inSeconds}s)',
      );
      return false;
    }

    return false;
  }
}
