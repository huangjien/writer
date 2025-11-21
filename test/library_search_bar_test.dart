import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/library/widgets/library_search_bar.dart';

void main() {
  testWidgets('LibrarySearchBar shows hint and emits changes', (tester) async {
    final controller = TextEditingController();
    String? changed;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LibrarySearchBar(
            controller: controller,
            onChanged: (v) => changed = v,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Search by title…'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'quiet');
    await tester.pump();
    expect(changed, 'quiet');
  });
}
