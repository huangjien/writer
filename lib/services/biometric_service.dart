import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  BiometricService({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             mOptions: _MacOsOptionsLegacy(usesDataProtectionKeychain: false),
           ),
       _localAuth = localAuth ?? LocalAuthentication();

  static const _biometricEnabledKey = 'biometric_enabled_v2';
  static const _sessionTokenKey = 'biometric_session_token_v2';
  static const _biometricSetupKey = 'biometric_setup_completed_v2';
  static const _refreshTokenKey = 'biometric_refresh_token_v2';

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: canCheckBiometrics=$canCheckBiometrics, isDeviceSupported=$isDeviceSupported',
          );
        } catch (_) {}
      }
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: isBiometricAvailable error - $e');
        } catch (_) {}
      }
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    String localizedReason = 'Authenticate to sign in',
  }) async {
    try {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Starting authentication - $localizedReason',
          );
        } catch (_) {}
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Authentication result=$authenticated');
        } catch (_) {}
      }
      return authenticated;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: PlatformException during authentication - code: ${e.code}, message: ${e.message}',
          );
        } catch (_) {}
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Unexpected error during authentication - $e',
          );
        } catch (_) {}
      }
      return false;
    }
  }

  Future<void> enableBiometricAuth(
    String sessionToken, {
    String? refreshToken,
  }) async {
    try {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Enabling biometric auth with token (length: ${sessionToken.length})',
          );
        } catch (_) {}
      }
      await _storage.write(key: _sessionTokenKey, value: sessionToken);
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }
      await _storage.write(key: _biometricEnabledKey, value: 'true');
      await _storage.write(key: _biometricSetupKey, value: 'true');
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Biometric auth enabled successfully');
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error enabling biometric auth - $e');
        } catch (_) {}
      }
      throw Exception('Storage Error: $e');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final isEnabled = await _storage.read(key: _biometricEnabledKey);
      final isSetup = await _storage.read(key: _biometricSetupKey);
      if (kDebugMode) {
        debugPrint(
          'BiometricService: isBiometricEnabled - enabled=$isEnabled, setup=$isSetup',
        );
      }
      return isEnabled == 'true' && isSetup == 'true';
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'BiometricService: Error checking biometric enabled status - $e',
        );
      }
      return false;
    }
  }

  Future<String?> getSessionToken() async {
    try {
      final token = await _storage.read(key: _sessionTokenKey);
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: getSessionToken - ${token != null ? "found (length: ${token.length})" : "not found"}',
          );
        } catch (_) {}
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error getting session token - $e');
        } catch (_) {}
      }
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: getRefreshToken - ${token != null ? "found (length: ${token.length})" : "not found"}',
          );
        } catch (_) {}
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error getting refresh token - $e');
        } catch (_) {}
      }
      return null;
    }
  }

  Future<void> disableBiometricAuth() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _sessionTokenKey);
    } catch (e) {
      throw Exception('Failed to disable biometric authentication');
    }
  }

  Future<void> clearBiometricData() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _sessionTokenKey);
      await _storage.delete(key: _biometricSetupKey);
    } catch (e) {
      throw Exception('Failed to clear biometric data');
    }
  }

  Future<bool> hasCompletedSetup() async {
    try {
      final setup = await _storage.read(key: _biometricSetupKey);
      return setup == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateStoredToken(String currentToken) async {
    try {
      final storedToken = await getSessionToken();
      if (storedToken == null) return false;

      return storedToken == currentToken;
    } catch (e) {
      return false;
    }
  }
}

class _MacOsOptionsLegacy extends MacOsOptions {
  const _MacOsOptionsLegacy({super.usesDataProtectionKeychain});

  @override
  Map<String, String> toMap() => <String, String>{
    ...super.toMap(),
    'useDataProtectionKeyChain': '$usesDataProtectionKeychain',
  };
}
