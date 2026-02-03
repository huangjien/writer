import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/services/biometric_service.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  group('BiometricService', () {
    late MockSecureStorage storage;
    late MockLocalAuth localAuth;
    late BiometricService service;

    setUp(() {
      storage = MockSecureStorage();
      localAuth = MockLocalAuth();
      service = BiometricService(storage: storage, localAuth: localAuth);
    });

    test('enableBiometricAuth writes setup and token keys', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await service.enableBiometricAuth(
        'session-token',
        refreshToken: 'refresh-token',
      );

      verify(
        () => storage.write(
          key: 'biometric_session_token_v2',
          value: 'session-token',
        ),
      ).called(1);
      verify(
        () => storage.write(
          key: 'biometric_refresh_token_v2',
          value: 'refresh-token',
        ),
      ).called(1);
      verify(
        () => storage.write(key: 'biometric_enabled_v2', value: 'true'),
      ).called(1);
      verify(
        () => storage.write(key: 'biometric_setup_completed_v2', value: 'true'),
      ).called(1);
    });

    test(
      'isBiometricAvailable true only when supported and biometrics enabled',
      () async {
        when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        expect(await service.isBiometricAvailable(), isTrue);
      },
    );

    test('getAvailableBiometrics returns list from local_auth', () async {
      when(
        () => localAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.fingerprint]);
      final bio = await service.getAvailableBiometrics();
      expect(bio, [BiometricType.fingerprint]);
    });

    test('authenticate returns false when biometric not available', () async {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => false);
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => false);
      expect(await service.authenticate(), isFalse);
    });

    test(
      'authenticate returns true when local_auth authenticate succeeds',
      () async {
        when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          () => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        expect(await service.authenticate(localizedReason: 'Reason'), isTrue);
      },
    );

    test('isBiometricEnabled requires both enabled and setup flags', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
        final key = inv.namedArguments[#key] as String;
        return switch (key) {
          'biometric_enabled_v2' => 'true',
          'biometric_setup_completed_v2' => 'true',
          _ => null,
        };
      });

      expect(await service.isBiometricEnabled(), isTrue);
    });

    test('hasCompletedSetup true only when setup flag true', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
        final key = inv.namedArguments[#key] as String;
        if (key == 'biometric_setup_completed_v2') return 'true';
        return null;
      });
      expect(await service.hasCompletedSetup(), isTrue);
    });

    test(
      'getSessionToken and validateStoredToken match stored token',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          if (key == 'biometric_session_token_v2') return 'session';
          return null;
        });
        expect(await service.getSessionToken(), 'session');
        expect(await service.validateStoredToken('session'), isTrue);
        expect(await service.validateStoredToken('other'), isFalse);
      },
    );

    test('getRefreshToken reads stored refresh token', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
        final key = inv.namedArguments[#key] as String;
        if (key == 'biometric_refresh_token_v2') return 'refresh';
        return null;
      });
      expect(await service.getRefreshToken(), 'refresh');
    });

    test(
      'getStoredEmail and getStoredPassword read stored credentials',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_email_v2' => 'a@b.com',
            'biometric_password_v2' => 'pw',
            _ => null,
          };
        });
        expect(await service.getStoredEmail(), 'a@b.com');
        expect(await service.getStoredPassword(), 'pw');
      },
    );

    test('hasStoredCredentials false when preference is false', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
        final key = inv.namedArguments[#key] as String;
        return switch (key) {
          'biometric_store_credentials_v2' => 'false',
          'biometric_email_v2' => 'a@b.com',
          'biometric_password_v2' => 'pw',
          _ => null,
        };
      });
      expect(await service.hasStoredCredentials(), isFalse);
    });

    test('getShouldStoreCredentials defaults to false when unset', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      expect(await service.getShouldStoreCredentials(), isFalse);
    });

    test('authenticate returns false when local_auth throws', () async {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        () => localAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenThrow(Exception('fail'));
      expect(await service.authenticate(localizedReason: 'Reason'), isFalse);
    });

    test(
      'getAvailableBiometrics returns empty list when local_auth throws',
      () async {
        when(
          () => localAuth.getAvailableBiometrics(),
        ).thenThrow(Exception('fail'));
        expect(await service.getAvailableBiometrics(), isEmpty);
      },
    );

    test('storage read errors return safe defaults', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenThrow(Exception('fail'));
      expect(await service.getSessionToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
      expect(await service.getStoredEmail(), isNull);
      expect(await service.getStoredPassword(), isNull);
      expect(await service.getShouldStoreCredentials(), isFalse);
      expect(await service.hasCompletedSetup(), isFalse);
    });

    test(
      'validateStoredTokens returns valid when refresh token exists',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_refresh_token_v2' => 'refresh',
            'biometric_session_token_v2' => null,
            'biometric_store_credentials_v2' => 'false',
            'biometric_email_v2' => null,
            'biometric_password_v2' => null,
            _ => null,
          };
        });

        final status = await service.validateStoredTokens();
        expect(status, BiometricTokenStatus.valid);
      },
    );

    test(
      'validateStoredTokens returns expired when only session token exists',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_refresh_token_v2' => null,
            'biometric_session_token_v2' => 'session',
            'biometric_store_credentials_v2' => 'false',
            'biometric_email_v2' => null,
            'biometric_password_v2' => null,
            _ => null,
          };
        });

        final status = await service.validateStoredTokens();
        expect(status, BiometricTokenStatus.expired);
      },
    );

    test(
      'validateStoredTokens returns noTokensWithCredentials when no tokens but credentials exist',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_refresh_token_v2' => null,
            'biometric_session_token_v2' => null,
            'biometric_store_credentials_v2' => 'true',
            'biometric_email_v2' => 'a@b.com',
            'biometric_password_v2' => 'pw',
            _ => null,
          };
        });

        final status = await service.validateStoredTokens();
        expect(status, BiometricTokenStatus.noTokensWithCredentials);
      },
    );

    test(
      'validateStoredTokens returns noTokens when no tokens and no credentials',
      () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_refresh_token_v2' => null,
            'biometric_session_token_v2' => null,
            'biometric_store_credentials_v2' => 'false',
            'biometric_email_v2' => null,
            'biometric_password_v2' => null,
            _ => null,
          };
        });

        final status = await service.validateStoredTokens();
        expect(status, BiometricTokenStatus.noTokens);
      },
    );

    test(
      'storeCredentials and hasStoredCredentials work with storage reads',
      () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        await service.storeCredentials('a@b.com', 'pw');

        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          return switch (key) {
            'biometric_store_credentials_v2' => 'true',
            'biometric_email_v2' => 'a@b.com',
            'biometric_password_v2' => 'pw',
            _ => null,
          };
        });

        expect(await service.hasStoredCredentials(), isTrue);
      },
    );

    test(
      'setShouldStoreCredentials writes preference and get reads it',
      () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        await service.setShouldStoreCredentials(true);
        verify(
          () => storage.write(
            key: 'biometric_store_credentials_v2',
            value: 'true',
          ),
        ).called(1);

        when(() => storage.read(key: any(named: 'key'))).thenAnswer((
          inv,
        ) async {
          final key = inv.namedArguments[#key] as String;
          if (key == 'biometric_store_credentials_v2') return 'true';
          return null;
        });
        expect(await service.getShouldStoreCredentials(), isTrue);
      },
    );

    test(
      'clearStoredCredentials deletes email/password and store flag',
      () async {
        when(
          () => storage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});
        await service.clearStoredCredentials();
        verify(
          () => storage.delete(key: 'biometric_store_credentials_v2'),
        ).called(1);
        verify(() => storage.delete(key: 'biometric_email_v2')).called(1);
        verify(() => storage.delete(key: 'biometric_password_v2')).called(1);
      },
    );

    test('disableBiometricAuth deletes enabled and session keys', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
      await service.disableBiometricAuth();

      verify(() => storage.delete(key: 'biometric_enabled_v2')).called(1);
      verify(() => storage.delete(key: 'biometric_session_token_v2')).called(1);
    });

    test(
      'clearBiometricData deletes tokens, flags, and stored credentials',
      () async {
        when(
          () => storage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});
        await service.clearBiometricData();

        verify(() => storage.delete(key: 'biometric_enabled_v2')).called(1);
        verify(
          () => storage.delete(key: 'biometric_session_token_v2'),
        ).called(1);
        verify(
          () => storage.delete(key: 'biometric_setup_completed_v2'),
        ).called(1);
        verify(
          () => storage.delete(key: 'biometric_refresh_token_v2'),
        ).called(1);
        verify(
          () => storage.delete(key: 'biometric_store_credentials_v2'),
        ).called(1);
        verify(() => storage.delete(key: 'biometric_email_v2')).called(1);
        verify(() => storage.delete(key: 'biometric_password_v2')).called(1);
      },
    );
  });
}
