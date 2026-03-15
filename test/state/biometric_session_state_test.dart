import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/auth_service.dart';

class MockBiometricService extends Mock implements BiometricService {}

class MockSessionNotifier extends Mock implements SessionNotifier {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late BiometricSessionNotifier notifier;
  late MockBiometricService mockBiometricService;
  late MockSessionNotifier mockSessionNotifier;
  late MockAuthService mockAuthService;

  setUp(() {
    mockBiometricService = MockBiometricService();
    mockSessionNotifier = MockSessionNotifier();
    mockAuthService = MockAuthService();
    notifier = BiometricSessionNotifier(
      mockBiometricService,
      mockSessionNotifier,
      mockAuthService,
    );
  });

  group('BiometricSessionNotifier', () {
    test('initial state is disabled', () {
      expect(notifier.state, BiometricAuthState.disabled);
    });

    test(
      'checkBiometricAvailability sets unavailable if service returns false',
      () async {
        when(
          () => mockBiometricService.isBiometricAvailable(),
        ).thenAnswer((_) async => false);

        await notifier.checkBiometricAvailability();

        expect(notifier.state, BiometricAuthState.unavailable);
      },
    );

    test(
      'checkBiometricAvailability sets enabled if service returns true and enabled',
      () async {
        when(
          () => mockBiometricService.isBiometricAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.isBiometricEnabled(),
        ).thenAnswer((_) async => true);

        await notifier.checkBiometricAvailability();

        expect(notifier.state, BiometricAuthState.enabled);
      },
    );

    test(
      'checkBiometricAvailability sets disabled if service returns true but not enabled',
      () async {
        when(
          () => mockBiometricService.isBiometricAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.isBiometricEnabled(),
        ).thenAnswer((_) async => false);

        await notifier.checkBiometricAvailability();

        expect(notifier.state, BiometricAuthState.disabled);
      },
    );

    test('enableBiometricAuth success', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockBiometricService.enableBiometricAuth(any())).thenAnswer((
        _,
      ) async {
        return;
      });

      final result = await notifier.enableBiometricAuth('token');

      expect(result, true);
      expect(notifier.state, BiometricAuthState.enabled);
      verify(() => mockBiometricService.enableBiometricAuth('token')).called(1);
    });

