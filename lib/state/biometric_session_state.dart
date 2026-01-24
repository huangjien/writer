import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';
import 'session_state.dart';
import 'auth_service_provider.dart';

enum BiometricAuthState {
  unavailable,
  disabled,
  enabled,
  authenticating,
  authenticated,
  failed,
}

class BiometricSessionNotifier extends StateNotifier<BiometricAuthState> {
  final BiometricService _biometricService;
  final SessionNotifier _sessionNotifier;
  final AuthService _authService;

  BiometricSessionNotifier(
    this._biometricService,
    this._sessionNotifier,
    this._authService,
  ) : super(BiometricAuthState.disabled);

  Future<void> checkBiometricAvailability() async {
    if (kDebugMode) {
      try {
        debugPrint('BiometricSessionNotifier: Checking biometric availability');
      } catch (_) {}
    }
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!mounted) return;
    if (!isAvailable) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricSessionNotifier: Biometric not available');
        } catch (_) {}
      }
      state = BiometricAuthState.unavailable;
      return;
    }

    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!mounted) return;
    if (kDebugMode) {
      try {
        debugPrint('BiometricSessionNotifier: Biometric enabled=$isEnabled');
      } catch (_) {}
    }
    state = isEnabled
        ? BiometricAuthState.enabled
        : BiometricAuthState.disabled;
  }

  Future<bool> enableBiometricAuth(
    String sessionToken, {
    String? refreshToken,
  }) async {
    try {
      try {
        debugPrint('BiometricSessionNotifier: Enabling biometric auth');
      } catch (_) {}
      state = BiometricAuthState.authenticating;

      final isAuthenticated = await _biometricService.authenticate(
        localizedReason: 'Enable biometric authentication for quick sign-in',
      );

      if (isAuthenticated) {
        try {
          debugPrint(
            'BiometricSessionNotifier: Authentication successful, storing token',
          );
        } catch (_) {}
        await _biometricService.enableBiometricAuth(
          sessionToken,
          refreshToken: refreshToken,
        );
        state = BiometricAuthState.enabled;
        try {
          debugPrint(
            'BiometricSessionNotifier: Biometric auth enabled successfully',
          );
        } catch (_) {}
        return true;
      } else {
        try {
          debugPrint('BiometricSessionNotifier: Authentication failed');
        } catch (_) {}
        state = BiometricAuthState.failed;
        return false;
      }
    } catch (e) {
      try {
        debugPrint(
          'BiometricSessionNotifier: Error in enableBiometricAuth - $e',
        );
      } catch (_) {}
      state = BiometricAuthState.failed;
      rethrow;
    }
  }

  Future<bool> signInWithBiometrics() async {
    try {
      try {
        debugPrint('BiometricSessionNotifier: Signing in with biometrics');
      } catch (_) {}
      state = BiometricAuthState.authenticating;

      final isAuthenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in with your biometrics',
      );

      if (isAuthenticated) {
        try {
          debugPrint(
            'BiometricSessionNotifier: Biometric authentication successful, checking for refresh token',
          );
        } catch (_) {}
        final refreshToken = await _biometricService.getRefreshToken();

        if (refreshToken != null) {
          try {
            debugPrint(
              'BiometricSessionNotifier: Refresh token found, refreshing session',
            );
          } catch (_) {}
          try {
            final result = await _authService.refresh(refreshToken);
            if (result.success && result.sessionId != null) {
              try {
                debugPrint(
                  'BiometricSessionNotifier: Session refreshed successfully',
                );
              } catch (_) {}
              await _sessionNotifier.setSessionId(result.sessionId!);
              if (result.refreshToken != null) {
                await _sessionNotifier.setRefreshToken(result.refreshToken);
              }
              state = BiometricAuthState.authenticated;
              try {
                debugPrint(
                  'BiometricSessionNotifier: Biometric sign in successful with refreshed session',
                );
              } catch (_) {}
              return true;
            } else {
              try {
                debugPrint(
                  'BiometricSessionNotifier: Refresh failed - ${result.errorMessage}',
                );
              } catch (_) {}
            }
          } catch (e) {
            try {
              debugPrint('BiometricSessionNotifier: Error during refresh - $e');
            } catch (_) {}
          }
        }

        try {
          debugPrint(
            'BiometricSessionNotifier: Falling back to stored session token',
          );
        } catch (_) {}
        final sessionToken = await _biometricService.getSessionToken();
        if (sessionToken != null) {
          try {
            debugPrint(
              'BiometricSessionNotifier: Token retrieved, setting session',
            );
          } catch (_) {}
          await _sessionNotifier.setSessionId(sessionToken);
          state = BiometricAuthState.authenticated;
          try {
            debugPrint(
              'BiometricSessionNotifier: Biometric sign in successful',
            );
          } catch (_) {}
          return true;
        } else {
          try {
            debugPrint(
              'BiometricSessionNotifier: Token is null, sign in failed',
            );
          } catch (_) {}
        }
      } else {
        try {
          debugPrint(
            'BiometricSessionNotifier: Biometric authentication failed',
          );
        } catch (_) {}
      }

      state = BiometricAuthState.failed;
      return false;
    } catch (e) {
      try {
        debugPrint(
          'BiometricSessionNotifier: Error in signInWithBiometrics - $e',
        );
      } catch (_) {}
      state = BiometricAuthState.failed;
      rethrow;
    }
  }

  Future<void> disableBiometricAuth() async {
    try {
      await _biometricService.disableBiometricAuth();
      state = BiometricAuthState.disabled;
    } catch (e) {
      state = BiometricAuthState.failed;
    }
  }

  Future<void> clearBiometricData() async {
    try {
      await _biometricService.clearBiometricData();
      state = BiometricAuthState.disabled;
    } catch (e) {
      state = BiometricAuthState.failed;
    }
  }

  bool get isBiometricEnabled => state == BiometricAuthState.enabled;
  bool get isBiometricAvailable => state != BiometricAuthState.unavailable;
  bool get isAuthenticating => state == BiometricAuthState.authenticating;
  bool get isAuthenticated => state == BiometricAuthState.authenticated;
  bool get hasFailed => state == BiometricAuthState.failed;

  void resetState() {
    if (state != BiometricAuthState.unavailable) {
      state = BiometricAuthState.disabled;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final biometricSessionProvider =
    StateNotifierProvider<BiometricSessionNotifier, BiometricAuthState>((ref) {
      final biometricService = ref.watch(biometricServiceProvider);
      final sessionNotifier = ref.watch(sessionProvider.notifier);
      final authService = ref.watch(authServiceProvider);
      return BiometricSessionNotifier(
        biometricService,
        sessionNotifier,
        authService,
      );
    });

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return await biometricService.isBiometricAvailable();
});

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return await biometricService.isBiometricEnabled();
});
