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
      when(
        () => mockBiometricService.enableBiometricAuth(any()),
      ).thenAnswer((_) async {});

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
      when(
        () => mockSessionNotifier.setSessionId('token'),
      ).thenAnswer((_) async {});

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

      expect(
        () => notifier.enableBiometricAuth('token'),
        throwsA(isA<Exception>()),
      );
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

        expect(
          () => notifier.signInWithBiometrics(),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state, BiometricAuthState.failed);
        verifyNever(() => mockBiometricService.getSessionToken());
        verifyNever(() => mockSessionNotifier.setSessionId(any()));
      },
    );

    test('disableBiometricAuth success', () async {
      when(
        () => mockBiometricService.disableBiometricAuth(),
      ).thenAnswer((_) async {});

      await notifier.disableBiometricAuth();

      expect(notifier.state, BiometricAuthState.disabled);
    });

    test('clearBiometricData success', () async {
      when(
        () => mockBiometricService.clearBiometricData(),
      ).thenAnswer((_) async {});

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
        () => mockBiometricService.isBiometricAvailable(),
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
        () => mockBiometricService.isBiometricEnabled(),
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
}
