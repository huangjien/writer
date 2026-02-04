import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:writer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Integration Tests', () {
    testWidgets('App Startup and Authentication Error Handling', (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for the app to fully initialize
      await tester.pumpAndSettle(const Duration(seconds: 5));
  
      // Debug: Print current widget tree
      debugPrint('App state after startup');

      // Navigate to sign in screen if we see the "Sign in to sync" message
      final signInSyncText = find.text('Sign in to sync.');
      if (signInSyncText.evaluate().isNotEmpty) {
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
      }

      // Verify we're on the sign in screen
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);

      // Enter invalid test credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.pump();

      // Tap Login button
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify error handling: should either show error message or stay on login screen
      // This validates the app properly handles authentication failures
      final hasErrorMessage = find.byType(SnackBar).evaluate().isNotEmpty;
      final stillOnSignInScreen = find.byKey(const Key('email_field')).evaluate().isNotEmpty;
      
      expect(
        hasErrorMessage || stillOnSignInScreen,
        isTrue,
        reason: 'App should show error message or remain on login screen after failed authentication'
      );
    });

    testWidgets('Network Error Handling Test', (WidgetTester tester) async {
      // This test validates the app handles backend unavailability gracefully
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Navigate to sign in if needed
      final signInButton = find.text('Sign in');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton);
        await tester.pumpAndSettle();
      }
      
      // Verify we can navigate to the sign in screen even with backend issues
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      
      // Try to login (this will fail but should not crash the app)
      await tester.enterText(find.byKey(const Key('email_field')), 'network@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'testpass');
      await tester.pump();
      
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // App should remain functional (not crash)
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
