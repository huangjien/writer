import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/tools/mobile_tools_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';

void main() {
  group('MobileToolsScreen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/tools',
        routes: [
          GoRoute(
            path: '/tools',
            builder: (context, state) => const MobileToolsScreen(),
          ),
          GoRoute(
            path: '/prompts',
            builder: (context, state) => const Scaffold(body: Text('Prompts')),
          ),
          GoRoute(
            path: '/patterns',
            builder: (context, state) => const Scaffold(body: Text('Patterns')),
          ),
          GoRoute(
            path: '/story_lines',
            builder: (context, state) =>
                const Scaffold(body: Text('Story Lines')),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Scaffold(body: Text('Settings')),
          ),
        ],
      );
    });

    testWidgets('renders grid items correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify grid items exist
      expect(
        find.text('Character Templates'),
        findsOneWidget,
      ); // Default localization
      expect(find.text('Scene Templates'), findsOneWidget);
      expect(find.text('Prompts'), findsOneWidget);
      expect(find.text('Patterns'), findsOneWidget);
      expect(find.text('Story Lines'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('navigates to tools on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Prompts
      await tester.tap(find.text('Prompts'));
      await tester.pumpAndSettle();
      expect(
        find.text('Prompts'),
        findsOneWidget,
      ); // Found in new route scaffold body

      // Go back
      router.go('/tools');
      await tester.pumpAndSettle();

      // Tap Patterns
      await tester.tap(find.text('Patterns'));
      await tester.pumpAndSettle();
      expect(find.text('Patterns'), findsOneWidget);
    });

    testWidgets('bottom nav bar interaction', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MobileBottomNavBar), findsOneWidget);

      // Initially selected tab should be tools
      // Note: MobileBottomNavBar internal state might be hard to inspect directly without keys,
      // but we can ensure it renders.
    });

    testWidgets('shows snackbar for unimplemented features', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Character Templates
      await tester.tap(find.text('Character Templates'));
      await tester.pump();
      expect(find.text('Select a novel first'), findsOneWidget);

      // Tap Scene Templates
      await tester.tap(find.text('Scene Templates'));
      await tester.pump();
      expect(find.text('Select a novel first'), findsOneWidget);
    });

    testWidgets('shows more menu', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();
      expect(find.text('More menu coming soon'), findsOneWidget);
    });
  });
}
