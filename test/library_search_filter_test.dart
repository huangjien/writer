import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('Search filter matches diacritics-insensitive titles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
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
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
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
