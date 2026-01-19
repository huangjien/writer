import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/features/auth/reset_password_screen.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockStorageService implements StorageService {
  String? _sessionId;

  @override
  String? getString(String key) =>
      key == 'backend_session_id' ? _sessionId : null;

  @override
  Future<void> setString(String key, String? value) async {
    if (key == 'backend_session_id') {
      _sessionId = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    if (key == 'backend_session_id') {
      _sessionId = null;
    }
  }

  @override
  Set<String> getKeys() => {'backend_session_id'};
}

class MockSessionNotifier extends SessionNotifier {
  MockSessionNotifier(String? initial) : super(MockStorageService()) {
    state = initial;
  }
}

void main() {
  testWidgets('ResetPasswordScreen shows fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ResetPasswordScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Reset Password'), findsWidgets);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen validates match', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ResetPasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'pass1');
    await tester.enterText(find.byType(TextField).at(1), 'pass2');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen success', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Success'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith((ref) => MockSessionNotifier('s-123')),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ResetPasswordScreen(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'password');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Password updated successfully!'), findsOneWidget);
  });
}
