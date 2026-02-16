import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';

void main() {
  group('Hover States Mobile Performance', () {
    testWidgets('ThemeAwareCard renders without lag on mobile', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => ThemeAwareCard(
                onTap: () {},
                child: ListTile(title: Text('Card $index')),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1000)),
        reason:
            'Rendering 50 ThemeAwareCard widgets should not cause lag on mobile',
      );
    });

    testWidgets('ThemeAwareCard hover states are optimized on mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Test Card')),
          ),
        ),
      );

      expect(find.byType(ThemeAwareCard), findsOneWidget);
    });

    testWidgets('Multiple ThemeAwareCard widgets perform efficiently', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                20,
                (index) => ThemeAwareCard(
                  onTap: () {},
                  child: ListTile(title: Text('Card $index')),
                ),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'Rendering 20 ThemeAwareCard widgets should complete quickly',
      );
    });

    testWidgets('ThemeAwareCard without onTap has no hover overhead', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) =>
                  ThemeAwareCard(child: ListTile(title: Text('Card $index'))),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1000)),
        reason: 'Non-interactive ThemeAwareCard widgets should render quickly',
      );
    });

    testWidgets('Tap response is immediate regardless of hover state', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(tapped, true, reason: 'Tap callback should be triggered');
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 100)),
        reason: 'Tap response should be immediate',
      );
    });

    testWidgets('Rapid tap sequence performs efficiently', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () => tapCount++,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Tap Me'));
        await tester.pump();
      }
      stopwatch.stop();

      expect(tapCount, 10);
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'Rapid tap sequence should handle efficiently',
      );
    });

    testWidgets('Nested ThemeAwareCard widgets perform efficiently', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ThemeAwareCard(
                onTap: () {},
                child: ThemeAwareCard(
                  onTap: () {},
                  child: ListTile(title: Text('Nested Card $index')),
                ),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1000)),
        reason: 'Nested ThemeAwareCard widgets should perform efficiently',
      );
    });

    testWidgets('ThemeAwareCard rebuilds efficiently on state change', (
      tester,
    ) async {
      int rebuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return ThemeAwareCard(
                  onTap: () => setState(() {}),
                  child: Text('Card (rebuilds: $rebuildCount)'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Card (rebuilds: 1)'));
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        rebuildCount,
        greaterThanOrEqualTo(2),
        reason: 'Should rebuild at least twice',
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 100)),
        reason: 'Rebuild should be efficient',
      );
    });
  });

  group('Platform-Specific Behavior', () {
    testWidgets('InkWell splash works on all platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Test Card')),
          ),
        ),
      );

      await tester.tap(find.text('Test Card'));
      await tester.pump();

      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
