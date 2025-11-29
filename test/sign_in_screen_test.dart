import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  testWidgets(
    'SignInScreen shows disabled message when Supabase disabled',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(
        find.text(
          'Supabase is not configured. Authentication is disabled in this build.',
        ),
        findsOneWidget,
      );
    },
    skip: supabaseEnabled,
  );

  testWidgets('SignInScreen shows fields when Supabase enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SignInScreen(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  }, skip: !supabaseEnabled);
}
