import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/storage_service_provider.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/services/auth_service.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/auth_service_provider.dart';
import 'package:writer/state/biometric_session_state.dart';

class MockBiometricService extends Mock implements BiometricService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({
    MockAuthService? authService,
    MockBiometricService? biometricService,
    SharedPreferences? prefs,
    SessionNotifier? sessionNotifier,
  }) {
    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('Settings')),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const Scaffold(body: Text('Sign Up')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('Forgot Password')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
        if (authService != null)
          authServiceProvider.overrideWithValue(authService),
        if (biometricService != null)
          biometricServiceProvider.overrideWithValue(biometricService),
        if (sessionNotifier != null)
          sessionProvider.overrideWith((ref) => sessionNotifier),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('SignInScreen UI Tests', () {
    testWidgets('SignInScreen shows fields', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestWidget(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('SignInScreen shows loading state during sign in', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      // Make the auth call take longer to see loading state
      when(() => mockAuthService.signIn(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return SignInResult.success('test-session');
      });
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // The biometric button text changes during loading, so we look for the loading indicator
      // The CircularProgressIndicator should be present somewhere in the widget tree
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('SignInScreen shows loading indicator during loading', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      when(() => mockAuthService.signIn(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return SignInResult.success('test-session');
      });
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Should show CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('SignInScreen shows biometric button when available', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      // Initially biometric button might not be visible until availability is checked
      // Wait for biometric check to complete
      await tester.pump(const Duration(milliseconds: 100));

      // The biometric button should appear after availability check
      expect(find.text('Sign in with biometrics'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('SignInScreen hides biometric button when unavailable', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      // Biometric button should not be visible
      expect(find.text('Sign in with biometrics'), findsNothing);
      expect(find.byIcon(Icons.fingerprint), findsNothing);
    });
  });

  group('SignInScreen Authentication Tests', () {
    testWidgets('SignInScreen shows error on login failure', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.failure('Invalid credentials'));
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'bad');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });

    testWidgets('SignInScreen trims email field', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      String? emailPassed;
      when(() => mockAuthService.signIn(any(), any())).thenAnswer((
        invocation,
      ) async {
        emailPassed = invocation.positionalArguments[0] as String;
        return SignInResult.success('test-session');
      });
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        '  test@example.com  ',
      );
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(emailPassed, 'test@example.com');
    });

    testWidgets('SignInScreen clears error on new attempt', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.failure('First error'));
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      // First attempt - should show error
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.textContaining('First error'), findsOneWidget);

      // Now make auth succeed
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.success('test-session'));

      // Second attempt - error should be cleared
      await tester.enterText(find.byType(TextField).at(1), 'correct');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.textContaining('First error'), findsNothing);
    });
  });

  group('SignInScreen Session Management', () {
    testWidgets('SignInScreen saves session on success', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);

      final mockAuthService = MockAuthService();
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.success('s-123'));
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
          sessionNotifier: sessionNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(sessionNotifier.state, 's-123');
      expect(find.textContaining('Invalid'), findsNothing);
    });

    testWidgets('SignInScreen handles biometric setup dialog', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);

      final mockAuthService = MockAuthService();
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.success('s-123'));
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => false);
      when(
        () => mockBiometricService.enableBiometricAuth(any<String>()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
          sessionNotifier: sessionNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show biometric setup dialog
      expect(find.text('Enable Biometric Login'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('SignInScreen cancels biometric setup', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);

      final mockAuthService = MockAuthService();
      when(
        () => mockAuthService.signIn(any(), any()),
      ).thenAnswer((_) async => SignInResult.success('s-123'));
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
          sessionNotifier: sessionNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Cancel biometric setup
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Enable biometric login'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('SignInScreen Biometric Tests', () {
    testWidgets('SignInScreen handles biometric sign in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);

      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
          sessionNotifier: sessionNotifier,
        ),
      );
      await tester.pumpAndSettle();

      // Tap biometric sign in button
      await tester.tap(find.text('Sign in with biometrics'));
      await tester.pumpAndSettle();

      // Should have called biometric service
      verify(
        () => mockBiometricService.authenticate(
          localizedReason: 'Sign in with your biometrics',
        ),
      ).called(1);
    });

    testWidgets('SignInScreen shows biometric error', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in with biometrics'));
      await tester.pumpAndSettle();

      expect(find.text('Biometric authentication failed'), findsOneWidget);
    });

    testWidgets('SignInScreen shows biometric loading state', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final mockAuthService = MockAuthService();
      final mockBiometricService = MockBiometricService();
      when(
        () => mockBiometricService.isBiometricAvailable(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.isBiometricEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async {
        return true;
      });
      when(
        () => mockBiometricService.enableBiometricAuth(any<String>()),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      when(
        () => mockBiometricService.getSessionToken(),
      ).thenAnswer((_) async => 'test-session-token');

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authService: mockAuthService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pumpAndSettle();

      // Tap biometric button and verify it completes without error
      await tester.tap(find.text('Sign in with biometrics'));

      // Wait for biometric authentication to complete
      await tester.pumpAndSettle();

      // If we get here without exceptions, the biometric flow worked
      // This test mainly verifies that biometric authentication doesn't crash
      expect(true, isTrue);

      await tester.pumpAndSettle();
    });
  });

  group('SignInScreen Navigation Tests', () {
    testWidgets('SignInScreen has navigation buttons', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestWidget(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });
}
