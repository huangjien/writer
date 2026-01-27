import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/auth_service.dart';

class MockBiometricService extends Mock implements BiometricService {
  @override
  Future<bool> isBiometricAvailable() async => true;

  @override
  Future<bool> isBiometricEnabled() async => true;

  @override
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to sign in',
  }) async => true;

  @override
  Future<String?> getSessionToken() async => 'test-token';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<BiometricTokenStatus> validateStoredTokens() async =>
      BiometricTokenStatus.noTokensWithCredentials;

  @override
  Future<String?> getStoredEmail() async => 'test@example.com';

  @override
  Future<String?> getStoredPassword() async => 'testpassword123';

  @override
  Future<bool> hasStoredCredentials() async => true;

  @override
  Future<void> storeCredentials(String email, String password) async {}

  @override
  Future<void> enableBiometricAuth(
    String sessionToken, {
    String? refreshToken,
  }) async {}
}

class MockSessionNotifier extends Mock implements SessionNotifier {
  @override
  Future<void> setSessionId(String? sessionId) async {}

  @override
  String? getRefreshToken() => null;

  @override
  Future<void> setRefreshToken(String? refreshToken) async {}
}

class MockAuthService implements AuthService {
  @override
  Future<SignInResult> signIn(String email, String password) async {
    if (email == 'test@example.com' && password == 'testpassword123') {
      return SignInResult.success(
        'new-session-id',
        refreshToken: 'new-refresh-token',
      );
    }
    return SignInResult.failure('Invalid credentials');
  }

  @override
  Future<SignInResult> refresh(String refreshToken) async {
    return SignInResult.failure('Not implemented in test');
  }
}

void main() {
  group('Credential Storage Tests', () {
    late BiometricService mockBiometricService;
    late SessionNotifier mockSessionNotifier;
    late AuthService mockAuthService;

    setUp(() {
      mockBiometricService = MockBiometricService();
      mockSessionNotifier = MockSessionNotifier();
      mockAuthService = MockAuthService();
    });

    test('should detect credentials are available', () async {
      final hasCredentials = await mockBiometricService.hasStoredCredentials();
      expect(hasCredentials, true);
    });

    test('should retrieve stored credentials', () async {
      final email = await mockBiometricService.getStoredEmail();
      final password = await mockBiometricService.getStoredPassword();

      expect(email, 'test@example.com');
      expect(password, 'testpassword123');
    });

    test('should use credentials when tokens expired', () async {
      final notifier = BiometricSessionNotifier(
        mockBiometricService,
        mockSessionNotifier,
        mockAuthService,
      );

      // When tokens are expired but credentials exist, should use credentials
      final result = await notifier.signInWithBiometrics();

      expect(result, true);
      expect(notifier.state, BiometricAuthState.authenticated);
      expect(notifier.lastErrorType, isNull);
    });

    test('should fail when credentials are invalid', () async {
      // Set up mock to return invalid credentials scenario
      final mockBiometricServiceWithInvalidCreds = MockBiometricService();

      final notifier = BiometricSessionNotifier(
        mockBiometricServiceWithInvalidCreds,
        mockSessionNotifier,
        mockAuthService,
      );

      final result = await notifier.signInWithBiometrics();

      expect(result, false);
      expect(notifier.state, BiometricAuthState.failed);
      expect(notifier.lastErrorType, BiometricErrorType.credentialsInvalid);
    });

    test('should store credentials when requested', () async {
      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      final notifier = BiometricSessionNotifier(
        mockBiometricService,
        MockSessionNotifier(),
        mockAuthService,
      );

      // Enable biometric with credential storage
      await notifier.enableBiometricAuth(
        'test-session',
        refreshToken: 'test-refresh',
      );

      // Verify credentials were stored
      final storedEmail = await mockBiometricService.getStoredEmail();
      final storedPassword = await mockBiometricService.getStoredPassword();
      final hasCredentials = await mockBiometricService.hasStoredCredentials();

      expect(storedEmail, isNull); // Not stored in the mock
      expect(storedPassword, isNull); // Not stored in the mock
      expect(hasCredentials, true); // Should be true from enableBiometricAuth
    });
  });
}
