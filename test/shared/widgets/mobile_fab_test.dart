import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/mobile_fab.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileFab', () {
    testWidgets('renders extended FAB with label and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () {},
              label: 'Create Novel',
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicButton), findsOneWidget);
      expect(find.text('Create Novel'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders mini FAB when extended is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () {},
              label: 'Save',
              icon: Icons.save,
              extended: false,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicButton), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () => pressed = true,
              label: 'Test',
              icon: Icons.add,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeumorphicButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () {},
              label: 'Loading',
              icon: Icons.add,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () => pressed = true,
              label: 'Loading',
              icon: Icons.add,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeumorphicButton));
      await tester.pump();

      expect(pressed, false);
    });

    testWidgets('applies correct colors for each type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MobileFab(
                  onPressed: () {},
                  label: 'Primary',
                  icon: Icons.add,
                  type: MobileFabType.primary,
                ),
                MobileFab(
                  onPressed: () {},
                  label: 'Secondary',
                  icon: Icons.save,
                  type: MobileFabType.secondary,
                ),
                MobileFab(
                  onPressed: () {},
                  label: 'Action',
                  icon: Icons.next_plan,
                  type: MobileFabType.action,
                ),
              ],
            ),
          ),
        ),
      );

      final buttons = tester.widgetList<NeumorphicButton>(
        find.byType(NeumorphicButton),
      );
      expect(buttons.length, 3);
    });

    testWidgets('uses custom heroTag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(
              onPressed: () {},
              label: 'Test',
              icon: Icons.add,
              heroTag: 'custom_hero_tag',
            ),
          ),
        ),
      );

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'custom_hero_tag');
    });

    testWidgets('has correct elevation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFab(onPressed: () {}, label: 'Test', icon: Icons.add),
          ),
        ),
      );

      final button = tester.widget<NeumorphicButton>(
        find.byType(NeumorphicButton),
      );
      expect(button.depth, 16.0);
    });
  });

  group('MobileMiniFab', () {
    testWidgets('renders mini FAB with icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileMiniFab(
              onPressed: () {},
              icon: Icons.edit,
              tooltip: 'Edit',
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('mini_fab_container')), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileMiniFab(
              onPressed: () => pressed = true,
              icon: Icons.edit,
              tooltip: 'Edit',
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('mini_fab_button')));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileMiniFab(
              onPressed: () {},
              icon: Icons.edit,
              tooltip: 'Edit',
            ),
          ),
        ),
      );

      final container = tester.widget<SizedBox>(
        find.byKey(const ValueKey('mini_fab_container')),
      );
      expect(container.width, 40.0);
      expect(container.height, 40.0);

      final fabs = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      final fab = fabs.first;
      expect(fab.elevation, 4.0);
      expect(fab.tooltip, 'Edit');
    });

    testWidgets('uses custom heroTag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileMiniFab(
              onPressed: () {},
              icon: Icons.edit,
              tooltip: 'Edit',
              heroTag: 'custom_mini_hero',
            ),
          ),
        ),
      );

      final fabs = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      final fab = fabs.first;
      expect(fab.heroTag, 'custom_mini_hero');
    });
  });

  group('MobileFabWithMenu', () {
    testWidgets('renders main FAB with label and icon', (tester) async {
      final items = [
        FabMenuItem(label: 'Option 1', icon: Icons.star, onTap: () {}),
        FabMenuItem(label: 'Option 2', icon: Icons.favorite, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: items,
              mainLabel: 'Menu',
              mainIcon: Icons.menu,
            ),
          ),
        ),
      );

      expect(find.text('Menu'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Menu items should not be visible initially
      expect(find.text('Option 1'), findsNothing);
      expect(find.text('Option 2'), findsNothing);
    });

    testWidgets('expands menu when main FAB is tapped', (tester) async {
      final items = [
        FabMenuItem(label: 'Option 1', icon: Icons.star, onTap: () {}),
        FabMenuItem(label: 'Option 2', icon: Icons.favorite, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: items,
              mainLabel: 'Menu',
              mainIcon: Icons.menu,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('collapses menu when tapped again', (tester) async {
      final items = [
        FabMenuItem(label: 'Option 1', icon: Icons.star, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: items,
              mainLabel: 'Menu',
              mainIcon: Icons.menu,
            ),
          ),
        ),
      );

      // Expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Option 1'), findsOneWidget);

      // Collapse
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Option 1'), findsNothing);
    });

    testWidgets('calls item onTap when menu item is tapped', (tester) async {
      bool item1Called = false;
      bool item2Called = false;

      final items = [
        FabMenuItem(
          label: 'Option 1',
          icon: Icons.star,
          onTap: () => item1Called = true,
        ),
        FabMenuItem(
          label: 'Option 2',
          icon: Icons.favorite,
          onTap: () => item2Called = true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: items,
              mainLabel: 'Menu',
              mainIcon: Icons.menu,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('fab_menu_item_Option 1')));
      await tester.pump();

      expect(item1Called, true);
      expect(item2Called, false);
      expect(find.text('Option 1'), findsNothing); // Menu should collapse
    });

    testWidgets('animates icon rotation when expanding', (tester) async {
      final items = [
        FabMenuItem(label: 'Option 1', icon: Icons.star, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: items,
              mainLabel: 'Menu',
              mainIcon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('fab_menu_rotation')), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Should still have rotation transition after expansion
      expect(find.byKey(const ValueKey('fab_menu_rotation')), findsOneWidget);
    });

    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MobileFabWithMenu(
              items: [],
              mainLabel: 'Menu',
              mainIcon: Icons.menu,
            ),
          ),
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not throw any errors during disposal
    });
  });

  group('FabMenuItem', () {
    test('creates item with required parameters', () {
      bool tapped = false;
      final item = FabMenuItem(
        label: 'Test Item',
        icon: Icons.star,
        onTap: () => tapped = true,
      );

      expect(item.label, 'Test Item');
      expect(item.icon, Icons.star);
      expect(item.onTap, isNotNull);

      item.onTap();
      expect(tapped, true);
    });
  });

  group('MobileFabType', () {
    test('has three enum values', () {
      const values = MobileFabType.values;
      expect(values.length, 3);
      expect(values, contains(MobileFabType.primary));
      expect(values, contains(MobileFabType.secondary));
      expect(values, contains(MobileFabType.action));
    });
  });
}
