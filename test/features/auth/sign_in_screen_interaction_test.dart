import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/providers.dart';

// Mocks
class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockAuth = MockGoTrueClient();
    // Register fallback value for AuthOptions if needed, though strict mocking is better
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [supabaseEnabledProvider.overrideWithValue(true)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SignInScreen(authClient: mockAuth),
      ),
    );
  }

  testWidgets('SignInScreen performs sign in on button press', (tester) async {
    // Setup success response
    when(
      () => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => MockAuthResponse());

    // Also mock refreshSession as it is called after sign in
    when(
      () => mockAuth.refreshSession(),
    ).thenAnswer((_) async => MockAuthResponse());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Find fields
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.pump();

    // Tap Sign In
    await tester.tap(find.byType(ElevatedButton));

    // Wait for async operations
    await tester.pumpAndSettle();

    verify(
      () => mockAuth.signInWithPassword(
        email: 'test@example.com',
        password: 'password',
      ),
    ).called(1);

    // Verify refreshSession is called
    verify(() => mockAuth.refreshSession()).called(1);
  });

  testWidgets('SignInScreen shows error on failure', (tester) async {
    // Setup failure
    when(
      () => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid login credentials'), findsOneWidget);
  });
}
