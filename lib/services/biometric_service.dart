import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum BiometricTokenStatus {
  /// Tokens are likely valid and can be used for authentication
  valid,

  /// Tokens exist but are likely expired (session token without refresh token)
  expired,

  /// No tokens are stored, but credentials are available for re-authentication
  noTokensWithCredentials,

  /// No tokens are stored and no credentials available
  noTokens,

  /// Error occurred while validating tokens
  error,
}

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

  // Credential storage keys
  static const _storeCredentialsKey = 'biometric_store_credentials_v2';
  static const _emailKey = 'biometric_email_v2';
  static const _passwordKey = 'biometric_password_v2';

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
      await _storage.delete(key: _refreshTokenKey);
      // Also clear stored credentials
      await clearStoredCredentials();
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

  /// Store user credentials securely for biometric login
  Future<void> storeCredentials(String email, String password) async {
    try {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Storing credentials for email (length: ${email.length})',
          );
        } catch (_) {}
      }
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passwordKey, value: password);
      await _storage.write(key: _storeCredentialsKey, value: 'true');
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Credentials stored successfully');
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error storing credentials - $e');
        } catch (_) {}
      }
      throw Exception('Storage Error: $e');
    }
  }

  /// Get stored email for credential-based login
  Future<String?> getStoredEmail() async {
    try {
      final email = await _storage.read(key: _emailKey);
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: getStoredEmail - ${email != null ? "found (length: ${email.length})" : "not found"}',
          );
        } catch (_) {}
      }
      return email;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error getting stored email - $e');
        } catch (_) {}
      }
      return null;
    }
  }

  /// Get stored password for credential-based login
  Future<String?> getStoredPassword() async {
    try {
      final password = await _storage.read(key: _passwordKey);
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: getStoredPassword - ${password != null ? "found" : "not found"}',
          );
        } catch (_) {}
      }
      return password;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Error getting stored password - $e');
        } catch (_) {}
      }
      return null;
    }
  }

  /// Check if credentials are stored for biometric login
  Future<bool> hasStoredCredentials() async {
    try {
      final storeCredentials = await _storage.read(key: _storeCredentialsKey);
      final hasEmail = await _storage.read(key: _emailKey) != null;
      final hasPassword = await _storage.read(key: _passwordKey) != null;
      final result = storeCredentials == 'true' && hasEmail && hasPassword;
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: hasStoredCredentials - $result (store=$storeCredentials, email=$hasEmail, password=$hasPassword)',
          );
        } catch (_) {}
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Error checking stored credentials - $e',
          );
        } catch (_) {}
      }
      return false;
    }
  }

  /// Clear stored credentials
  Future<void> clearStoredCredentials() async {
    try {
      await _storage.delete(key: _storeCredentialsKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
      if (kDebugMode) {
        try {
          debugPrint('BiometricService: Stored credentials cleared');
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Error clearing stored credentials - $e',
          );
        } catch (_) {}
      }
      throw Exception('Failed to clear stored credentials');
    }
  }

  /// Check if user has opted to store credentials
  Future<bool> getShouldStoreCredentials() async {
    try {
      final shouldStore = await _storage.read(key: _storeCredentialsKey);
      return shouldStore == 'true';
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Error checking store credentials preference - $e',
          );
        } catch (_) {}
      }
      return false;
    }
  }

  /// Set user preference for storing credentials
  Future<void> setShouldStoreCredentials(bool shouldStore) async {
    try {
      await _storage.write(
        key: _storeCredentialsKey,
        value: shouldStore ? 'true' : 'false',
      );
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Store credentials preference set to $shouldStore',
          );
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        try {
          debugPrint(
            'BiometricService: Error setting store credentials preference - $e',
          );
        } catch (_) {}
      }
      throw Exception('Failed to set store credentials preference');
    }
  }

  /// Validates if stored tokens are likely still valid
  /// Returns a BiometricTokenStatus indicating the state of stored tokens
  Future<BiometricTokenStatus> validateStoredTokens() async {
    try {
      final refreshToken = await getRefreshToken();
      final sessionToken = await getSessionToken();
      final hasCredentials = await hasStoredCredentials();

      // If we have no tokens but have credentials, we can re-authenticate
      if (refreshToken == null && sessionToken == null && hasCredentials) {
        return BiometricTokenStatus.noTokensWithCredentials;
      }

      // If we have no tokens at all, they're invalid
      if (refreshToken == null && sessionToken == null && !hasCredentials) {
        return BiometricTokenStatus.noTokens;
      }

      // If we have a refresh token, assume it's likely valid
      // (refresh tokens typically have much longer expiry)
      if (refreshToken != null) {
        return BiometricTokenStatus.valid;
      }

      // If we have no tokens but have credentials, we can re-authenticate
      if (refreshToken == null && sessionToken == null && hasCredentials) {
        return BiometricTokenStatus.noTokensWithCredentials;
      }

      // If we have no tokens at all, they're invalid
      if (refreshToken == null && sessionToken == null && !hasCredentials) {
        return BiometricTokenStatus.noTokens;
      }

      // If we have a refresh token, assume it's likely valid
      // (refresh tokens typically have much longer expiry)
      if (refreshToken != null) {
        return BiometricTokenStatus.valid;
      }

      // If we only have a session token, it's likely expired
      // Session tokens typically expire in hours/days
      if (sessionToken != null) {
        return BiometricTokenStatus.expired;
      }

      return BiometricTokenStatus.noTokens;
    } catch (e) {
      return BiometricTokenStatus.error;
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
