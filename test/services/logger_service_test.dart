import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    late LoggerService logger;
    late List<String> outputLines;

    setUp(() {
      logger = LoggerService();
      outputLines = [];
      // Reset singleton state (stack frame counter)
      logger.processLogLine('RESET_STATE', (_) {});
    });

    void captureOutput(String line) {
      outputLines.add(line);
    }

    test('processLogLine processes single line', () {
      logger.processLogLine('Test log', captureOutput);
      expect(outputLines, ['Test log']);
    });

    test('processLogLine splits multi-line logs', () {
      logger.processLogLine('Line 1\nLine 2', captureOutput);
      expect(outputLines, ['Line 1', 'Line 2']);
    });

    test('filters out empty lines', () {
      logger.processLogLine('\n   \n', captureOutput);
      expect(outputLines, isEmpty);
    });

    test('filters out Flutter exception headers', () {
      logger.processLogLine('══╡ EXCEPTION CAUGHT BY', captureOutput);
      expect(outputLines, isEmpty);

      logger.processLogLine(
        '══════════════════════════════════════',
        captureOutput,
      );
      expect(outputLines, isEmpty);
    });

    test('filters out filtered patterns', () {
      logger.processLogLine(
        'The following assertion was thrown',
        captureOutput,
      );
      logger.processLogLine('[Settings] initState', captureOutput);
      logger.processLogLine(
        'RenderFlex children have non-zero flex',
        captureOutput,
      );
      expect(outputLines, isEmpty);
    });

    test('truncates long lines', () {
      final longLine = 'a' * 300;
      logger.processLogLine(longLine, captureOutput);
      expect(outputLines.first, endsWith('... (truncated)'));
      expect(outputLines.first.length, lessThan(300));
    });

    test('limits consecutive stack frames', () {
      logger.processLogLine('#0 Frame 0', captureOutput);
      logger.processLogLine('#1 Frame 1', captureOutput);
      logger.processLogLine('#2 Frame 2', captureOutput);
      logger.processLogLine('#3 Frame 3', captureOutput);

      // Should show first 2 frames (based on _maxConsecutiveStackFrames = 2)
      // Note: Implementation allows <= max, so 0, 1, 2 = 3 frames?
      // Let's check logic:
      // if (trimmed.startsWith('#')) {
      //   _consecutiveStackFrames++;
      //   if (_consecutiveStackFrames <= _maxConsecutiveStackFrames) {
      //     output(processedLine);
      //   }
      // }
      // _maxConsecutiveStackFrames is 2.
      // #0 -> count=1 -> output
      // #1 -> count=2 -> output
      // #2 -> count=3 -> skip

      expect(outputLines.length, 2);
      expect(outputLines[0], '#0 Frame 0');
      expect(outputLines[1], '#1 Frame 1');
    });

    test('resets stack frame counter on non-stack line', () {
      logger.processLogLine('#0 Frame 0', captureOutput);
      logger.processLogLine('#1 Frame 1', captureOutput);
      logger.processLogLine('Not a frame', captureOutput);
      logger.processLogLine('#0 New Frame', captureOutput);

      expect(outputLines.length, 4);
      expect(outputLines[2], 'Not a frame');
      expect(outputLines[3], '#0 New Frame');
    });

    test('shouldLog implements rate limiting', () async {
      // Since _instance is static/singleton, state might persist.
      // We can use a unique error key for this test.
      final errorKey = 'UniqueError-${DateTime.now().millisecondsSinceEpoch}';

      // _maxExceptionsPerWindow is 3
      expect(
        logger.shouldLog(errorKey),
        isTrue,
        reason: 'First log should pass',
      );
      expect(
        logger.shouldLog(errorKey),
        isTrue,
        reason: 'Second log should pass',
      );
      expect(
        logger.shouldLog(errorKey),
        isTrue,
        reason: 'Third log should pass',
      );

      // Fourth log should be blocked
      expect(
        logger.shouldLog(errorKey),
        isFalse,
        reason: 'Fourth log should be rate limited',
      );
    });

    test('truncateStackTrace reduces stack depth', () {
      final stack = StackTrace.fromString(
        List.generate(20, (i) => '#$i Frame').join('\n'),
      );
      final truncated = logger.truncateStackTrace(stack);
      final lines = truncated.toString().split('\n');
      // _maxStackTraceLines is 5
      expect(
        lines.length,
        lessThanOrEqualTo(6),
      ); // 5 lines + potentially truncation message or newline
    });
  });
}
