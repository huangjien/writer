import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:writer/services/biometric_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late BiometricService biometricService;
  late MockFlutterSecureStorage mockStorage;
  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLocalAuth = MockLocalAuthentication();
    biometricService = BiometricService(
      storage: mockStorage,
      localAuth: mockLocalAuth,
    );
  });

  group('BiometricService', () {
    test(
      'isBiometricAvailable returns true when supported and capable',
      () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalAuth.isDeviceSupported(),
        ).thenAnswer((_) async => true);

        expect(await biometricService.isBiometricAvailable(), true);
      },
    );

    test('isBiometricAvailable returns false when not capable', () async {
      when(
        () => mockLocalAuth.canCheckBiometrics,
      ).thenAnswer((_) async => false);
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenAnswer((_) async => true);

      expect(await biometricService.isBiometricAvailable(), false);
    });

    test('isBiometricAvailable returns false on error', () async {
      when(() => mockLocalAuth.canCheckBiometrics).thenThrow(Exception('test'));

      expect(await biometricService.isBiometricAvailable(), false);
    });

    test('getAvailableBiometrics returns list', () async {
      when(
        () => mockLocalAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.face]);

      expect(await biometricService.getAvailableBiometrics(), [
        BiometricType.face,
      ]);
    });

    test('authenticate returns true on success', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);

      expect(await biometricService.authenticate(), true);
    });

    test('authenticate returns false on failure', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      expect(await biometricService.authenticate(), false);
    });

    test('authenticate returns false on error', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenThrow(PlatformException(code: 'test'));

      expect(await biometricService.authenticate(), false);
    });

    test('enableBiometricAuth writes data', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await biometricService.enableBiometricAuth('long_enough_token_123');

      verify(
        () => mockStorage.write(
          key: 'biometric_session_token_v2',
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'biometric_enabled_v2', value: 'true'),
      ).called(1);
    });

    test('isBiometricEnabled returns true when enabled and setup', () async {
      when(
        () => mockStorage.read(key: 'biometric_enabled_v2'),
      ).thenAnswer((_) async => 'true');
      when(
        () => mockStorage.read(key: 'biometric_setup_completed_v2'),
      ).thenAnswer((_) async => 'true');

      expect(await biometricService.isBiometricEnabled(), true);
    });

    test('isBiometricEnabled returns false when not enabled', () async {
      when(
        () => mockStorage.read(key: 'biometric_enabled_v2'),
      ).thenAnswer((_) async => null);

      expect(await biometricService.isBiometricEnabled(), false);
    });

    test('getSessionToken returns stored token', () async {
      when(
        () => mockStorage.read(key: 'biometric_session_token_v2'),
      ).thenAnswer((_) async => 'some_token');

      expect(await biometricService.getSessionToken(), 'some_token');
    });

    test('disableBiometricAuth deletes keys', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await biometricService.disableBiometricAuth();

      verify(() => mockStorage.delete(key: 'biometric_enabled_v2')).called(1);
      verify(
        () => mockStorage.delete(key: 'biometric_session_token_v2'),
      ).called(1);
    });

    test('validateStoredToken returns true if matches', () async {
      when(
        () => mockStorage.read(key: 'biometric_session_token_v2'),
      ).thenAnswer((_) async => 'correct_token');

      expect(await biometricService.validateStoredToken('correct_token'), true);
    });

    test('validateStoredToken returns false if no token', () async {
      when(
        () => mockStorage.read(key: 'biometric_session_token_v2'),
      ).thenAnswer((_) async => null);

      expect(
        await biometricService.validateStoredToken('long_token_for_validation'),
        false,
      );
    });
  });
}
