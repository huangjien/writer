import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardShortcutsDialog', () {
    testWidgets('showKeyboardShortcutsDialog can be invoked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showKeyboardShortcutsDialog(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      expect(dialog, findsOneWidget);
    });

    testWidgets('showKeyboardShortcutsSheet can be invoked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showKeyboardShortcutsSheet(context),
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      final bottomSheet = find.byType(BottomSheet);
      expect(bottomSheet, findsOneWidget);
    });

    testWidgets('keyboard shortcut help includes sidebar shortcuts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showKeyboardShortcutsDialog(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Toggle Left Sidebar'), findsOneWidget);
      expect(find.text('Toggle AI Sidebar'), findsOneWidget);
    });

    test('appendShortcutToTooltip combines text', () {
      final result = appendShortcutToTooltip('Save', 'Ctrl+S');
      expect(result, 'Save (Ctrl+S)');
    });

    testWidgets('ShortcutKey displays modifier key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShortcutKey('Ctrl'))),
      );

      expect(find.text('Ctrl'), findsOneWidget);
    });

    testWidgets('ShortcutKey displays regular key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShortcutKey('S'))),
      );

      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('ShortcutKeys renders multiple keys', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShortcutKeys(keys: ['Ctrl', 'S'])),
        ),
      );

      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('ShortcutKeys with multiple modifiers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShortcutKeys(keys: ['Ctrl', 'Shift', 'S'])),
        ),
      );

      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('ShortcutKeys with single key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShortcutKeys(keys: ['S'])),
        ),
      );

      expect(find.text('S'), findsOneWidget);
      expect(find.text('+'), findsNothing);
    });
  });
}
