import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/settings/widgets/enhanced_settings_section.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';

void main() {
  testWidgets(
    'EnhancedSettingsSection renders title, description, and children',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedSettingsSection(
              title: 'Section title',
              description: 'Section description',
              icon: Icons.settings,
              children: [
                ListTile(title: Text('Child 1')),
                ListTile(title: Text('Child 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Section title'), findsOneWidget);
      expect(find.text('Section description'), findsOneWidget);
      expect(find.byType(ThemeAwareCard), findsOneWidget);
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    },
  );

  testWidgets('SettingsToggle uses NeumorphicSwitch and calls onChanged', (
    tester,
  ) async {
    bool value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsToggle(
            title: 'Toggle title',
            subtitle: 'Toggle subtitle',
            icon: Icons.security,
            value: value,
            onChanged: (v) {
              value = v ?? false;
            },
          ),
        ),
      ),
    );

    expect(find.text('Toggle title'), findsOneWidget);
    expect(find.text('Toggle subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.security), findsOneWidget);

    final switchFinder = find.byType(NeumorphicSwitch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('SettingsToggle disabled does not call onChanged', (
    tester,
  ) async {
    bool called = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsToggle(
            title: 'Toggle title',
            value: false,
            enabled: false,
            onChanged: (_) => called = true,
          ),
        ),
      ),
    );

    final switchFinder = find.byType(NeumorphicSwitch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(called, isFalse);
  });

  testWidgets('SettingsSelection renders and updates selection', (
    tester,
  ) async {
    String current = 'a';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsSelection<String>(
            title: 'Select title',
            subtitle: 'Select subtitle',
            icon: Icons.palette,
            value: current,
            options: const [
              SettingsOption(label: 'Option A', value: 'a'),
              SettingsOption(label: 'Option B', value: 'b'),
            ],
            onChanged: (v) => current = v ?? current,
          ),
        ),
      ),
    );

    expect(find.text('Select title'), findsOneWidget);
    expect(find.text('Select subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.palette), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Option B').last);
    await tester.pumpAndSettle();
    expect(current, equals('b'));
  });

  testWidgets('SettingsNavigation triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsNavigation(
            title: 'Nav title',
            subtitle: 'Nav subtitle',
            icon: Icons.chevron_right,
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Nav title'), findsOneWidget);
    expect(find.text('Nav subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

    await tester.tap(find.text('Nav title'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
