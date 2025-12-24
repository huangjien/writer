import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  BiometricService({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _localAuth = localAuth ?? LocalAuthentication();

  static const _biometricEnabledKey = 'biometric_enabled_v2';
  static const _sessionTokenKey = 'biometric_session_token_v2';
  static const _biometricSetupKey = 'biometric_setup_completed_v2';

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
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
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );
      return authenticated;
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometricAuth(String sessionToken) async {
    try {
      await _storage.write(key: _sessionTokenKey, value: sessionToken);
      await _storage.write(key: _biometricEnabledKey, value: 'true');
      await _storage.write(key: _biometricSetupKey, value: 'true');
    } catch (e) {
      throw Exception('Failed to enable biometric authentication');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final isEnabled = await _storage.read(key: _biometricEnabledKey);
      final isSetup = await _storage.read(key: _biometricSetupKey);
      return isEnabled == 'true' && isSetup == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: _sessionTokenKey);
    } catch (e) {
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
