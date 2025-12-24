import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/biometric_service.dart';
import 'session_state.dart';

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

  BiometricSessionNotifier(this._biometricService, this._sessionNotifier)
    : super(BiometricAuthState.disabled);

  Future<void> checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) {
      state = BiometricAuthState.unavailable;
      return;
    }

    final isEnabled = await _biometricService.isBiometricEnabled();
    state = isEnabled
        ? BiometricAuthState.enabled
        : BiometricAuthState.disabled;
  }

  Future<bool> enableBiometricAuth(String sessionToken) async {
    try {
      state = BiometricAuthState.authenticating;

      final isAuthenticated = await _biometricService.authenticate(
        localizedReason: 'Enable biometric authentication for quick sign-in',
      );

      if (isAuthenticated) {
        await _biometricService.enableBiometricAuth(sessionToken);
        state = BiometricAuthState.enabled;
        return true;
      } else {
        state = BiometricAuthState.failed;
        return false;
      }
    } catch (e) {
      state = BiometricAuthState.failed;
      return false;
    }
  }

  Future<bool> signInWithBiometrics() async {
    try {
      state = BiometricAuthState.authenticating;

      final isAuthenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in with your biometrics',
      );

      if (isAuthenticated) {
        final sessionToken = await _biometricService.getSessionToken();
        if (sessionToken != null) {
          await _sessionNotifier.setSessionId(sessionToken);
          state = BiometricAuthState.authenticated;
          return true;
        }
      }

      state = BiometricAuthState.failed;
      return false;
    } catch (e) {
      state = BiometricAuthState.failed;
      return false;
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
      return BiometricSessionNotifier(biometricService, sessionNotifier);
    });

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return await biometricService.isBiometricAvailable();
});

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return await biometricService.isBiometricEnabled();
});
