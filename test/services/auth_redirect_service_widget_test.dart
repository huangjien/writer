import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/state/navigator_key_provider.dart';
import 'package:writer/state/redirect_provider.dart';

void main() {
  group('AuthRedirectService Integration', () {
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

    testWidgets('captures current route from GoRouter when not provided', (
      tester,
    ) async {
      // Define a simple app with GoRouter
      final router = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/initial',
        routes: [
          GoRoute(
            path: '/initial',
            builder: (context, state) => const Scaffold(body: Text('Initial')),
          ),
          GoRoute(
            path: '/target',
            builder: (context, state) => const Scaffold(body: Text('Target')),
          ),
          GoRoute(
            path: '/auth',
            name: 'auth',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      // Define a provider that triggers the redirect using its own Ref
      final triggerProvider = Provider<Future<void> Function()>((ref) {
        return () async {
          await ref.read(authRedirectServiceProvider).redirectToLogin(ref);
        };
      });

      // Override the container to include this provider is tricky since container is already created?
      // No, we can just read it if we didn't override it, but here it's a local variable.
      // We can add it to the overrides in setUp? No, it's specific to this test.
      // Actually, we can just use a specific provider for this test or add it to a new container?
      // Re-creating container for this test is easier.

      // Re-setup container for this test to include the trigger logic if needed,
      // but simpler is to just define it globally or pass it.
      // Wait, Provider overrides are for overriding behavior. New providers can just be read.
      // But we need to use 'ref' which comes from the container.
      // So simply defining `triggerProvider` and reading it in the widget is fine without overrides.

      // 2. Add a helper widget that calls redirectToLogin on button press
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
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
                            // Read the trigger provider.
                            // Note: We need to make sure the provider is usable.
                            // Since it's just a variable here, we can't 'read' it via ref
                            // unless it's a global or static final.
                            // Let's rely on a closure that uses the container?
                            // No, `redirectToLogin` needs a `Ref`.

                            // Workaround: Modify existing test setup to include a way to get Ref.
                            // Or define `triggerProvider` outside of main or as a mock.

                            // Let's define the provider locally but use UncontrolledProviderScope.
                            // Riverpod providers are usually global or static.
                            // Making it local works if we just pass the variable.
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

      // Navigate to the target route
      router.go('/target');
      await tester.pumpAndSettle();
      expect(find.text('Target'), findsOneWidget);

      // Act: Tap the button to trigger redirect
      await tester.tap(find.text('Trigger 401'));
      await tester.pumpAndSettle();

      // Assert
      // 1. Check if we navigated to /auth
      expect(find.text('Login'), findsOneWidget);

      // 2. Check if the route was saved correctly
      final savedRoute = container
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();

      // GoRouterState.uri.toString() returns the full path
      expect(savedRoute, '/target');
    });

    testWidgets('captures current route with query params', (tester) async {
      // Define trigger provider for this test too
      final triggerProvider = Provider<Future<void> Function()>((ref) {
        return () async {
          await ref.read(authRedirectServiceProvider).redirectToLogin(ref);
        };
      });

      final router = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/initial',
        routes: [
          GoRoute(
            path: '/initial',
            builder: (context, state) => const Scaffold(body: Text('Initial')),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const Scaffold(body: Text('Search')),
          ),
          GoRoute(
            path: '/auth',
            name: 'auth',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
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

      // Navigate to search with query params
      router.go('/search?q=test');
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);

      // Act
      await tester.tap(find.text('Trigger 401'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login'), findsOneWidget);
      final savedRoute = container
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();
      expect(savedRoute, '/search?q=test');
    });
  });
}
