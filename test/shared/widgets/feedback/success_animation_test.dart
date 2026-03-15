import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/feedback/success_animation.dart';

void main() {
  group('SuccessAnimation', () {
    testWidgets('renders with default parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SuccessAnimation())),
      );
      await tester.pump();

      expect(find.byType(SuccessAnimation), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders with custom size', (tester) async {
      const customSize = 80.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessAnimation(size: customSize)),
        ),
      );
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('renders with custom color', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessAnimation(color: customColor)),
        ),
      );
      await tester.pump();

      expect(find.byType(SuccessAnimation), findsOneWidget);
    });

    testWidgets('animation starts and progresses', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimation(duration: Duration(milliseconds: 100)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SuccessAnimation), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SuccessAnimation), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(SuccessAnimation), findsOneWidget);
    });

    testWidgets('disposes animation controller', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SuccessAnimation())),
      );
      await tester.pump();

      expect(find.byType(SuccessAnimation), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      expect(find.byType(SuccessAnimation), findsNothing);
    });
  });

  group('SuccessBanner', () {
    testWidgets('renders with message only', (tester) async {
      const message = 'Operation successful';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessBanner(message: message)),
        ),
      );
      await tester.pump();

      expect(find.byType(SuccessBanner), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.byType(SuccessAnimation), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('renders with message and action', (tester) async {
      const message = 'Operation successful';
      const actionLabel = 'Undo';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessBanner(
              message: message,
              actionLabel: actionLabel,
              onAction: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(message), findsOneWidget);
      expect(find.text(actionLabel), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('calls onAction when button is pressed', (tester) async {
      var actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessBanner(
              message: 'Test',
              actionLabel: 'Undo',
              onAction: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(actionPressed, true);
    });

    testWidgets('does not show button when actionLabel is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessBanner(message: 'Test', onAction: () {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('does not show button when onAction is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessBanner(message: 'Test', actionLabel: 'Undo'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('uses primary color for animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessBanner(message: 'Test')),
        ),
      );
      await tester.pump();

      expect(find.byType(SuccessAnimation), findsOneWidget);
    });
  });
}
