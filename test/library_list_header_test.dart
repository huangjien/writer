import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/library/widgets/library_list_header.dart';

void main() {
  testWidgets('LibraryListHeader shows count and changes sort', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LibraryListHeader(
            visibleCount: 1,
            totalCount: 3,
            sortValue: 'titleAsc',
            onSortChanged: (v) => selected = v,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 / 3 Novels'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sortDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Author'));
    await tester.pump();
    expect(selected, 'authorAsc');
  });
}
