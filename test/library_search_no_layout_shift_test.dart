import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Changing sort does not cause list height layout shift', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final novels = [
      const Novel(
        id: 'n1',
        title: 'Alpha',
        description: '',
        author: 'Zed',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n2',
        title: 'Beta',
        description: '',
        author: 'Ann',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n3',
        title: 'Gamma',
        description: '',
        author: 'Bob',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(false),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Capture list height before sort changes.
    final listFinder = find.byKey(const Key('libraryListView'));
    expect(listFinder, findsOneWidget);
    final beforeSize = tester.getSize(listFinder);

    // Change sort to Author.
    final sortDropdown = find.byKey(const Key('sortDropdown'));
    expect(sortDropdown, findsOneWidget);
    await tester.tap(sortDropdown);
    await tester.pump();
    await tester.tap(
      find
          .text(AppLocalizations.of(tester.element(sortDropdown))!.authorLabel)
          .last,
    );
    await tester.pumpAndSettle();

    final afterSize1 = tester.getSize(listFinder);
    expect(afterSize1.height, equals(beforeSize.height));

    // Change sort to Title.
    await tester.tap(sortDropdown);
    await tester.pump();
    await tester.tap(
      find
          .text(AppLocalizations.of(tester.element(sortDropdown))!.titleLabel)
          .last,
    );
    await tester.pumpAndSettle();

    final afterSize2 = tester.getSize(listFinder);
    expect(afterSize2.height, equals(beforeSize.height));
  });
}
