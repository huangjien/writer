import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';
import 'session_state.dart';
import 'auth_service_provider.dart';

// Re-export BiometricTokenStatus for UI usage
export '../services/biometric_service.dart';

enum BiometricAuthState {
  unavailable,
  disabled,
  enabled,
  authenticating,
  authenticated,
  failed,
}

enum BiometricErrorType {
  /// Biometric authentication failed (user cancelled, fingerprint not recognized, etc.)
  authenticationFailed,

  /// Stored tokens are expired, user needs to sign in normally
  tokensExpired,

  /// No tokens are stored, biometric was never properly set up
  noTokens,

  /// Error occurred during token validation or refresh
  tokenError,

  /// Network or other technical error
  technicalError,

  /// Stored credentials failed to authenticate (password changed, account issues, etc.)
  credentialsInvalid,
}

class BiometricSessionNotifier extends StateNotifier<BiometricAuthState> {
  final BiometricService _biometricService;
  final SessionNotifier _sessionNotifier;
  final AuthService _authService;
  BiometricErrorType? _lastErrorType;

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
      debugPrint('BiometricSessionNotifier: Starting biometric sign in');
      state = BiometricAuthState.authenticating;

      // Step 1: Perform biometric authentication
      final isAuthenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in with your biometrics',
      );

      if (!isAuthenticated) {
        debugPrint('BiometricSessionNotifier: Biometric authentication failed');
        _setError(BiometricErrorType.authenticationFailed);
        return false;
      }

      debugPrint(
        'BiometricSessionNotifier: Biometric authentication successful',
      );

      // Step 2: Validate stored tokens before attempting to use them
      final tokenStatus = await _biometricService.validateStoredTokens();
      debugPrint(
        'BiometricSessionNotifier: Token validation result: $tokenStatus',
      );

      switch (tokenStatus) {
        case BiometricTokenStatus.noTokens:
          debugPrint('BiometricSessionNotifier: No tokens stored');
          _setError(BiometricErrorType.noTokens);
          return false;

        case BiometricTokenStatus.noTokensWithCredentials:
          debugPrint(
            'BiometricSessionNotifier: No tokens but credentials available, attempting re-authentication',
          );
          return await _attemptCredentialBasedSignin();

        case BiometricTokenStatus.expired:
          debugPrint('BiometricSessionNotifier: Tokens are expired');
          _setError(BiometricErrorType.tokensExpired);
          // Optionally auto-disable biometric when tokens are expired
          await disableBiometricAuthDueToExpiration();
          return false;

        case BiometricTokenStatus.error:
          debugPrint('BiometricSessionNotifier: Error validating tokens');
          _setError(BiometricErrorType.tokenError);
          return false;

        case BiometricTokenStatus.valid:
          debugPrint(
            'BiometricSessionNotifier: Tokens appear valid, proceeding',
          );
          break;
      }

      // Step 3: Try refresh token first if available
      final refreshToken = await _biometricService.getRefreshToken();
      if (refreshToken != null) {
        debugPrint(
          'BiometricSessionNotifier: Refresh token found, attempting refresh',
        );
        try {
          final result = await _authService.refresh(refreshToken);
          if (result.success && result.sessionId != null) {
            debugPrint(
              'BiometricSessionNotifier: Session refreshed successfully',
            );
            await _sessionNotifier.setSessionId(result.sessionId!);
            if (result.refreshToken != null) {
              await _sessionNotifier.setRefreshToken(result.refreshToken);
            }
            state = BiometricAuthState.authenticated;
            return true;
          } else {
            debugPrint(
              'BiometricSessionNotifier: Refresh failed - ${result.errorMessage}',
            );
            // Don't fall back to session token if refresh failed - tokens are likely expired
            _setError(BiometricErrorType.tokensExpired);
            return false;
          }
        } catch (e) {
          debugPrint('BiometricSessionNotifier: Error during refresh - $e');
          _setError(BiometricErrorType.tokenError);
          return false;
        }
      }

      // Step 4: Fall back to session token only (if no refresh token)
      final sessionToken = await _biometricService.getSessionToken();
      if (sessionToken != null) {
        debugPrint('BiometricSessionNotifier: Using stored session token');
        try {
          await _sessionNotifier.setSessionId(sessionToken);
          state = BiometricAuthState.authenticated;
          debugPrint('BiometricSessionNotifier: Biometric sign in successful');
          return true;
        } catch (e) {
          debugPrint(
            'BiometricSessionNotifier: Error setting session token - $e',
          );
          _setError(BiometricErrorType.technicalError);
          return false;
        }
      }

      debugPrint('BiometricSessionNotifier: No valid tokens found');
      _setError(BiometricErrorType.noTokens);
      return false;
    } catch (e) {
      debugPrint(
        'BiometricSessionNotifier: Unexpected error in signInWithBiometrics - $e',
      );
      _setError(BiometricErrorType.technicalError);
      return false;
    }
  }

  Future<void> disableBiometricAuth() async {
    try {
      await _biometricService.disableBiometricAuth();
      state = BiometricAuthState.disabled;
      _lastErrorType = null;
    } catch (e) {
      state = BiometricAuthState.failed;
    }
  }

  /// Disable biometric authentication when tokens are expired
  /// This should be called when tokens are no longer valid
  Future<void> disableBiometricAuthDueToExpiration() async {
    try {
      debugPrint(
        'BiometricSessionNotifier: Disabling biometric auth due to token expiration',
      );
      await _biometricService.clearBiometricData();
      state = BiometricAuthState.disabled;
      _lastErrorType = null;
    } catch (e) {
      debugPrint(
        'BiometricSessionNotifier: Error disabling biometric auth - $e',
      );
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
  BiometricErrorType? get lastErrorType => _lastErrorType;

  void resetState() {
    if (state != BiometricAuthState.unavailable) {
      state = BiometricAuthState.disabled;
      _lastErrorType = null;
    }
  }

  void _setError(BiometricErrorType errorType) {
    state = BiometricAuthState.failed;
    _lastErrorType = errorType;
  }

  /// Attempt to sign in using stored credentials after biometric authentication
  Future<bool> _attemptCredentialBasedSignin() async {
    try {
      debugPrint(
        'BiometricSessionNotifier: Attempting credential-based sign-in',
      );

      // Get stored credentials
      final email = await _biometricService.getStoredEmail();
      final password = await _biometricService.getStoredPassword();

      if (email == null || password == null) {
        debugPrint('BiometricSessionNotifier: No stored credentials available');
        _setError(BiometricErrorType.noTokens);
        return false;
      }

      // Attempt sign-in with stored credentials
      final result = await _authService.signIn(email, password);

      if (result.success && result.sessionId != null) {
        debugPrint(
          'BiometricSessionNotifier: Credential-based sign-in successful',
        );

        // Store the new session tokens
        await _biometricService.enableBiometricAuth(
          result.sessionId!,
          refreshToken: result.refreshToken,
        );

        // Set the session
        await _sessionNotifier.setSessionId(result.sessionId!);
        if (result.refreshToken != null) {
          await _sessionNotifier.setRefreshToken(result.refreshToken);
        }

        state = BiometricAuthState.authenticated;
        return true;
      } else {
        debugPrint(
          'BiometricSessionNotifier: Credential-based sign-in failed - ${result.errorMessage}',
        );
        _setError(BiometricErrorType.credentialsInvalid);
        return false;
      }
    } catch (e) {
      debugPrint(
        'BiometricSessionNotifier: Error during credential-based sign-in - $e',
      );
      _setError(BiometricErrorType.technicalError);
      return false;
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
