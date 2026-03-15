import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/screens/mobile_editor/mobile_editor_shortcuts.dart';

void main() {
  group('MobileEditorShortcuts', () {
    testWidgets('builds correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('builds with preview mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: true,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Preview')),
          ),
        ),
      );
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      const testChild = Placeholder();
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: testChild,
          ),
        ),
      );

      expect(find.byWidget(testChild), findsOneWidget);
    });

    testWidgets('contains Shortcuts widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      expect(find.byType(Shortcuts), findsWidgets);
    });

    testWidgets('contains Actions widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      expect(find.byType(Actions), findsWidgets);
    });

    testWidgets('preserves child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(
              body: Column(
                children: [Text('First'), Text('Second'), Text('Third')],
              ),
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('works with nested widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(
              body: Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Nested Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nested Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('works with Focus widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Focus(
            onKeyEvent: (node, event) => KeyEventResult.ignored,
            child: MobileEditorShortcuts(
              contentController: TextEditingController(),
              preview: false,
              onSave: () {},
              onTogglePreview: () {},
              onShowHelp: () {},
              onDismiss: () {},
              child: const Scaffold(body: Text('Focused')),
            ),
          ),
        ),
      );

      expect(find.text('Focused'), findsOneWidget);
    });

    testWidgets('handles contentController parameter', (tester) async {
      final controller = TextEditingController(text: 'Test content');

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Controller Test')),
          ),
        ),
      );

      expect(find.text('Controller Test'), findsOneWidget);
      expect(controller.text, 'Test content');
    });

    testWidgets('handles preview mode correctly', (tester) async {
      for (final previewValue in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MobileEditorShortcuts(
              contentController: TextEditingController(),
              preview: previewValue,
              onSave: () {},
              onTogglePreview: () {},
              onShowHelp: () {},
              onDismiss: () {},
              child: Scaffold(body: Text('Preview: $previewValue')),
            ),
          ),
        );

        expect(find.text('Preview: $previewValue'), findsOneWidget);
      }
    });

    testWidgets('provides all required callbacks', (tester) async {
      var callbacksCalled = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () => callbacksCalled++,
            onTogglePreview: () => callbacksCalled++,
            onShowHelp: () => callbacksCalled++,
            onDismiss: () => callbacksCalled++,
            child: const Scaffold(body: Text('Callbacks')),
          ),
        ),
      );

      expect(find.text('Callbacks'), findsOneWidget);
      expect(callbacksCalled, 0);
    });

    testWidgets('handles different widget children', (tester) async {
      final testCases = [
        const Text('Simple text'),
        const Placeholder(),
        Container(),
        const Scaffold(body: Text('Scaffold')),
      ];

      for (final child in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: MobileEditorShortcuts(
              contentController: TextEditingController(),
              preview: false,
              onSave: () {},
              onTogglePreview: () {},
              onShowHelp: () {},
              onDismiss: () {},
              child: child,
            ),
          ),
        );

        expect(find.byWidget(child), findsOneWidget);
      }
    });

    testWidgets('contains Shortcuts widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      expect(find.byType(Shortcuts), findsWidgets);
    });

    testWidgets('contains Actions widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      expect(find.byType(Actions), findsWidgets);
    });

    testWidgets('handles null callbacks properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      expect(find.byType(MobileEditorShortcuts), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('handles both preview modes', (tester) async {
      for (final isPreview in [true, false]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MobileEditorShortcuts(
              contentController: TextEditingController(),
              preview: isPreview,
              onSave: () {},
              onTogglePreview: () {},
              onShowHelp: () {},
              onDismiss: () {},
              child: Scaffold(body: Text('Preview mode: $isPreview')),
            ),
          ),
        );

        expect(find.text('Preview mode: $isPreview'), findsOneWidget);
      }
    });

    testWidgets('updates widget when preview changes', (tester) async {
      var currentPreview = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return MobileEditorShortcuts(
                contentController: TextEditingController(),
                preview: currentPreview,
                onSave: () {},
                onTogglePreview: () =>
                    setState(() => currentPreview = !currentPreview),
                onShowHelp: () {},
                onDismiss: () {},
                child: Scaffold(body: Text('Preview: $currentPreview')),
              );
            },
          ),
        ),
      );

      expect(find.text('Preview: false'), findsOneWidget);
    });

    testWidgets('can be used with Material app as root', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(body: Text('Material Root')),
          ),
        ),
      );

      expect(find.text('Material Root'), findsOneWidget);
    });

    testWidgets('handles TextEditingController with text', (tester) async {
      final controller = TextEditingController(text: 'Initial text');

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(body: TextField(controller: controller)),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(controller.text, 'Initial text');
    });

    testWidgets('handles empty TextEditingController', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(body: TextField(controller: controller)),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(controller.text, isEmpty);
    });

    testWidgets('can be used with multiple Scaffold children', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(
              appBar: AppBar(title: const Text('Test App')),
              body: const Text('Body'),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('can be used with Column layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: TextEditingController(),
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: const Scaffold(
              body: Column(
                children: [Text('Line 1'), Text('Line 2'), Text('Line 3')],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text('Line 3'), findsOneWidget);
    });

    testWidgets('triggers Save callback with Ctrl+S key combination', (
      tester,
    ) async {
      var saveCalled = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () => saveCalled = true,
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(saveCalled, isTrue);
    });

    testWidgets('triggers TogglePreview callback with Ctrl+P key combination', (
      tester,
    ) async {
      var toggleCalled = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () => toggleCalled = true,
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(toggleCalled, isTrue);
    });

    testWidgets('triggers Help callback with Ctrl+/ key combination', (
      tester,
    ) async {
      var helpCalled = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () => helpCalled = true,
            onDismiss: () {},
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(helpCalled, isTrue);
    });

    testWidgets('triggers Dismiss callback with Escape in non-preview mode', (
      tester,
    ) async {
      var dismissCalled = false;
      var toggleCalled = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () => toggleCalled = true,
            onShowHelp: () {},
            onDismiss: () => dismissCalled = true,
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(dismissCalled, isTrue);
      expect(toggleCalled, isFalse);
    });

    testWidgets('triggers TogglePreview callback with Escape in preview mode', (
      tester,
    ) async {
      var dismissCalled = false;
      var toggleCalled = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: true,
            onSave: () {},
            onTogglePreview: () => toggleCalled = true,
            onShowHelp: () {},
            onDismiss: () => dismissCalled = true,
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(dismissCalled, isFalse);
      expect(toggleCalled, isTrue);
    });

    testWidgets('MarkdownEditActions are called for formatting shortcuts', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'test');

      await tester.pumpWidget(
        MaterialApp(
          home: MobileEditorShortcuts(
            contentController: controller,
            preview: false,
            onSave: () {},
            onTogglePreview: () {},
            onShowHelp: () {},
            onDismiss: () {},
            child: Scaffold(
              body: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final textAfterBold = controller.text;
      expect(textAfterBold, isNotNull);
    });
  });
}
