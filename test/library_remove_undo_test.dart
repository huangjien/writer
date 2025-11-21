import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('Remove hides item and undo restores it (offline)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'Quiet City Nights',
        author: 'L. Dreamer',
        description: 'Slice-of-life stories set in a peaceful city.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n-2',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockNovelsProvider.overrideWith((ref) async => novels)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Resolve async providers and list build
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Initial count shows all items
    expect(find.text('2 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsOneWidget);
    expect(find.text('The Whispering Forest'), findsOneWidget);

    // Tap remove icon on the first tile
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsWidgets);
    await tester.tap(deleteButtons.first);
    await tester.pump();
    // Ensure SnackBar fully animates in before interacting
    await tester.pumpAndSettle();

    // After local remove, count should update and one title hidden
    expect(find.text('1 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsNothing);
    expect(find.text('The Whispering Forest'), findsOneWidget);

    // SnackBar appears with Undo action
    expect(find.text('Removed from Library'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore
    await tester.tap(find.text('Undo'));
    // Allow state update and UI to settle after Undo
    await tester.pumpAndSettle();

    // Item visibility restored and count reset
    expect(find.text('2 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsOneWidget);
    expect(find.text('The Whispering Forest'), findsOneWidget);
  });
}
