import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/library/my_novels_screen.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('MyNovelsScreen shows sign-in prompt when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in to sync progress across devices.'), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
  });
}
