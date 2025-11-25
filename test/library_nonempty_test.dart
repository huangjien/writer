import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('Library shows list, search filter, and disabled download', (
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

    // Allow async providers to resolve
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Mode banner and counts
    expect(find.text('Mode: Mock data'), findsOneWidget);
    expect(find.text('2 / 2 Novels'), findsOneWidget);

    // Search field present and filters to one item
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Quiet');
    await tester.pump();
    expect(find.text('1 / 2 Novels'), findsOneWidget);

    // Download IconButton present but disabled (Supabase disabled)
    final downloadButtons = find.byWidgetPredicate(
      (w) =>
          w is IconButton &&
          w.icon is Icon &&
          (w.icon as Icon).icon == Icons.download,
    );
    expect(downloadButtons, findsWidgets);
    final anyDisabled = downloadButtons.evaluate().any((e) {
      final w = e.widget as IconButton;
      return w.onPressed == null;
    });
    expect(anyDisabled, isTrue);
  });
}
