import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/biometric_session_state.dart';

class MockBiometricService extends Mock implements BiometricService {}

class _OpenSignIn extends StatelessWidget {
  const _OpenSignIn({required this.client});
  final http.Client client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Root'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignInScreen(client: client),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('SignInScreen shows fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('SignInScreen shows error on login failure', (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/auth/login') {
        return http.Response('{"detail":"Invalid credentials"}', 401);
      }
      return http.Response('not found', 404);
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'bad');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid credentials'), findsOneWidget);
  });

  testWidgets('SignInScreen saves session and pops on success', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sessionNotifier = SessionNotifier(prefs);

    final mockBiometricService = MockBiometricService();
    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => false);

    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => sessionNotifier),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
      ],
    );
    addTearDown(container.dispose);

    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/auth/login') {
        return http.Response('{"session_id":"s-123"}', 200);
      }
      return http.Response('not found', 404);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _OpenSignIn(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Root'), findsOneWidget);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Root'), findsOneWidget);
    expect(container.read(sessionProvider), 's-123');
  });
}
