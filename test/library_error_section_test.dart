import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/widgets/library_error_section.dart';

void main() {
  testWidgets('LibraryErrorSection shows error UI and reload button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LibraryErrorSection(error: 'Oops')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });
}