    test('enableBiometricAuth failure on auth', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      final result = await notifier.enableBiometricAuth('token');

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      verifyNever(() => mockBiometricService.enableBiometricAuth(any()));
    });

    test('signInWithBiometrics success', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => null);
      when(
        () => mockBiometricService.getSessionToken(),
      ).thenAnswer((_) async => 'token');
      when(() => mockSessionNotifier.setSessionId('token')).thenAnswer((
        _,
      ) async {
        return;
      });

      final result = await notifier.signInWithBiometrics();

      expect(result, true);
      expect(notifier.state, BiometricAuthState.authenticated);
      verify(() => mockSessionNotifier.setSessionId('token')).called(1);
    });

    test('signInWithBiometrics failure on token null', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.noTokens);

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.noTokens);
      verifyNever(() => mockSessionNotifier.setSessionId(any()));
    });

    test(
      'signInWithBiometrics failure when authenticate returns false',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => false);

        final result = await notifier.signInWithBiometrics();

        expect(result, false);
        expect(notifier.state, BiometricAuthState.failed);
        expect(notifier.lastErrorType, BiometricErrorType.authenticationFailed);
        verifyNever(() => mockBiometricService.getSessionToken());
        verifyNever(() => mockSessionNotifier.setSessionId(any()));
      },
    );

    test('enableBiometricAuth sets failed and rethrows on exception', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenThrow(Exception('boom'));

      try {
        await notifier.enableBiometricAuth('token');
        fail('Expected exception to be thrown');
      } on Exception {
        // Exception should be rethrown
      }
      expect(notifier.state, BiometricAuthState.failed);
      verifyNever(() => mockBiometricService.enableBiometricAuth(any()));
    });

    test(
      'signInWithBiometrics sets failed and rethrows on exception',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenThrow(Exception('boom'));

        try {
          await notifier.signInWithBiometrics();
          fail('Expected exception to be thrown');
        } on Exception {
          // Exception should be rethrown
        }
        expect(notifier.state, BiometricAuthState.failed);
        verifyNever(() => mockBiometricService.getSessionToken());
        verifyNever(() => mockSessionNotifier.setSessionId(any()));
      },
    );

    test('disableBiometricAuth success', () async {
      when(() => mockBiometricService.disableBiometricAuth()).thenAnswer((
        _,
      ) async {
        return;
      });

      await notifier.disableBiometricAuth();

      expect(notifier.state, BiometricAuthState.disabled);
    });

    test('clearBiometricData success', () async {
      when(() => mockBiometricService.clearBiometricData()).thenAnswer((
        _,
      ) async {
        return;
      });

      await notifier.clearBiometricData();

      expect(notifier.state, BiometricAuthState.disabled);
    });

    test('resetState resets to disabled unless unavailable', () {
      notifier.state = BiometricAuthState.enabled;
      notifier.resetState();
      expect(notifier.state, BiometricAuthState.disabled);

      notifier.state = BiometricAuthState.unavailable;
      notifier.resetState();
      expect(notifier.state, BiometricAuthState.unavailable);
    });

    test('boolean getters reflect current state', () {
      notifier.state = BiometricAuthState.unavailable;
      expect(notifier.isBiometricAvailable, isFalse);

      notifier.state = BiometricAuthState.enabled;
      expect(notifier.isBiometricEnabled, isTrue);
      expect(notifier.isAuthenticating, isFalse);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.hasFailed, isFalse);

      notifier.state = BiometricAuthState.authenticating;
      expect(notifier.isAuthenticating, isTrue);

      notifier.state = BiometricAuthState.authenticated;
      expect(notifier.isAuthenticated, isTrue);

      notifier.state = BiometricAuthState.failed;
      expect(notifier.hasFailed, isTrue);
    });
  });

  group('biometric providers', () {
    test('biometricAvailableProvider reflects service value', () async {
      final mockBiometricService = MockBiometricService();
      when(
        mockBiometricService.isBiometricAvailable,
      ).thenAnswer((_) async => true);

      final container = ProviderContainer(
        overrides: [
          biometricServiceProvider.overrideWithValue(mockBiometricService),
        ],
      );
      addTearDown(container.dispose);

      final isAvailable = await container.read(
        biometricAvailableProvider.future,
      );
      expect(isAvailable, isTrue);
    });

    test('biometricEnabledProvider reflects service value', () async {
      final mockBiometricService = MockBiometricService();
      when(
        mockBiometricService.isBiometricEnabled,
      ).thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          biometricServiceProvider.overrideWithValue(mockBiometricService),
        ],
      );
      addTearDown(container.dispose);

      final isEnabled = await container.read(biometricEnabledProvider.future);
      expect(isEnabled, isFalse);
    });
  });

  group('BiometricSessionNotifier - Additional Coverage', () {
    test('signInWithBiometrics handles expired tokens', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.expired);
      when(
        () => mockBiometricService.clearBiometricData(),
      ).thenAnswer((_) async {});

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.disabled);
      expect(notifier.lastErrorType, isNull);
      verify(() => mockBiometricService.clearBiometricData()).called(1);
    });

    test('signInWithBiometrics handles token validation error', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.error);

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.tokenError);
    });

    test('signInWithBiometrics handles refresh token success', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(() => mockAuthService.refresh('refresh_token')).thenAnswer(
        (_) async => const SignInResult(
          success: true,
          sessionId: 'new_session_id',
          refreshToken: 'new_refresh_token',
        ),
      );
      when(
        () => mockSessionNotifier.setSessionId('new_session_id'),
      ).thenAnswer((_) async {});
      when(
        () => mockSessionNotifier.setRefreshToken('new_refresh_token'),
      ).thenAnswer((_) async {});

      final result = await notifier.signInWithBiometrics();

      expect(result, true);
      expect(notifier.state, BiometricAuthState.authenticated);
      verify(
        () => mockSessionNotifier.setSessionId('new_session_id'),
      ).called(1);
      verify(
        () => mockSessionNotifier.setRefreshToken('new_refresh_token'),
      ).called(1);
    });

    test('signInWithBiometrics handles refresh token failure', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(() => mockAuthService.refresh('refresh_token')).thenAnswer(
        (_) async =>
            const SignInResult(success: false, errorMessage: 'Refresh failed'),
      );

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.tokensExpired);
      verifyNever(() => mockSessionNotifier.setSessionId(any()));
    });

    test('signInWithBiometrics handles refresh token exception', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(
        () => mockAuthService.refresh('refresh_token'),
      ).thenThrow(Exception('Network error'));

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.tokenError);
    });

    test(
      'signInWithBiometrics handles credential-based signin success',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.validateStoredTokens(),
        ).thenAnswer((_) async => BiometricTokenStatus.noTokensWithCredentials);
        when(
          () => mockBiometricService.getStoredEmail(),
        ).thenAnswer((_) async => 'test@example.com');
        when(
          () => mockBiometricService.getStoredPassword(),
        ).thenAnswer((_) async => 'password');
        when(
          () => mockAuthService.signIn('test@example.com', 'password'),
        ).thenAnswer(
          (_) async => const SignInResult(
            success: true,
            sessionId: 'new_session',
            refreshToken: 'new_refresh',
          ),
        );
        when(
          () => mockSessionNotifier.setSessionId('new_session'),
        ).thenAnswer((_) async {});
        when(
          () => mockSessionNotifier.setRefreshToken('new_refresh'),
        ).thenAnswer((_) async {});
        when(
          () => mockBiometricService.enableBiometricAuth(
            'new_session',
            refreshToken: 'new_refresh',
          ),
        ).thenAnswer((_) async {});

        final result = await notifier.signInWithBiometrics();

        expect(result, true);
        expect(notifier.state, BiometricAuthState.authenticated);
        verify(
          () => mockBiometricService.enableBiometricAuth(
            'new_session',
            refreshToken: 'new_refresh',
          ),
        ).called(1);
      },
    );

    test(
      'signInWithBiometrics handles credential-based signin with no credentials',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.validateStoredTokens(),
        ).thenAnswer((_) async => BiometricTokenStatus.noTokensWithCredentials);
        when(
          () => mockBiometricService.getStoredEmail(),
        ).thenAnswer((_) async => null);
        when(
          () => mockBiometricService.getStoredPassword(),
        ).thenAnswer((_) async => 'password');

        final result = await notifier.signInWithBiometrics();

        expect(result, false);
        expect(notifier.state, BiometricAuthState.failed);
        expect(notifier.lastErrorType, BiometricErrorType.noTokens);
        verifyNever(() => mockAuthService.signIn(any(), any()));
      },
    );

    test(
      'signInWithBiometrics handles credential-based signin with invalid credentials',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.validateStoredTokens(),
        ).thenAnswer((_) async => BiometricTokenStatus.noTokensWithCredentials);
        when(
          () => mockBiometricService.getStoredEmail(),
        ).thenAnswer((_) async => 'test@example.com');
        when(
          () => mockBiometricService.getStoredPassword(),
        ).thenAnswer((_) async => 'password');
        when(
          () => mockAuthService.signIn('test@example.com', 'password'),
        ).thenAnswer(
          (_) async => const SignInResult(
            success: false,
            errorMessage: 'Invalid credentials',
          ),
        );

        final result = await notifier.signInWithBiometrics();

        expect(result, false);
        expect(notifier.state, BiometricAuthState.failed);
        expect(notifier.lastErrorType, BiometricErrorType.credentialsInvalid);
      },
    );

    test(
      'signInWithBiometrics handles credential-based signin with exception',
      () async {
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.validateStoredTokens(),
        ).thenAnswer((_) async => BiometricTokenStatus.noTokensWithCredentials);
        when(
          () => mockBiometricService.getStoredEmail(),
        ).thenAnswer((_) async => 'test@example.com');
        when(
          () => mockBiometricService.getStoredPassword(),
        ).thenAnswer((_) async => 'password');
        when(
          () => mockAuthService.signIn('test@example.com', 'password'),
        ).thenThrow(Exception('Network error'));

        final result = await notifier.signInWithBiometrics();

        expect(result, false);
        expect(notifier.state, BiometricAuthState.failed);
        expect(notifier.lastErrorType, BiometricErrorType.technicalError);
      },
    );

    test('signInWithBiometrics handles session token with exception', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => null);
      when(
        () => mockBiometricService.getSessionToken(),
      ).thenAnswer((_) async => 'session_token');
      when(
        () => mockSessionNotifier.setSessionId('session_token'),
      ).thenThrow(Exception('Session error'));

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.technicalError);
    });

    test('disableBiometricAuthDueToExpiration clears data', () async {
      notifier.state = BiometricAuthState.authenticated;
      when(
        () => mockBiometricService.clearBiometricData(),
      ).thenAnswer((_) async {});

      await notifier.disableBiometricAuthDueToExpiration();

      expect(notifier.state, BiometricAuthState.disabled);
      verify(() => mockBiometricService.clearBiometricData()).called(1);
    });

    test('disableBiometricAuthDueToExpiration handles error', () async {
      notifier.state = BiometricAuthState.authenticated;
      when(
        () => mockBiometricService.clearBiometricData(),
      ).thenThrow(Exception('Clear error'));

      await notifier.disableBiometricAuthDueToExpiration();

      expect(notifier.state, BiometricAuthState.failed);
    });

    test('disableBiometricAuth handles error', () async {
      notifier.state = BiometricAuthState.enabled;
      when(
        () => mockBiometricService.disableBiometricAuth(),
      ).thenThrow(Exception('Disable error'));

      await notifier.disableBiometricAuth();

      expect(notifier.state, BiometricAuthState.failed);
    });

    test('clearBiometricData handles error', () async {
      notifier.state = BiometricAuthState.enabled;
      when(
        () => mockBiometricService.clearBiometricData(),
      ).thenThrow(Exception('Clear error'));

      await notifier.clearBiometricData();

      expect(notifier.state, BiometricAuthState.failed);
    });

    test('enableBiometricAuth with refresh token', () async {
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.enableBiometricAuth(
          'token',
          refreshToken: 'refresh',
        ),
      ).thenAnswer((_) async {});

      final result = await notifier.enableBiometricAuth(
        'token',
        refreshToken: 'refresh',
      );

      expect(result, true);
      expect(notifier.state, BiometricAuthState.enabled);
      verify(
        () => mockBiometricService.enableBiometricAuth(
          'token',
          refreshToken: 'refresh',
        ),
      ).called(1);
    });
  });
}
