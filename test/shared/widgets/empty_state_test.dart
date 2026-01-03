import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            subtitle: 'Add some items to get started',
            actionLabel: 'Add Item',
            onAction: () {},
          ),
        ),
      ),
    );

    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Add some items to get started'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });

  testWidgets('EmptyState triggers action callback', (tester) async {
    bool actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            actionLabel: 'Add Item',
            onAction: () => actionPressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add Item'));
    expect(actionPressed, isTrue);
  });

  testWidgets('EmptyState renders custom action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            action: Text('Custom Action'),
          ),
        ),
      ),
    );

    expect(find.text('Custom Action'), findsOneWidget);
  });

  testWidgets('EmptyState renders custom illustration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            illustration: Text('Custom Illustration'),
          ),
        ),
      ),
    );

    expect(find.text('Custom Illustration'), findsOneWidget);
  });
}
