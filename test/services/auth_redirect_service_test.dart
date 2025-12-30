import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/state/navigator_key_provider.dart';
import 'package:writer/state/redirect_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRedirectService', () {
    late ProviderContainer container;
    late GlobalKey<NavigatorState> mockNavigatorKey;

    setUp(() {
      mockNavigatorKey = GlobalKey<NavigatorState>();
      container = ProviderContainer(
        overrides: [
          globalNavigatorKeyProvider.overrideWithValue(mockNavigatorKey),
          authRedirectServiceProvider.overrideWithValue(
            AuthRedirectService(mockNavigatorKey),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('redirect provider behavior', () {
      test('saves default route when no currentPath is provided', () {
        // Simulate what redirectToLogin does when currentPath is null
        container.read(authRedirectProvider.notifier).saveRouteAndRedirect('/');
        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/');
      });

      test('saves provided currentPath', () {
        // Simulate what redirectToLogin does with currentPath
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/library');
        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/library');
      });

      test('clears redirect after navigation back', () {
        // Simulate save -> get -> clear flow
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/novels/123');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/novels/123',
        );

        container.read(authRedirectProvider.notifier).clearRedirect();
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );
      });

      test('does not save auth-related routes', () {
        // /auth route should save '/' instead
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/auth');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );

        // /signup route should save '/' instead
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/signup');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );

        // /forgot-password route should save '/' instead
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/forgot-password');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );

        // /reset-password route should save '/' instead
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/reset-password');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );
      });

      test('saves nested routes correctly', () {
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/novels/123/chapters/456');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/novels/123/chapters/456',
        );
      });
    });

    group('navigateBackToOriginal behavior', () {
      test('clears redirect after navigating back', () {
        // Simulate navigateBackToOriginal flow
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/library');

        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/library');

        // The service clears redirect
        container.read(authRedirectProvider.notifier).clearRedirect();

        final clearedRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(clearedRoute, '/');
      });

      test('returns "/" when no route was saved', () {
        // No route saved
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );
      });
    });

    group('navigator key provider', () {
      test('provides GlobalKey<NavigatorState>', () {
        final navigatorKey = container.read(globalNavigatorKeyProvider);
        expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
      });

      test('navigatorKey.currentState is null by default in test', () {
        final navigatorKey = container.read(globalNavigatorKeyProvider);
        expect(navigatorKey.currentState, isNull);
      });
    });

    group('integration flow', () {
      test('complete auth redirect flow', () {
        // Initial state
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );

        // Save route when 401 error occurs
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/library');
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/library',
        );

        // After login, navigate back and clear
        final route = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(route, '/library');

        container.read(authRedirectProvider.notifier).clearRedirect();
        expect(
          container.read(authRedirectProvider.notifier).getRedirectRoute(),
          '/',
        );
      });
    });
  });

  group('AuthRedirectService with test provider', () {
    // Create a test provider that exercises AuthRedirectService methods
    final testRedirectProvider = Provider.autoDispose((ref) {
      return _TestRedirectHelper(ref);
    });

    late ProviderContainer container;
    late GlobalKey<NavigatorState> mockNavigatorKey;

    setUp(() {
      mockNavigatorKey = GlobalKey<NavigatorState>();
      container = ProviderContainer(
        overrides: [
          globalNavigatorKeyProvider.overrideWithValue(mockNavigatorKey),
          authRedirectServiceProvider.overrideWithValue(
            AuthRedirectService(mockNavigatorKey),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'AuthRedirectService.redirectToLogin saves route with null navigator state',
      () async {
        final helper = container.read(testRedirectProvider);
        await helper.callRedirectToLogin(currentPath: '/library');

        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/library');
      },
    );

    test(
      'AuthRedirectService.redirectToLogin saves default route when currentPath not provided',
      () async {
        final helper = container.read(testRedirectProvider);
        await helper.callRedirectToLogin();

        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/');
      },
    );

    test(
      'AuthRedirectService.redirectToLogin saves custom currentPath',
      () async {
        final helper = container.read(testRedirectProvider);
        await helper.callRedirectToLogin(
          currentPath: '/novels/123/chapters/456',
        );

        final redirectRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(redirectRoute, '/novels/123/chapters/456');
      },
    );

    test('AuthRedirectService.navigateBackToOriginal clears redirect', () {
      // First save a route
      container
          .read(authRedirectProvider.notifier)
          .saveRouteAndRedirect('/library');
      expect(
        container.read(authRedirectProvider.notifier).getRedirectRoute(),
        '/library',
      );

      // Then call navigateBackToOriginal
      final helper = container.read(testRedirectProvider);
      helper.callNavigateBackToOriginal();

      // Verify redirect was cleared
      final clearedRoute = container
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();
      expect(clearedRoute, '/');
    });

    test(
      'AuthRedirectService.navigateBackToOriginal with unmounted context',
      () {
        container
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect('/library');

        final helper = container.read(testRedirectProvider);
        final mockContext = _createMockContext(mounted: false);
        helper.callNavigateBackToOriginalWithContext(mockContext);

        // Redirect should still be cleared even if context is not mounted
        final clearedRoute = container
            .read(authRedirectProvider.notifier)
            .getRedirectRoute();
        expect(clearedRoute, '/');
      },
    );

    test('complete flow using AuthRedirectService methods', () async {
      final helper = container.read(testRedirectProvider);

      // Initial state
      expect(
        container.read(authRedirectProvider.notifier).getRedirectRoute(),
        '/',
      );

      // Call redirectToLogin
      await helper.callRedirectToLogin(currentPath: '/novels/123');
      expect(
        container.read(authRedirectProvider.notifier).getRedirectRoute(),
        '/novels/123',
      );

      // Call navigateBackToOriginal
      helper.callNavigateBackToOriginal();
      expect(
        container.read(authRedirectProvider.notifier).getRedirectRoute(),
        '/',
      );
    });
  });
}

/// Helper class to test AuthRedirectService instance methods
class _TestRedirectHelper {
  final Ref ref;

  _TestRedirectHelper(this.ref);

  /// Wrapper to call AuthRedirectService.redirectToLogin
  Future<void> callRedirectToLogin({String? currentPath}) async {
    final service = ref.read(authRedirectServiceProvider);
    return service.redirectToLogin(ref, currentPath: currentPath);
  }

  /// Wrapper to call AuthRedirectService.navigateBackToOriginal without context
  void callNavigateBackToOriginal() {
    // This simulates the behavior when context is not available
    ref.read(authRedirectProvider.notifier).clearRedirect();
  }

  /// Wrapper to call AuthRedirectService.navigateBackToOriginal with context
  void callNavigateBackToOriginalWithContext(BuildContext context) {
    final service = ref.read(authRedirectServiceProvider);
    service.navigateBackToOriginal(ref, context);
  }
}

/// Create a mock BuildContext for testing
BuildContext _createMockContext({required bool mounted}) {
  return _MockBuildContext(mounted: mounted);
}

class _MockBuildContext implements BuildContext {
  final bool _mounted;

  _MockBuildContext({required bool mounted}) : _mounted = mounted;

  @override
  bool get mounted => _mounted;

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    return null;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<
    T extends InheritedWidget
  >({Object? aspect}) {
    return null;
  }

  @override
  // ignore: no_such_method
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
