import 'package:flutter_riverpod/legacy.dart';

/// Provider for handling authentication redirects
///
/// This provider manages the redirect flow when authentication fails:
/// 1. Saves the current route when 401 is received
/// 2. Redirects to the login page
/// 3. After successful login, redirects back to the original route
class AuthRedirectNotifier extends StateNotifier<String?> {
  AuthRedirectNotifier() : super(null);

  /// Store the current route and trigger redirect to login
  ///
  /// [currentPath] - The current route path that the user was on
  void saveRouteAndRedirect(String currentPath) {
    if (currentPath.trim().isEmpty) {
      state = '/';
      return;
    }

    final parsed = Uri.tryParse(currentPath);
    final path = parsed?.path ?? currentPath;

    // Don't save auth-related routes
    if (path == '/auth' ||
        path == '/signup' ||
        path == '/forgot-password' ||
        path == '/reset-password') {
      state = '/';
      return;
    }
    state = currentPath;
  }

  /// Get the saved route to redirect to after login
  ///
  /// Returns the saved route or '/' if no route was saved
  String getRedirectRoute() {
    return state ?? '/';
  }

  /// Clear the saved redirect route
  void clearRedirect() {
    state = null;
  }
}

/// Provider for authentication redirect management
final authRedirectProvider =
    StateNotifierProvider<AuthRedirectNotifier, String?>((ref) {
      return AuthRedirectNotifier();
    });
