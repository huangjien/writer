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
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Settings Screen'))),
        ),
        GoRoute(
          path: '/prompts',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Prompts Screen'))),
        ),
        GoRoute(
          path: '/create-novel',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Create Novel Screen'))),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('About Screen'))),
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
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings Screen'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
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
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prompts'));
    await tester.pumpAndSettle();
    expect(find.text('Prompts Screen'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
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
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Character Templates'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scene Templates'));
    await tester.pumpAndSettle();
  });
}
