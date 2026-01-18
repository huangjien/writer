import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/enhanced_card.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';

void main() {
  testWidgets('EnhancedCard uses ThemeAwareCard when elevated and no border', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EnhancedCard(elevation: 2, child: Text('Content')),
        ),
      ),
    );

    expect(find.byType(ThemeAwareCard), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('EnhancedCard uses InkWell when onTap is provided', (
    tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedCard(
            elevation: 2,
            onTap: () => tapped = true,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    expect(find.byType(ThemeAwareCard), findsOneWidget);
    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('EnhancedCard falls back when border is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedCard(
            elevation: 2,
            border: Border.all(width: 1),
            child: const Text('Content'),
          ),
        ),
      ),
    );

    expect(find.byType(ThemeAwareCard), findsNothing);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('EnhancedCard border fallback still supports onTap', (
    tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedCard(
            elevation: 2,
            border: Border.all(width: 1),
            onTap: () => tapped = true,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('EnhancedCard falls back when elevation is zero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EnhancedCard(elevation: 0, child: Text('Content')),
        ),
      ),
    );

    expect(find.byType(ThemeAwareCard), findsNothing);
    expect(find.text('Content'), findsOneWidget);
  });
}
