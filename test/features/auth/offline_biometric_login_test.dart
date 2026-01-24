import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/services/auth_service.dart';
import 'package:writer/state/auth_service_provider.dart';

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
  Future<String?> getSessionToken() async => 'offline-session-token';

  @override
  Future<String?> getRefreshToken() async => null;
}

class MockStorageService extends Mock implements StorageService {
  @override
  String? getString(String key) => null;

  @override
  Future<void> setString(String key, String? value) async {}

  @override
  Future<void> remove(String key) async {}
}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<SignInResult> signIn(String email, String password) async {
    return SignInResult.success('mock-session-id');
  }
}

void main() {
  group('Offline Biometric Login', () {
    late ProviderContainer container;
    late MockBiometricService mockBiometricService;
    late MockStorageService mockStorageService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockBiometricService = MockBiometricService();
      mockStorageService = MockStorageService();
      mockAuthService = MockAuthService();

      container = ProviderContainer(
        overrides: [
          biometricServiceProvider.overrideWithValue(mockBiometricService),
          storageServiceProvider.overrideWithValue(mockStorageService),
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('allows login when offline using biometrics', (tester) async {
      // Setup Router
      final router = GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Home Screen')),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) => const SignInScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Wait for biometric availability check to complete
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify we are on login screen
      expect(find.byType(SignInScreen), findsOneWidget);

      // Verify buttons are present
      expect(find.text('Sign in with biometrics'), findsOneWidget);

      // Verify initial session state is null
      expect(container.read(sessionProvider), isNull);

      // Verify session token is set
      // Tap Biometric Sign In using exact text from debug output
      await tester.tap(find.text('Sign in with biometrics'));
      await tester.pumpAndSettle();

      // Verify successful navigation to home (default success route)
      expect(find.text('Home Screen'), findsOneWidget);

      // Verify session token is set
      expect(container.read(sessionProvider), 'offline-session-token');
    });
  });
}
