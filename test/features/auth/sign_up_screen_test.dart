import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/features/auth/screens/sign_up_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  testWidgets('SignUpScreen shows fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignUpScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(
      find.widgetWithText(NeumorphicButton, 'Create Account'),
      findsOneWidget,
    );
  });

  testWidgets('SignUpScreen handles error', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'detail': 'Email already exists'}),
        400,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignUpScreen(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.widgetWithText(NeumorphicButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Email already exists'), findsOneWidget);
  });

  testWidgets('SignUpScreen handles success', (tester) async {
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignUpScreen(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.widgetWithText(NeumorphicButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Account created!'), findsOneWidget);
    expect(
      find.widgetWithText(NeumorphicButton, 'Back to Sign In'),
      findsOneWidget,
    );
  });
}
