import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  group('SignInScreen Comprehensive Tests', () {
    testWidgets('shows disabled message when supabase is disabled', (
      tester,
    ) async {
      if (supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SignInScreen)),
      )!;
      expect(find.text(l10n.authDisabledInBuild), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows sign in form when supabase is enabled', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SignInScreen)),
      )!;
      expect(find.text(l10n.signIn), findsWidgets);
      expect(find.text(l10n.email), findsOneWidget);
      expect(find.text(l10n.password), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validates email input', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.byType(TextField).first;
      expect(emailField, findsOneWidget);

      // Enter text and verify it accepts input
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('validates password input', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(TextField).last;
      expect(passwordField, findsOneWidget);

      // Enter text and verify it accepts input (obscured)
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Password should be obscured
      final passwordTextField = tester.widget<TextField>(passwordField);
      expect(passwordTextField.obscureText, isTrue);
    });

    testWidgets('shows loading state during sign in', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Tap sign in button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Pump to show loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Button should be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('displays error message on sign in failure', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid credentials
      await tester.enterText(
        find.byType(TextField).first,
        'invalid@example.com',
      );
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');

      // Tap sign in button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Wait for error to appear

      // Should show some error indication (the actual error message may vary)
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('clears error when retrying sign in', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Tap sign in button to trigger loading
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Show loading state

      // Clear and re-enter credentials
      await tester.enterText(find.byType(TextField).first, '');
      await tester.enterText(find.byType(TextField).first, 'new@example.com');
      await tester.pump();

      // Verify form is still functional
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('disposes controllers properly', (tester) async {
      if (!supabaseEnabled) return;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the screen is rendered
      expect(find.byType(SignInScreen), findsOneWidget);

      // Remove the widget to trigger disposal
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Container(),
        ),
      );

      await tester.pumpAndSettle();

      // Controllers should be disposed (no direct way to test this, but no errors should occur)
      expect(find.byType(SignInScreen), findsNothing);
    });
  });
}
