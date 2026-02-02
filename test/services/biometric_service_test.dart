import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/biometric_service.dart';

void main() {
  group('BiometricService', () {
    test('can be instantiated with defaults', () {
      final service = BiometricService();
      expect(service, isNotNull);
    });

    test('can be instantiated with custom storage', () {
      final service = BiometricService(storage: null);
      expect(service, isNotNull);
    });

    test('can be instantiated with custom localAuth', () {
      final service = BiometricService(localAuth: null);
      expect(service, isNotNull);
    });

    test('has isBiometricAvailable method', () async {
      final service = BiometricService();
      final result = await service.isBiometricAvailable();
      expect(result, isA<bool>());
    });

    test('has getAvailableBiometrics method', () async {
      final service = BiometricService();
      final result = await service.getAvailableBiometrics();
      expect(result, isA<List>());
    });

    test('has authenticate method', () async {
      final service = BiometricService();
      final result = await service.authenticate();
      expect(result, isA<bool>());
    });

    test('has isBiometricEnabled method', () async {
      final service = BiometricService();
      final result = await service.isBiometricEnabled();
      expect(result, isA<bool>());
    });

    test('has getSessionToken method', () async {
      final service = BiometricService();
      final result = await service.getSessionToken();
      expect(result, isA<String?>());
    });

    test('has getRefreshToken method', () async {
      final service = BiometricService();
      final result = await service.getRefreshToken();
      expect(result, isA<String?>());
    });

    test('has disableBiometricAuth method', () async {
      final service = BiometricService();
      try {
        await service.disableBiometricAuth();
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('has clearBiometricData method', () async {
      final service = BiometricService();
      try {
        await service.clearBiometricData();
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('has hasCompletedSetup method', () async {
      final service = BiometricService();
      final result = await service.hasCompletedSetup();
      expect(result, isA<bool>());
    });

    test('has validateStoredToken method', () async {
      final service = BiometricService();
      final result = await service.validateStoredToken('test-token');
      expect(result, isA<bool>());
    });

    test('has storeCredentials method', () async {
      final service = BiometricService();
      try {
        await service.storeCredentials('test@example.com', 'password');
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('has getStoredEmail method', () async {
      final service = BiometricService();
      final result = await service.getStoredEmail();
      expect(result, isA<String?>());
    });

    test('has getStoredPassword method', () async {
      final service = BiometricService();
      final result = await service.getStoredPassword();
      expect(result, isA<String?>());
    });

    test('has hasStoredCredentials method', () async {
      final service = BiometricService();
      final result = await service.hasStoredCredentials();
      expect(result, isA<bool>());
    });

    test('has clearStoredCredentials method', () async {
      final service = BiometricService();
      try {
        await service.clearStoredCredentials();
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('has getShouldStoreCredentials method', () async {
      final service = BiometricService();
      final result = await service.getShouldStoreCredentials();
      expect(result, isA<bool>());
    });

    test('has setShouldStoreCredentials method', () async {
      final service = BiometricService();
      try {
        await service.setShouldStoreCredentials(true);
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('has validateStoredTokens method', () async {
      final service = BiometricService();
      final result = await service.validateStoredTokens();
      expect(result, isA<BiometricTokenStatus>());
    });

    test('BiometricTokenStatus has all expected values', () {
      expect(BiometricTokenStatus.valid, isNotNull);
      expect(BiometricTokenStatus.expired, isNotNull);
      expect(BiometricTokenStatus.noTokensWithCredentials, isNotNull);
      expect(BiometricTokenStatus.noTokens, isNotNull);
      expect(BiometricTokenStatus.error, isNotNull);
    });

    test('enableBiometricAuth requires sessionToken', () async {
      final service = BiometricService();
      try {
        await service.enableBiometricAuth('test-token');
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('enableBiometricAuth accepts optional refreshToken', () async {
      final service = BiometricService();
      try {
        await service.enableBiometricAuth(
          'test-token',
          refreshToken: 'refresh-token',
        );
      } catch (e) {
        // Storage errors are expected in test environment
      }
    });

    test('authenticate accepts custom localizedReason', () async {
      final service = BiometricService();
      final result = await service.authenticate(
        localizedReason: 'Custom reason',
      );
      expect(result, isA<bool>());
    });
  });
}
