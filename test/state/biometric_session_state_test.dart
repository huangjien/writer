import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/session_state.dart';

class MockBiometricService extends Mock implements BiometricService {}

class MockSessionNotifier extends Mock implements SessionNotifier {}

void main() {
  late BiometricSessionNotifier notifier;
  late MockBiometricService mockBiometricService;
  late MockSessionNotifier mockSessionNotifier;

  setUp(() {
    mockBiometricService = MockBiometricService();
    mockSessionNotifier = MockSessionNotifier();
    notifier = BiometricSessionNotifier(
      mockBiometricService,
      mockSessionNotifier,
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
        () => mockBiometricService.getSessionToken(),
      ).thenAnswer((_) async => null);

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      verifyNever(() => mockSessionNotifier.setSessionId(any()));
    });

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
  });
}
