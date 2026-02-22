import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/shared/widgets/app_shell.dart';

void main() {
  group('AppShellType enum', () {
    test('has expected values', () {
      expect(AppShellType.values.length, 3);
      expect(AppShellType.values, contains(AppShellType.appDrawer));
      expect(AppShellType.values, contains(AppShellType.novel));
      expect(AppShellType.values, contains(AppShellType.none));
    });
  });

  group('AppShell basic rendering', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('My Content'),
            ),
          ),
        ),
      );

      expect(find.text('My Content'), findsOneWidget);
    });

    testWidgets('renders Column child', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Column(children: [Text('Header'), Text('Body')]),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });
  });

  group('AppShell mobile layout', () {
    testWidgets('shows appBar on mobile', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final appBar = AppBar(title: const Text('Test'));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              appBar: appBar,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('hides appBar on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final appBar = AppBar(title: const Text('Test'));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              appBar: appBar,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('shows floatingActionButton on mobile', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const fab = FloatingActionButton(onPressed: null, child: Icon(Icons.add));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              floatingActionButton: fab,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('hides floatingActionButton on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const fab = FloatingActionButton(onPressed: null, child: Icon(Icons.add));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              floatingActionButton: fab,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows bottomNavigationBar on mobile', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bottomNav = BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              bottomNavigationBar: bottomNav,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('hides bottomNavigationBar on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bottomNav = BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              bottomNavigationBar: bottomNav,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('child is always visible', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Child Content'), findsOneWidget);
    });
  });

  group('AppShell desktop layout', () {
    testWidgets('child is visible in Row layout on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('child is Expanded in Row layout', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('child is not in Row on mobile', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });
  });

  group('AppShell with AppShellType.novel', () {
    testWidgets('child is visible when novelId is provided (mobile)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.novel,
              novelId: 'novel-123',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('child is visible when novelId is null (desktop)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.novel,
              novelId: null,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('child is visible on mobile with novelId', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.novel,
              novelId: 'novel-123',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('AppShell responsive behavior', () {
    testWidgets('handles mobile width', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('handles desktop width', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('handles tablet width', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(
              shellType: AppShellType.none,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
