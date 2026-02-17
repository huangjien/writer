import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/widgets/app_drawer.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('Home Screen')),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('Settings Screen')),
          ),
        ),
        GoRoute(
          path: '/prompts',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Prompts')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('Prompts Screen')),
          ),
        ),
        GoRoute(
          path: '/create-novel',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Create Novel')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('Create Novel Screen')),
          ),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('About')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('About Screen')),
          ),
        ),
        GoRoute(
          path: '/my-novels',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('My Novels')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('My Novels Screen')),
          ),
        ),
        GoRoute(
          path: '/hot-topics',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Hot Topics')),
            drawer: const AppDrawer(),
            body: const Center(child: Text('Hot Topics Screen')),
          ),
        ),
      ],
    );
  }

  testWidgets('AppDrawer navigates to settings and about', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    final s1 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s1.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings Screen'), findsOneWidget);
    final s2 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s2.openDrawer();
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('About'),
      find.byType(Drawer),
      const Offset(0, -50),
    );
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('About Screen'), findsOneWidget);
  });

  testWidgets('AppDrawer navigates to prompts and create novel', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final s1 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s1.openDrawer();
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Prompts'),
      find.byType(Drawer),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Prompts'));
    await tester.pumpAndSettle();
    expect(find.text('Prompts Screen'), findsOneWidget);
    final s2 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s2.openDrawer();
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Create Novel'),
      find.byType(Drawer),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Create Novel'));
    await tester.pumpAndSettle();
    expect(find.text('Create Novel Screen'), findsOneWidget);
  });

  testWidgets('AppDrawer navigates to character and scene templates', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final s1 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s1.openDrawer();
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Character Templates'),
      find.byType(Drawer),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Character Templates'));
    await tester.pumpAndSettle();
    expect(find.text('My Novels Screen'), findsOneWidget);
    final s2 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s2.openDrawer();
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Scene Templates'),
      find.byType(Drawer),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Scene Templates'));
    await tester.pumpAndSettle();
    expect(find.text('My Novels Screen'), findsOneWidget);
  });

  testWidgets('AppDrawer navigates to home and hot topics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    final s1 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s1.openDrawer();
    await tester.pumpAndSettle();
    final homeFinder = find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Home'),
    );
    await tester.tap(homeFinder);
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    final s2 = tester.state<ScaffoldState>(find.byType(Scaffold));
    s2.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hot Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Hot Topics Screen'), findsOneWidget);
  });
}
