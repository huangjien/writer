import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlobalShortcutsWrapper', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Test'))),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('works with nested widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: Column(children: [Text('First'), Text('Second')]),
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('supports Focus widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(body: Focus(child: Text('Focused'))),
          ),
        ),
      );

      expect(find.text('Focused'), findsOneWidget);
    });

    testWidgets('preserves theme context', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const GlobalShortcutsWrapper(
            child: Scaffold(body: Text('Themed')),
          ),
        ),
      );

      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('handles multiple children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: Row(children: [Text('A'), Text('B'), Text('C')]),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('works with stateful widgets', (tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        counter++;
                      });
                    },
                    child: Text('Count: $counter'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Count: 0'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('can be used multiple times', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlobalShortcutsWrapper(child: Text('Wrapper 1')),
                GlobalShortcutsWrapper(child: Text('Wrapper 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Wrapper 1'), findsOneWidget);
      expect(find.text('Wrapper 2'), findsOneWidget);
    });

    testWidgets('works with Navigator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Home'))),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
