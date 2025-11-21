import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/features/auth/sign_in_screen.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/l10n/app_localizations_en.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  testWidgets(
    'SignInScreen shows disabled message when Supabase not enabled',
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
      expect(find.text('Sign In'), findsNothing);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Password'), findsNothing);
      expect(
        find.text(AppLocalizationsEn().authDisabledInBuild),
        findsOneWidget,
      );
    },
    skip: supabaseEnabled,
  );

  testWidgets('SignInScreen renders inputs and button when enabled', (
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
    expect(find.byType(ElevatedButton), findsOneWidget);
  }, skip: !supabaseEnabled);
}
