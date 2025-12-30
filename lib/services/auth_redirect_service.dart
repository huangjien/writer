import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/navigator_key_provider.dart';
import '../state/redirect_provider.dart';

/// Service for handling authentication redirects
///
/// This service provides methods to trigger redirects to the login page
/// when authentication fails (401 errors). It saves the current route
/// so the user can return to it after successful login.
class AuthRedirectService {
  final GlobalKey<NavigatorState> navigatorKey;

  AuthRedirectService(this.navigatorKey);

  /// Trigger redirect to login page with current route preservation
  ///
  /// This method should be called when a 401 error is received.
  /// It saves the current route and navigates to the login page.
  ///
  /// [ref] - The Ref for accessing providers
  /// [currentPath] - Optional current route path (defaults to '/' if not provided)
  Future<void> redirectToLogin(Ref ref, {String? currentPath}) async {
    try {
      final currentState = navigatorKey.currentState;

      if (currentState == null) {
        // Can't navigate, just save the redirect route
        ref
            .read(authRedirectProvider.notifier)
            .saveRouteAndRedirect(currentPath ?? '/');
        return;
      }

      // Get current route if not provided
      final path = currentPath ?? '/';

      // Save the route and navigate to login
      ref.read(authRedirectProvider.notifier).saveRouteAndRedirect(path);

      // Navigate to login page
      currentState.pushNamed('/auth');
    } catch (e) {
      // If navigation fails, just save the redirect route
      ref
          .read(authRedirectProvider.notifier)
          .saveRouteAndRedirect(currentPath ?? '/');
    }
  }

  /// Navigate back to the original route after successful login
  ///
  /// [ref] - The Ref for accessing providers
  /// [context] - The BuildContext for navigation
  void navigateBackToOriginal(Ref ref, BuildContext context) {
    final redirectRoute = ref
        .read(authRedirectProvider.notifier)
        .getRedirectRoute();
    ref.read(authRedirectProvider.notifier).clearRedirect();

    if (context.mounted) {
      context.go(redirectRoute);
    }
  }
}

/// Provider for AuthRedirectService
///
/// This provider can be overridden in tests with a mock implementation.
final authRedirectServiceProvider = Provider<AuthRedirectService>((ref) {
  final navigatorKey = ref.read(globalNavigatorKeyProvider);
  return AuthRedirectService(navigatorKey);
});

// Keep static methods for backward compatibility (deprecated)
// These will be removed in a future version
@Deprecated('Use authRedirectServiceProvider instead')
class AuthRedirectServiceStatic {
  AuthRedirectServiceStatic._();

  /// Trigger redirect to login page with current route preservation
  ///
  /// This method should be called when a 401 error is received.
  /// It saves the current route and navigates to the login page.
  ///
  /// [ref] - The Ref for accessing providers
  /// [currentPath] - Optional current route path (defaults to '/' if not provided)
  @Deprecated('Use authRedirectServiceProvider and instance method instead')
  static Future<void> redirectToLogin(Ref ref, {String? currentPath}) async {
    final service = ref.read(authRedirectServiceProvider);
    return service.redirectToLogin(ref, currentPath: currentPath);
  }

  /// Navigate back to the original route after successful login
  ///
  /// [ref] - The Ref for accessing providers
  /// [context] - The BuildContext for navigation
  @Deprecated('Use authRedirectServiceProvider and instance method instead')
  static void navigateBackToOriginal(Ref ref, BuildContext context) {
    final service = ref.read(authRedirectServiceProvider);
    service.navigateBackToOriginal(ref, context);
  }
}
