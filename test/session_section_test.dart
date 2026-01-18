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

  testWidgets('SessionSection banner cancel hides MaterialBanner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SessionSection(isSignedIn: false)),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialBanner), findsOneWidget);

    final cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancel'),
    );
    cancelButton.onPressed!.call();
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('SessionSection hides banner on sign-in update', (tester) async {
    var signedIn = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  SessionSection(isSignedIn: signedIn),
                  TextButton(
                    onPressed: () => setState(() => signedIn = true),
                    child: const Text('Toggle'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(MaterialBanner), findsOneWidget);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);
  });
}
