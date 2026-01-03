import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/state/navigator_key_provider.dart';
import 'package:writer/state/redirect_provider.dart';

void main() {
  group('AuthRedirectService Fallback Tests', () {
    late ProviderContainer container;
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
      container = ProviderContainer(
        overrides: [
          globalNavigatorKeyProvider.overrideWithValue(navigatorKey),
          authRedirectServiceProvider.overrideWithValue(
            AuthRedirectService(navigatorKey),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('falls back to root path when GoRouter is not available', (
      tester,
    ) async {
      // Define a trigger provider
      final triggerProvider = Provider<Future<void> Function()>((ref) {
        return () async {
          await ref.read(authRedirectServiceProvider).redirectToLogin(ref);
        };
      });

      // Use standard MaterialApp without GoRouter
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            initialRoute: '/initial',
            routes: {
              '/initial': (context) =>
                  const Scaffold(body: Text('Initial Standard')),
              // Define 'auth' route for pushNamed to work
              'auth': (context) => const Scaffold(body: Text('Login Page')),
            },
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () {
                            ref.read(triggerProvider)();
                          },
                          child: const Text('Trigger 401'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Initial Standard'), findsOneWidget);

      // Act: Trigger redirect
      await tester.tap(find.text('Trigger 401'));
      await tester.pumpAndSettle();

      // Assert:
      // 1. Should NOT have navigated to Login Page because GoRouter is missing
      // and context.pushNamed depends on GoRouter.
      // The service catches the error and prevents a crash.
      expect(find.text('Login Page'), findsNothing);
      expect(find.text('Initial Standard'), findsOneWidget);

      // 2. Should have saved '/' as the route because GoRouter.of(context) failed
      final savedRoute = container
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();
      expect(savedRoute, '/');
    });

    testWidgets('uses explicit currentPath even if GoRouter is not available', (
      tester,
    ) async {
      final triggerProvider = Provider<Future<void> Function()>((ref) {
        return () async {
          await ref
              .read(authRedirectServiceProvider)
              .redirectToLogin(ref, currentPath: '/explicit/path');
        };
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            initialRoute: '/initial',
            routes: {
              '/initial': (context) =>
                  const Scaffold(body: Text('Initial Standard')),
              'auth': (context) => const Scaffold(body: Text('Login Page')),
            },
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () {
                            ref.read(triggerProvider)();
                          },
                          child: const Text('Trigger 401'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Trigger 401'));
      await tester.pumpAndSettle();

      // Should not navigate but should verify it didn't crash
      expect(find.text('Login Page'), findsNothing);
      expect(find.text('Initial Standard'), findsOneWidget);

      final savedRoute = container
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();
      expect(savedRoute, '/explicit/path');
    });
  });
}
