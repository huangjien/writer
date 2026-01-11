import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/loading/shimmer_skeleton.dart';

void main() {
  group('ShimmerSkeleton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('uses default enabled value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      final shimmerSkeleton = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmerSkeleton.enabled, true);
    });

    testWidgets('uses custom enabled value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ShimmerSkeleton(
              enabled: false,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final shimmerSkeleton = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmerSkeleton.enabled, false);
    });

    testWidgets('uses default duration value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      final shimmerSkeleton = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmerSkeleton.duration, const Duration(milliseconds: 1500));
    });

    testWidgets('uses custom duration value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ShimmerSkeleton(
              duration: Duration(milliseconds: 2000),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final shimmerSkeleton = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmerSkeleton.duration, const Duration(milliseconds: 2000));
    });

    testWidgets('wraps any widget type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Container Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Container Child'), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('wraps Icon widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ShimmerSkeleton(child: const Icon(Icons.star))),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('handles multiple ShimmerSkeleton widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShimmerSkeleton(
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                ShimmerSkeleton(
                  child: Container(width: 100, height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsNWidgets(2));
    });

    testWidgets('enabled parameter can be toggled', (tester) async {
      bool enabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              enabled: enabled,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);

      // Rebuild with enabled = false
      enabled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              enabled: enabled,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      final shimmerSkeleton = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmerSkeleton.enabled, false);
    });

    testWidgets('preserves child widget properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              child: Text(
                'Styled Text',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.purple);
    });

    testWidgets('works inside ListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ShimmerSkeleton(
                  child: Container(height: 100, color: Colors.red),
                ),
                ShimmerSkeleton(
                  child: Container(height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsNWidgets(2));
    });

    testWidgets('works inside Stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ShimmerSkeleton(
                  child: Container(width: 200, height: 200, color: Colors.red),
                ),
                const Positioned(top: 10, left: 10, child: Text('Overlay')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('with custom key', (tester) async {
      const key = Key('custom_shimmer_skeleton');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(key: key, child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('wraps CircleAvatar widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              child: const CircleAvatar(radius: 30, child: Text('AB')),
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('wraps Column widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              child: Column(
                children: const [
                  Text('Line 1'),
                  Text('Line 2'),
                  Text('Line 3'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text('Line 3'), findsOneWidget);
    });
  });

  group('ShimmerSkeleton Theme Integration', () {
    testWidgets('adapts to light theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('adapts to dark theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('works with custom theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });
  });

  group('ShimmerSkeleton Integration', () {
    testWidgets('works with Navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(child: const Text('Navigable Child')),
          ),
        ),
      );

      expect(find.text('Navigable Child'), findsOneWidget);
    });

    testWidgets('works inside Card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(child: ShimmerSkeleton(child: const Text('Card Child'))),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(find.text('Card Child'), findsOneWidget);
    });

    testWidgets('works inside ListTile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              title: ShimmerSkeleton(child: const Text('ListTile Title')),
              subtitle: ShimmerSkeleton(child: const Text('ListTile Subtitle')),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsNWidgets(2));
    });

    testWidgets('works inside Row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ShimmerSkeleton(child: const Text('Item 1')),
                ShimmerSkeleton(child: const Text('Item 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsNWidgets(2));
    });

    testWidgets('works with nested widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerSkeleton(
              child: Column(
                children: [
                  Container(width: 100, height: 50, color: Colors.red),
                  const Text('Nested Text'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Nested Text'), findsOneWidget);
    });
  });
}
