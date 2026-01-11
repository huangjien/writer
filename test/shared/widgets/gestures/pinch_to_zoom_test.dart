import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/gestures/pinch_to_zoom.dart';

void main() {
  group('PinchToZoom', () {
    testWidgets('renders child widget when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PinchToZoom(child: const Text('Test Child'))),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(PinchToZoom), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('renders child widget directly when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(enabled: false, child: Text('Test Child')),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(PinchToZoom), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('uses InteractiveViewer with default parameters', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PinchToZoom(child: const Text('Test Child'))),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.minScale, 1.0);
      expect(viewer.maxScale, 4.0);
    });

    testWidgets('uses custom minScale parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(minScale: 0.5, child: Text('Test Child')),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.minScale, 0.5);
    });

    testWidgets('uses custom maxScale parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(maxScale: 8.0, child: Text('Test Child')),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.maxScale, 8.0);
    });

    testWidgets('uses custom boundaryMargin parameter', (tester) async {
      const customMargin = EdgeInsets.all(48);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(
              boundaryMargin: customMargin,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.boundaryMargin, customMargin);
    });

    testWidgets('wraps any widget type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(
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
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('wraps Image widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(
              child: Image.network(
                'https://example.com/image.jpg',
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error loading image');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('handles multiple PinchToZoom widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PinchToZoom(
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                PinchToZoom(
                  child: Container(width: 100, height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PinchToZoom), findsNWidgets(2));
      expect(find.byType(InteractiveViewer), findsNWidgets(2));
    });

    testWidgets('enabled parameter can be toggled', (tester) async {
      bool enabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(
              enabled: enabled,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Rebuild with enabled = false
      enabled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(
              enabled: enabled,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('preserves child widget properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(
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

    testWidgets('handles asymmetric boundary margin', (tester) async {
      const asymmetricMargin = EdgeInsets.fromLTRB(10, 20, 30, 40);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(
              boundaryMargin: asymmetricMargin,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.boundaryMargin, asymmetricMargin);
    });

    testWidgets('supports zero boundary margin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(
              boundaryMargin: EdgeInsets.zero,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.boundaryMargin, EdgeInsets.zero);
    });

    testWidgets('handles minScale equal to maxScale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const PinchToZoom(
              minScale: 2.0,
              maxScale: 2.0,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.minScale, 2.0);
      expect(viewer.maxScale, 2.0);
    });
  });

  group('PinchToZoom.showNetworkImage', () {
    test('showNetworkImage is a static method', () {
      // Verify the method exists by checking it's a function
      expect(PinchToZoom.showNetworkImage, isA<Function>());
    });
  });

  group('PinchToZoom Integration', () {
    testWidgets('works with Navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchToZoom(child: const Text('Navigable Child')),
          ),
        ),
      );

      expect(find.text('Navigable Child'), findsOneWidget);
    });

    testWidgets('works inside ListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                PinchToZoom(child: Container(height: 200, color: Colors.red)),
                PinchToZoom(child: Container(height: 200, color: Colors.blue)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PinchToZoom), findsNWidgets(2));
      expect(find.byType(InteractiveViewer), findsNWidgets(2));
    });

    testWidgets('works inside Stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                PinchToZoom(
                  child: Container(width: 200, height: 200, color: Colors.red),
                ),
                const Positioned(top: 10, left: 10, child: Text('Overlay')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PinchToZoom), findsOneWidget);
      expect(find.text('Overlay'), findsOneWidget);
    });
  });
}
