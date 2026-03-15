import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/auth/screens/sign_in_screen.dart';
import 'package:writer/features/auth/state/sign_in_state.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/services/auth_service.dart';
import 'package:writer/state/auth_service_provider.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';

class MockAuthService extends Mock implements AuthService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockSessionNotifier extends Mock implements SessionNotifier {}

class FakeSignInState extends SignInState {
  const FakeSignInState({
    super.error,
    super.isLoading = false,
    super.obscurePassword = true,
    super.isBiometricLoading = false,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockBiometricService mockBiometricService;
  late MockSessionNotifier mockSessionNotifier;

  setUp(() {
    mockAuthService = MockAuthService();
    mockBiometricService = MockBiometricService();
    mockSessionNotifier = MockSessionNotifier();

    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => false);
  });

  Widget createTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        sessionProvider.overrideWith((ref) => mockSessionNotifier),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('SignInScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
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
}
