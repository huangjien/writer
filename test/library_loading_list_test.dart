import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/library/widgets/library_loading_list.dart';

void main() {
  testWidgets('LibraryLoadingList shows skeleton items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(height: 400, child: LibraryLoadingList()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Loading novels…'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(6));
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
