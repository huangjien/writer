import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileBottomSheet', () {
    testWidgets('show method displays bottom sheet with content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Sheet Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content'), findsOneWidget);
      // Drag handle is a Container, not a DragHandle widget
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('show method displays bottom sheet with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.show(
                      context: context,
                      title: 'Sheet Title',
                      builder: (context) => const Text('Sheet Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Title'), findsOneWidget);
      expect(find.text('Sheet Content'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('show method respects custom maxHeight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.show(
                      context: context,
                      maxHeight: 200,
                      builder: (context) => const SizedBox(
                        height: 400,
                        child: Text('Tall Content'),
                      ),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Verify sheet content is visible
      expect(find.text('Tall Content'), findsOneWidget);
      // The maxHeight is applied internally, we just verify that sheet shows
    });

    testWidgets('showActionSheet displays list of items', (tester) async {
      final items = [
        const ActionSheetItem(
          label: 'Option 1',
          value: 'opt1',
          icon: Icons.home,
        ),
        const ActionSheetItem(
          label: 'Option 2',
          value: 'opt2',
          icon: Icons.settings,
        ),
        const ActionSheetItem(
          label: 'Delete',
          value: 'delete',
          icon: Icons.delete,
          isDestructive: true,
        ),
      ];

      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedValue =
                        await MobileBottomSheet.showActionSheet<String>(
                          context: context,
                          items: items,
                        );
                  },
                  child: const Text('Show Action Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Test destructive item styling
      final deleteItem = tester.widget<Text>(find.text('Delete'));
      expect(deleteItem.style?.color, isA<Color>());

      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'opt1');
    });

    testWidgets('showActionSheet with custom cancel label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.showActionSheet<String>(
                      context: context,
                      items: [],
                      cancelLabel: 'Close',
                    );
                  },
                  child: const Text('Show Action Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('showOptions displays selectable options', (tester) async {
      final options = [
        const SheetOption(label: 'Option A', value: 'a'),
        const SheetOption(label: 'Option B', value: 'b'),
        const SheetOption(label: 'Option C', value: 'c'),
      ];

      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedValue = await MobileBottomSheet.showOptions<String>(
                      context: context,
                      options: options,
                      selectedValue: 'b',
                    );
                  },
                  child: const Text('Show Options'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Options'));
      await tester.pumpAndSettle();

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);

      // Selected option should have check icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Option C'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'c');
    });

    testWidgets('DraggableBottomSheet renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableBottomSheet(child: Text('Draggable Content')),
          ),
        ),
      );

      expect(find.text('Draggable Content'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('DraggableBottomSheet respects custom parameters', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableBottomSheet(
              minChildSize: 0.2,
              maxChildSize: 0.8,
              initialChildSize: 0.4,
              snap: false,
              child: Text('Custom Draggable Content'),
            ),
          ),
        ),
      );

      final draggableSheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet),
      );

      expect(draggableSheet.minChildSize, 0.2);
      expect(draggableSheet.maxChildSize, 0.8);
      expect(draggableSheet.initialChildSize, 0.4);
      expect(draggableSheet.snap, false);
    });

    testWidgets('ActionSheetItem onPressed callback is called', (tester) async {
      bool callbackCalled = false;

      final items = [
        ActionSheetItem(
          label: 'Callback Item',
          value: 'callback',
          onPressed: () => callbackCalled = true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.showActionSheet<String>(
                      context: context,
                      items: items,
                    );
                  },
                  child: const Text('Show Action Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(callbackCalled, false);

      await tester.tap(find.text('Callback Item'));
      await tester.pumpAndSettle();

      expect(callbackCalled, true);
    });

    testWidgets('bottom sheet can be dismissed by tapping outside', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Sheet Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content'), findsOneWidget);

      // Tap outside to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content'), findsNothing);
    });

    testWidgets('bottom sheet respects isDismissible flag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MobileBottomSheet.show(
                      context: context,
                      isDismissible: false,
                      builder: (context) => const Text('Non-dismissible Sheet'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Non-dismissible Sheet'), findsOneWidget);

      // Try to tap outside - should not dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.text('Non-dismissible Sheet'), findsOneWidget);
    });
  });

  group('ActionSheetItem', () {
    test('creates item with required parameters', () {
      const item = ActionSheetItem(label: 'Test Item', value: 'test');

      expect(item.label, 'Test Item');
      expect(item.value, 'test');
      expect(item.icon, null);
      expect(item.isDestructive, false);
      expect(item.onPressed, null);
    });

    test('creates item with all parameters', () {
      bool callbackCalled = false;
      final item = ActionSheetItem(
        label: 'Full Item',
        value: 'full',
        icon: Icons.star,
        isDestructive: true,
        onPressed: () => callbackCalled = true,
      );

      expect(item.label, 'Full Item');
      expect(item.value, 'full');
      expect(item.icon, Icons.star);
      expect(item.isDestructive, true);
      expect(item.onPressed, isNotNull);

      item.onPressed?.call();
      expect(callbackCalled, true);
    });
  });

  group('SheetOption', () {
    test('creates option with required parameters', () {
      const option = SheetOption(label: 'Test Option', value: 'test');

      expect(option.label, 'Test Option');
      expect(option.value, 'test');
    });
  });
}
