import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/features/auth/forgot_password_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  testWidgets('ForgotPasswordScreen shows fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(
      find.widgetWithText(NeumorphicButton, 'Send Reset Link'),
      findsOneWidget,
    );
  });

  testWidgets('ForgotPasswordScreen success', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Success'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ForgotPasswordScreen(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.tap(find.widgetWithText(NeumorphicButton, 'Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.textContaining('reset link has been sent'), findsOneWidget);
    expect(
      find.widgetWithText(NeumorphicButton, 'Back to Sign In'),
      findsOneWidget,
    );
  });
}
