import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/novel.dart';

void main() {
  testWidgets('Search filter matches diacritics-insensitive titles', (
    tester,
  ) async {
    final novels = [
      const Novel(
        id: 'n1',
        title: 'Café',
        description: '',
        author: 'A',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n2',
        title: 'Cafe',
        description: '',
        author: 'B',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n3',
        title: 'Tea House',
        description: '',
        author: 'C',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockNovelsProvider.overrideWith((ref) async => novels)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter 'cafe' should match both 'Cafe' and 'Café'.
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'cafe');
    await tester.pumpAndSettle();

    expect(find.text('Cafe'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Tea House'), findsNothing);
  });
}
