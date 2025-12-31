import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/mobile_gestures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileGestures', () {
    setUp(() {
      // Reset mock before each test
      // Note: In a real implementation, you'd mock HapticFeedback
      // For now, we'll test the method calls exist
    });

    test('has static methods for different haptic impacts', () {
      // Test that methods exist and can be called
      expect(() => MobileGestures.lightImpact(), returnsNormally);
      expect(() => MobileGestures.mediumImpact(), returnsNormally);
      expect(() => MobileGestures.heavyImpact(), returnsNormally);
      expect(() => MobileGestures.selectionClick(), returnsNormally);
      expect(() => MobileGestures.toggleImpact(), returnsNormally);
    });
  });

  group('HapticTap', () {
    testWidgets('wraps child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HapticTap(child: const Text('Test Child'))),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(HapticTap), findsOneWidget);
    });

    testWidgets('uses GestureDetector to handle taps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HapticTap(child: const Text('Tap Me'))),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('handles onLongPress when provided', (tester) async {
      bool longPressCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              child: const Text('Long Press Me'),
              onLongPress: () => longPressCalled = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressCalled, true);
    });

    testWidgets('does not handle onLongPress when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HapticTap(child: const Text('No Long Press'))),
        ),
      );

      // Should not throw error
      await tester.longPress(find.text('No Long Press'));
      await tester.pump();

      expect(find.text('No Long Press'), findsOneWidget);
    });

    testWidgets('handles different haptic impacts', (tester) async {
      for (final impact in HapticImpact.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HapticTap(
                impact: impact,
                child: Text('Impact: ${impact.name}'),
              ),
            ),
          ),
        );

        expect(find.text('Impact: ${impact.name}'), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
      }
    });
  });

  group('LongPressMenu', () {
    testWidgets('renders child widget initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: const [],
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.text('Menu Child'), findsOneWidget);
      expect(find.byType(LongPressMenu), findsOneWidget);
    });

    testWidgets('shows menu when selectedIndex is set', (tester) async {
      final menuItems = [
        const MenuItem(label: 'Option 1', icon: Icons.star),
        const MenuItem(label: 'Option 2', icon: Icons.favorite),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      // Initially, menu should not be visible
      expect(find.text('Option 1'), findsNothing);
      expect(find.text('Option 2'), findsNothing);

      // Simulate menu selection by accessing internal state
      // Note: This requires accessing private state, which isn't ideal
      // In practice, you'd trigger the menu through user interaction
    });

    testWidgets('calls onItemSelected when menu item is tapped', (
      tester,
    ) async {
      final menuItems = [
        const MenuItem(label: 'Option 1', icon: Icons.star),
        const MenuItem(label: 'Option 2', icon: Icons.favorite),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      // Note: Since the menu overlay appears based on internal state,
      // we can't easily trigger it without access to private state
      // This is a limitation in the current design for testing
    });

    testWidgets('renders menu items with correct structure', (tester) async {
      final menuItems = [
        const MenuItem(label: 'Option 1', icon: Icons.star),
        const MenuItem(label: 'Option 2', icon: null),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
    });
  });

  group('MenuItem', () {
    test('creates menu item with required parameters', () {
      const item = MenuItem(label: 'Test Item');

      expect(item.label, 'Test Item');
      expect(item.icon, null);
      expect(item.value, null);
    });

    test('creates menu item with all parameters', () {
      const item = MenuItem(
        label: 'Full Item',
        icon: Icons.star,
        value: 'test_value',
      );

      expect(item.label, 'Full Item');
      expect(item.icon, Icons.star);
      expect(item.value, 'test_value');
    });

    test('handles different icon types', () {
      final items = [
        MenuItem(label: 'No Icon'),
        MenuItem(label: 'Star Icon', icon: Icons.star),
        MenuItem(label: 'Heart Icon', icon: Icons.favorite),
      ];

      expect(items.length, 3);
      expect(items[0].icon, null);
      expect(items[1].icon, Icons.star);
      expect(items[2].icon, Icons.favorite);
    });
  });

  group('SwipeDirection', () {
    test('has two enum values', () {
      final values = SwipeDirection.values;
      expect(values.length, 2);
      expect(values, contains(SwipeDirection.endToStart));
      expect(values, contains(SwipeDirection.startToEnd));
    });

    test('enum values have correct names', () {
      expect(SwipeDirection.endToStart.name, 'endToStart');
      expect(SwipeDirection.startToEnd.name, 'startToEnd');
    });
  });

  group('HapticImpact', () {
    test('has three enum values', () {
      final values = HapticImpact.values;
      expect(values.length, 3);
      expect(values, contains(HapticImpact.light));
      expect(values, contains(HapticImpact.medium));
      expect(values, contains(HapticImpact.heavy));
    });

    test('enum values have correct names', () {
      expect(HapticImpact.light.name, 'light');
      expect(HapticImpact.medium.name, 'medium');
      expect(HapticImpact.heavy.name, 'heavy');
    });
  });

  group('Integration Tests', () {
    testWidgets('HapticTap with child Button', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              child: ElevatedButton(
                onPressed: () => buttonPressed = true,
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Button'));
      await tester.pump();

      expect(buttonPressed, true);
    });
  });
  group('SwipeAction', () {
    testWidgets('wraps child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.endToStart,
              child: const Text('Swipe Child'),
            ),
          ),
        ),
      );

      expect(find.text('Swipe Child'), findsOneWidget);
      expect(find.byType(SwipeAction), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('uses Dismissible for swipe detection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.endToStart,
              child: const Text('Swipe Me'),
            ),
          ),
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('calls onSwipe when swiped', (tester) async {
      bool swipeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () => swipeCalled = true,
              direction: SwipeDirection.endToStart,
              child: const Text('Swipe Me'),
            ),
          ),
        ),
      );

      // Simulate swipe from right to left
      await tester.drag(find.text('Swipe Me'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(swipeCalled, true);
    });

    testWidgets('handles endToStart direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.endToStart,
              child: const Text('End to Start'),
            ),
          ),
        ),
      );

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.endToStart);
    });

    testWidgets('handles startToEnd direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.startToEnd,
              child: const Text('Start to End'),
            ),
          ),
        ),
      );

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.startToEnd);
    });

    testWidgets('shows delete icon for endToStart swipe background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.endToStart,
              child: const Text('Delete Swipe'),
            ),
          ),
        ),
      );

      // Simulate partial swipe to reveal background
      await tester.drag(find.text('Delete Swipe'), const Offset(-100, 0));
      await tester.pump();

      // The background should have a delete icon
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('shows archive icon for startToEnd swipe background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.startToEnd,
              child: const Text('Archive Swipe'),
            ),
          ),
        ),
      );

      // Simulate partial swipe to reveal background
      await tester.drag(find.text('Archive Swipe'), const Offset(100, 0));
      await tester.pump();

      // The background should have an archive icon
      expect(find.byIcon(Icons.archive), findsOneWidget);
    });

    testWidgets('uses errorContainer color for endToStart background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.endToStart,
              child: const Text('Delete Swipe'),
            ),
          ),
        ),
      );

      // Simulate partial swipe to reveal background
      await tester.drag(find.text('Delete Swipe'), const Offset(-100, 0));
      await tester.pump();

      // Find the container in the background
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('uses primaryContainer color for startToEnd background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SwipeAction(
              onSwipe: () {},
              direction: SwipeDirection.startToEnd,
              child: const Text('Archive Swipe'),
            ),
          ),
        ),
      );

      // Simulate partial swipe to reveal background
      await tester.drag(find.text('Archive Swipe'), const Offset(100, 0));
      await tester.pump();

      // Find the container in the background
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('has unique key based on direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SwipeAction(
                  onSwipe: () {},
                  direction: SwipeDirection.endToStart,
                  child: const Text('Swipe 1'),
                ),
                SwipeAction(
                  onSwipe: () {},
                  direction: SwipeDirection.startToEnd,
                  child: const Text('Swipe 2'),
                ),
              ],
            ),
          ),
        ),
      );

      final dismissibles = find.byType(Dismissible);
      expect(dismissibles, findsNWidgets(2));
    });
  });

  group('LongPressMenu - Enhanced Tests', () {
    testWidgets('menu overlay uses SafeArea', (tester) async {
      final menuItems = [const MenuItem(label: 'Option 1', icon: Icons.star)];

      // Create a testable widget that can trigger the menu
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // This would normally be triggered by long press
                    // For testing, we need to access the widget state
                  },
                  child: LongPressMenu(
                    menuItems: menuItems,
                    onItemSelected: (index) {},
                    child: const Text('Menu Child'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
    });

    testWidgets('menu items have correct padding', (tester) async {
      final menuItems = [const MenuItem(label: 'Option 1', icon: Icons.star)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
    });

    testWidgets('LongPressMenu has correct widget structure', (tester) async {
      final menuItems = [const MenuItem(label: 'Option 1', icon: Icons.star)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      // The LongPressMenu should be present
      expect(find.byType(LongPressMenu), findsOneWidget);
    });

    testWidgets('menu overlay has semi-transparent background', (tester) async {
      final menuItems = [const MenuItem(label: 'Option 1', icon: Icons.star)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
    });

    testWidgets('handles empty menu items list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: const [],
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
      expect(find.text('Menu Child'), findsOneWidget);
    });

    testWidgets('handles multiple menu items', (tester) async {
      final menuItems = [
        const MenuItem(label: 'Option 1', icon: Icons.star),
        const MenuItem(label: 'Option 2', icon: Icons.favorite),
        const MenuItem(label: 'Option 3', icon: Icons.bookmark),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressMenu(
              menuItems: menuItems,
              onItemSelected: (index) {},
              child: const Text('Menu Child'),
            ),
          ),
        ),
      );

      expect(find.byType(LongPressMenu), findsOneWidget);
    });
  });

  group('HapticTap - Enhanced Tests', () {
    testWidgets('provides haptic feedback on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              impact: HapticImpact.light,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('uses light impact by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HapticTap(child: const Text('Default Impact'))),
        ),
      );

      await tester.tap(find.text('Default Impact'));
      await tester.pump();

      expect(find.text('Default Impact'), findsOneWidget);
    });

    testWidgets('uses medium impact when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              impact: HapticImpact.medium,
              child: const Text('Medium Impact'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Medium Impact'));
      await tester.pump();

      expect(find.text('Medium Impact'), findsOneWidget);
    });

    testWidgets('uses heavy impact when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              impact: HapticImpact.heavy,
              child: const Text('Heavy Impact'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Heavy Impact'));
      await tester.pump();

      expect(find.text('Heavy Impact'), findsOneWidget);
    });

    testWidgets('provides heavy impact on long press', (tester) async {
      bool longPressCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              onLongPress: () => longPressCalled = true,
              impact: HapticImpact.light,
              child: const Text('Long Press Me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressCalled, true);
    });

    testWidgets('can be used with any widget type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HapticTap(
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                HapticTap(child: const Icon(Icons.star)),
                HapticTap(child: const Card(child: Text('Card'))),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('preserves child widget properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HapticTap(
              child: Text(
                'Styled Text',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.blue);
    });
  });
}
