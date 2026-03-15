import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/auth/screens/sign_in_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/services/auth_service.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/auth_service_provider.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/models/biometric_session_state.dart';
import 'package:writer/state/redirect_provider.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockAuthService extends Mock implements AuthService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockBiometricService mockBiometricService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockBiometricService = MockBiometricService();
    mockStorageService = MockStorageService();

    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => false);

    when(() => mockStorageService.getKeys()).thenReturn({});
    when(() => mockStorageService.getString(any())).thenReturn(null);
    when(
      () => mockStorageService.setString(any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockStorageService.remove(any())).thenAnswer((_) async => true);
    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => false);
    when(
      () => mockBiometricService.isBiometricEnabled(),
    ).thenAnswer((_) async => false);
  });

  Widget createTestWidget({
    required Widget child,
    String initialLocation = '/',
    BiometricAuthState initialBiometricState = BiometricAuthState.disabled,
  }) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        storageServiceProvider.overrideWithValue(mockStorageService),
        authRedirectProvider.overrideWith((ref) => AuthRedirectNotifier()),
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(mockStorageService),
        ),
        biometricSessionProvider.overrideWith(
          (ref) => BiometricSessionNotifier(
            mockBiometricService,
            ref.read(sessionProvider.notifier),
            mockAuthService,
          )..state = initialBiometricState,
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: initialLocation,
          routes: [
            GoRoute(path: '/', builder: (context, state) => child),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard')),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('debug biometric state during sign in', (tester) async {
    when(() => mockAuthService.signIn(any(), any())).thenAnswer(
      (_) async => const SignInResult(
        success: true,
        sessionId: 'session123',
        refreshToken: 'refresh123',
      ),
    );
    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => true);
    when(
      () => mockBiometricService.isBiometricEnabled(),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(
      createTestWidget(
        child: const SignInScreen(),
        initialBiometricState: BiometricAuthState.disabled,
      ),
    );
    await tester.pumpAndSettle();

    // Wait for biometric availability check to complete
    await tester.pump(const Duration(milliseconds: 200));

    // Enter credentials and sign in
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'password');

    // Tap sign in button
    await tester.tap(find.byKey(const Key('sign_in_button')));
    await tester.pump();

    // Wait for async operations to complete
    debugPrint('Before first pumpAndSettle');
    await tester.pumpAndSettle();
    debugPrint('After first pumpAndSettle');

    // Wait for session/token operations
    await tester.pumpAndSettle(const Duration(seconds: 1));
    debugPrint('After second pumpAndSettle');

    // Wait for biometric check
    await tester.pumpAndSettle(const Duration(seconds: 1));
    debugPrint('After third pumpAndSettle');

    // Final wait for dialog
    await tester.pumpAndSettle(const Duration(seconds: 1));
    debugPrint('After fourth pumpAndSettle');

    // Try to find the dialog
    final dialogFinder = find.text('Enable Biometric Login');
    debugPrint('Dialog found: ${dialogFinder.evaluate().isNotEmpty}');

    // Check biometric state
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignInScreen)),
    );
    final biometricState = container.read(biometricSessionProvider);
    debugPrint('Final biometric state: $biometricState');

    expect(dialogFinder, findsOneWidget);
  });
}
