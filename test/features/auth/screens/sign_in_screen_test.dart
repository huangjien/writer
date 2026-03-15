import 'dart:async';

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
          )..state = BiometricAuthState.disabled,
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
            GoRoute(
              path: '/signup',
              builder: (context, state) =>
                  const Scaffold(body: Text('Sign Up')),
            ),
            GoRoute(
              path: '/forgot-password',
              builder: (context, state) =>
                  const Scaffold(body: Text('Forgot Password')),
            ),
          ],
        ),
      ),
    );
  }

  group('SignInScreen - Basic UI', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('shows sign up and forgot password buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign Up'), findsOneWidget);
      expect(find.textContaining('Forgot Password'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      final visibilityButton = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('SignInScreen - Sign In Flow', () {
    testWidgets('shows loading indicator during sign in', (tester) async {
      final completer = Completer<SignInResult>();

      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(
        const SignInResult(success: false, errorMessage: 'Error'),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when sign in fails', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(
          success: false,
          errorMessage: 'Invalid credentials',
        ),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });

    testWidgets('navigates to dashboard on successful sign in', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(
        createTestWidget(child: const SignInScreen(), initialLocation: '/'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockStorageService.setString('backend_session_id', 'session123'),
      ).called(1);
    });

    testWidgets('clears password on successful sign in', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, 'password');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      );
      expect(textField.controller?.text, isEmpty);
    });
  });

  group('SignInScreen - Biometric Authentication', () {
    testWidgets('shows biometric sign in button when available', (
      tester,
    ) async {
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith((ref) => AuthRedirectNotifier()),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign in with biometrics'), findsOneWidget);
    });

    testWidgets('does not show biometric button when unavailable', (
      tester,
    ) async {
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith((ref) => AuthRedirectNotifier()),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign in with biometrics'), findsNothing);
    });

    testWidgets('shows error when biometric authentication fails', (
      tester,
    ) async {
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);

      // Mock authenticate to return false (authentication failed) - use any() for optional parameter
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      // Mock authService.refresh() to prevent errors during token refresh attempts
      when(() => mockAuthService.refresh(any())).thenAnswer(
        (_) async =>
            const SignInResult(success: false, errorMessage: 'Refresh failed'),
      );

      // Mock token validation methods to prevent null errors
      when(
        () => mockBiometricService.hasStoredCredentials(),
      ).thenAnswer((_) async => false);
      when(
        () => mockBiometricService.validateStoredTokens(),
      ).thenAnswer((_) async => BiometricTokenStatus.valid);
      when(
        () => mockBiometricService.getRefreshToken(),
      ).thenAnswer((_) async => 'fake_refresh_token');
      when(
        () => mockBiometricService.getSessionToken(),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith((ref) => AuthRedirectNotifier()),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final biometricButton = find.textContaining('Sign in with biometrics');
      expect(biometricButton, findsOneWidget);
      await tester.tap(biometricButton);
      await tester.pumpAndSettle();

      // Should show error when authentication fails
      expect(
        find.textContaining('Biometric authentication failed'),
        findsOneWidget,
      );
    });
  });

  group('SignInScreen - Navigation', () {
    testWidgets('navigates to sign up screen', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      final signUpButton = find.textContaining('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('navigates to forgot password screen', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      final forgotPasswordButton = find.textContaining('Forgot Password');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
    });
  });

  group('SignInScreen - Form Validation', () {
    testWidgets('submits form with email and password', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockAuthService.signIn('test@example.com', 'password123'),
      ).called(1);
    });

    testWidgets('trims email before submission', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        '  test@example.com  ',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockAuthService.signIn('test@example.com', 'password'),
      ).called(1);
    });
  });

  group('SignInScreen - Error Handling', () {
    testWidgets('displays error text in red', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(
          success: false,
          errorMessage: 'Authentication failed',
        ),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      final errorFinder = find.textContaining('Authentication failed');
      expect(errorFinder, findsOneWidget);

      final errorWidget = tester.widget<Text>(errorFinder);
      expect(errorWidget.style?.color, Colors.red);
    });

    testWidgets('clears error on new sign in attempt', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async =>
            const SignInResult(success: false, errorMessage: 'First error'),
      );

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('First error'), findsOneWidget);

      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async =>
            const SignInResult(success: false, errorMessage: 'Second error'),
      );

      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('First error'), findsNothing);
      expect(find.textContaining('Second error'), findsOneWidget);
    });
  });

  group('SignInScreen - Redirect Handling', () {
    testWidgets('navigates to dashboard when no redirect present', (
      tester,
    ) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(
        ProviderScope(
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
                SessionNotifier(mockStorageService),
                mockAuthService,
              )..state = BiometricAuthState.unavailable,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/signin',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Dashboard')),
                ),
                GoRoute(
                  path: '/signin',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('sanitizes redirect URL with scheme', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith(
              (ref) => AuthRedirectNotifier()..state = 'https://evil.com',
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorageService),
            ),
            biometricSessionProvider.overrideWith(
              (ref) => BiometricSessionNotifier(
                mockBiometricService,
                SessionNotifier(mockStorageService),
                mockAuthService,
              )..state = BiometricAuthState.unavailable,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/signin',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Dashboard')),
                ),
                GoRoute(
                  path: '/signin',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('sanitizes redirect to auth routes', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith(
              (ref) => AuthRedirectNotifier()..state = '/auth',
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorageService),
            ),
            biometricSessionProvider.overrideWith(
              (ref) => BiometricSessionNotifier(
                mockBiometricService,
                SessionNotifier(mockStorageService),
                mockAuthService,
              )..state = BiometricAuthState.unavailable,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/signin',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Dashboard')),
                ),
                GoRoute(
                  path: '/signin',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('navigates to safe redirect path', (tester) async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer(
        (_) async => const SignInResult(success: true, sessionId: 'session123'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
            storageServiceProvider.overrideWithValue(mockStorageService),
            authRedirectProvider.overrideWith(
              (ref) => AuthRedirectNotifier()..state = '/novels/123',
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorageService),
            ),
            biometricSessionProvider.overrideWith(
              (ref) => BiometricSessionNotifier(
                mockBiometricService,
                SessionNotifier(mockStorageService),
                mockAuthService,
              )..state = BiometricAuthState.unavailable,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SignInScreen(),
                ),
                GoRoute(
                  path: '/novels/:novelId',
                  builder: (context, state) => Scaffold(
                    body: Text('Novel ${state.pathParameters["novelId"]}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.text('Novel 123'), findsOneWidget);
    });
  });

  group('SignInScreen - Biometric Setup Dialog', () {
    testWidgets(
      'shows biometric setup dialog after successful sign in with tokens',
      (tester) async {
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

        await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
        await tester.pumpAndSettle();

        // Wait for biometric availability check to complete
        await tester.pump(const Duration(milliseconds: 200));

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password',
        );
        await tester.tap(find.byKey(const Key('sign_in_button')));
        await tester.pumpAndSettle();

        expect(find.text('Enable Biometric Login'), findsOneWidget);
      },
    );

    testWidgets('cancels biometric setup dialog', (tester) async {
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
        ProviderScope(
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
              )..state = BiometricAuthState.disabled,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/signin',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Dashboard')),
                ),
                GoRoute(
                  path: '/signin',
                  builder: (context, state) => const SignInScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Wait for biometric availability check to complete
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('enables biometric auth without storing credentials', (
      tester,
    ) async {
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
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.enableBiometricAuth(
          any(),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockBiometricService.storeCredentials(any(), any()),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      // Wait for biometric availability check to complete
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => mockBiometricService.enableBiometricAuth(
          'session123',
          refreshToken: 'refresh123',
        ),
      ).called(1);
      verifyNever(() => mockBiometricService.storeCredentials(any(), any()));
    });

    testWidgets('enables biometric auth with storing credentials', (
      tester,
    ) async {
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
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.enableBiometricAuth(
          any(),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockBiometricService.storeCredentials(any(), any()),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      // Wait for biometric availability check to complete
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => mockBiometricService.storeCredentials(
          'test@example.com',
          'password',
        ),
      ).called(1);
    });

    testWidgets('shows error when biometric enable fails', (tester) async {
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
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.enableBiometricAuth(
          any(),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenThrow(Exception('Storage Error'));

      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      // Wait for biometric availability check to complete
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception: Storage Error'), findsOneWidget);
    });
  });
}
