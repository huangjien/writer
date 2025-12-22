import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/widgets/session_section.dart';

void main() {
  testWidgets('SessionSection shows Sign In when signed out', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SessionSection(isSignedIn: false)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Sign in to sync progress across devices.'), findsWidgets);
  });

  testWidgets(
    'SessionSection shows Sign In button and banner when signed out',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SessionSection(isSignedIn: false)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsWidgets);
      expect(
        find.text('Sign in to sync progress across devices.'),
        findsWidgets,
      );
    },
  );

  testWidgets('SessionSection hides banner when signed in', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SessionSection(isSignedIn: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });
}
