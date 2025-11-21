import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('Library sort by author changes order', (tester) async {
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
      const Novel(
        id: 'n-3',
        title: 'Stars Above, Seas Below',
        author: 'M. Voyager',
        description: 'Exploring the cosmos and the depths of the ocean.',
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

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Initial sort by title (asc) should place 'Quiet City Nights' first.
    final quietPos = tester.getTopLeft(find.text('Quiet City Nights'));
    final starsPos = tester.getTopLeft(find.text('Stars Above, Seas Below'));
    final whisperPos = tester.getTopLeft(find.text('The Whispering Forest'));
    expect(quietPos.dy < starsPos.dy, isTrue);
    expect(starsPos.dy < whisperPos.dy, isTrue);

    // Change sort to Author and validate new first item.
    final dropdown = find.byType(DropdownButton);
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Tap 'Author' menu item.
    await tester.tap(find.text('Author').last);
    await tester.pumpAndSettle();

    final whisperPos2 = tester.getTopLeft(find.text('The Whispering Forest'));
    final quietPos2 = tester.getTopLeft(find.text('Quiet City Nights'));
    final starsPos2 = tester.getTopLeft(find.text('Stars Above, Seas Below'));
    // Now 'The Whispering Forest' (A. Storyteller) should be first.
    expect(whisperPos2.dy < quietPos2.dy, isTrue);
    expect(quietPos2.dy < starsPos2.dy, isTrue);
  });
}
