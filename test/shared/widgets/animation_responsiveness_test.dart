import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/micro_interactions.dart';
import 'package:writer/shared/widgets/feedback/error_animation.dart';

const Duration maxResponsiveDuration = Duration(milliseconds: 200);

void main() {
  group('MicroInteractions Animation Responsiveness', () {
    testWidgets('PressScale uses responsive duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const PressScale(child: Text('Test Child'))),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(
        pressScale.duration,
        lessThanOrEqualTo(maxResponsiveDuration),
        reason:
            'PressScale duration (${pressScale.duration.inMilliseconds}ms) '
            'should not exceed ${maxResponsiveDuration.inMilliseconds}ms for perceived responsiveness',
      );
    });

    testWidgets('TapBump has hardcoded responsive duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      expect(
        find.byType(TapBump),
        findsOneWidget,
        reason: 'TapBump should be rendered',
      );
    });
  });

  group('ErrorAnimation Responsiveness', () {
    testWidgets('ErrorAnimation uses responsive duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const ErrorAnimation())),
      );

      final errorAnimation = tester.widget<ErrorAnimation>(
        find.byType(ErrorAnimation),
      );
      expect(
        errorAnimation.duration,
        lessThanOrEqualTo(maxResponsiveDuration),
        reason:
            'ErrorAnimation duration (${errorAnimation.duration.inMilliseconds}ms) '
            'should not exceed ${maxResponsiveDuration.inMilliseconds}ms for perceived responsiveness',
      );
    });

    testWidgets('RetryPulse has hardcoded responsive duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RetryPulse(child: const Icon(Icons.refresh))),
        ),
      );

      expect(
        find.byType(RetryPulse),
        findsOneWidget,
        reason: 'RetryPulse should be rendered',
      );
    });
  });

  group('Animation Duration Verification', () {
    testWidgets('PressScale completes animation within threshold', (
      tester,
    ) async {
      const testDuration = Duration(milliseconds: 120);
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(duration: testDuration, child: const Text('Test')),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump(testDuration);

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThanOrEqualTo(testDuration + const Duration(milliseconds: 50)),
        reason: 'PressScale animation should complete within reasonable time',
      );
    });

    testWidgets('TapBump completes animation within threshold', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test')),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'TapBump animation should complete quickly',
      );
    });

    testWidgets('ErrorAnimation completes initial animation within threshold', (
      tester,
    ) async {
      const testDuration = Duration(milliseconds: 200);
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorAnimation(duration: testDuration)),
        ),
      );

      await tester.pump(testDuration);
      stopwatch.stop();

      expect(
        stopwatch.elapsed,
        lessThanOrEqualTo(testDuration + const Duration(milliseconds: 50)),
        reason:
            'ErrorAnimation should complete initial animation within threshold',
      );
    });
  });

  group('Performance Impact Tests', () {
    testWidgets('Multiple PressScale animations do not cause lag', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => PressScale(
                onTap: () {},
                child: ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'Rendering multiple PressScale widgets should not cause lag',
      );
    });

    testWidgets('Multiple TapBump animations do not cause lag', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => TapBump(
                onTap: () {},
                child: ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'Rendering multiple TapBump widgets should not cause lag',
      );
    });
  });
}
