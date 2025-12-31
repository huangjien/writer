import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileBottomNavBar', () {
    late List<MobileNavTab> selectedTabs;

    setUp(() {
      selectedTabs = [];
    });

    Widget createWidget({
      MobileNavTab currentTab = MobileNavTab.home,
      Set<MobileNavTab>? showBadgeOnTab,
    }) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MobileBottomNavBar(
            currentTab: currentTab,
            onTabChanged: (tab) => selectedTabs.add(tab),
            showBadgeOnTab: showBadgeOnTab,
          ),
        ),
      );
    }

    testWidgets('renders all 5 navigation tabs', (tester) async {
      await tester.pumpWidget(createWidget());

      // Check that all navigation icons are present
      // Home tab is selected by default, so it shows filled icon
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Check that all labels are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Write'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Tools'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('highlights selected tab with filled icon and primary color', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(currentTab: MobileNavTab.write));

      // Selected tab should have filled icon
      expect(find.byIcon(Icons.edit), findsOneWidget);
      // Unselected tabs should have outlined icons
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Selected tab label should have primary color and bold weight
      final writeTabWidgets = tester.widgetList<Text>(find.text('Write'));
      final writeTab = writeTabWidgets.first;
      expect(writeTab.style?.color, isA<Color>());
      expect(writeTab.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('calls onTabChanged when tab is tapped', (tester) async {
      await tester.pumpWidget(createWidget());

      // Tap on the 'Write' tab
      await tester.tap(find.text('Write'));
      await tester.pump();

      expect(selectedTabs, [MobileNavTab.write]);

      // Tap on the 'Read' tab
      await tester.tap(find.text('Read'));
      await tester.pump();

      expect(selectedTabs, [MobileNavTab.write, MobileNavTab.read]);
    });

    testWidgets('shows badge on specified tabs', (tester) async {
      await tester.pumpWidget(
        createWidget(showBadgeOnTab: {MobileNavTab.home, MobileNavTab.tools}),
      );

      // Should find 2 badge indicators (red circles)
      expect(find.byType(Positioned), findsNWidgets(2));
    });

    testWidgets('does not show badges when showBadgeOnTab is null', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      // Should not find any badge indicators
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('shows correct icons for each tab when selected', (
      tester,
    ) async {
      for (final tab in MobileNavTab.values) {
        selectedTabs.clear();
        await tester.pumpWidget(createWidget(currentTab: tab));

        IconData expectedFilledIcon;
        switch (tab) {
          case MobileNavTab.home:
            expectedFilledIcon = Icons.menu_book;
            break;
          case MobileNavTab.write:
            expectedFilledIcon = Icons.edit;
            break;
          case MobileNavTab.read:
            expectedFilledIcon = Icons.book;
            break;
          case MobileNavTab.tools:
            expectedFilledIcon = Icons.build;
            break;
          case MobileNavTab.more:
            expectedFilledIcon = Icons.more_horiz;
            break;
        }

        expect(find.byIcon(expectedFilledIcon), findsOneWidget);
      }
    });

    testWidgets('has correct height and decoration', (tester) async {
      await tester.pumpWidget(createWidget());

      final bottomNavBarFinder = find.byType(Container);
      final bottomNavBar = tester.widget<Container>(bottomNavBarFinder.first);

      // Check that the container has the expected height
      expect(bottomNavBar.constraints?.maxHeight, equals(56.0));

      // Check that it has a box shadow
      final decoration = bottomNavBar.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotEmpty);
      expect(decoration.boxShadow?.first.blurRadius, equals(8.0));
    });

    testWidgets('handles rapid tab changes', (tester) async {
      await tester.pumpWidget(createWidget());

      // Rapidly tap different tabs
      await tester.tap(find.text('Write'));
      await tester.tap(find.text('Read'));
      await tester.tap(find.text('Tools'));
      await tester.pump();

      expect(selectedTabs, [
        MobileNavTab.write,
        MobileNavTab.read,
        MobileNavTab.tools,
      ]);
    });

    testWidgets('tabs are tappable within their touch target area', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      // Tap the general area around each tab
      final writeTabFinder = find.byIcon(Icons.edit_outlined);
      await tester.tap(writeTabFinder);
      await tester.pump();

      expect(selectedTabs, [MobileNavTab.write]);
    });

    testWidgets('badge position is correct', (tester) async {
      await tester.pumpWidget(
        createWidget(showBadgeOnTab: {MobileNavTab.home}),
      );

      final badgeFinder = find.byType(Positioned);
      final badge = tester.widget<Positioned>(badgeFinder.first);

      // Badge should be positioned at top-right of the tab
      expect(badge.top, equals(4.0));
      expect(badge.right, equals(8.0));

      final badgeContainer = badge.child as Container;
      final constraints = badgeContainer.constraints as BoxConstraints;
      expect(constraints.maxWidth, equals(8.0));
      expect(constraints.maxHeight, equals(8.0));
    });
  });
}
