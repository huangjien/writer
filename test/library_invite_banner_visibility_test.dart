import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';

void main() {
  testWidgets('Invite banner shows when signed out', (tester) async {
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
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Use mock novels to avoid actual backend queries in test
          novelsProvider.overrideWith((ref) async => novels),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Banner is shown via post-frame callback
    await tester.pump();

    // Expect a single MaterialBanner with the sign-in prompt (scoped to banner)
    final bannerFinder = find.byType(MaterialBanner);
    expect(bannerFinder, findsOneWidget);
    final bannerContentFinder = find.descendant(
      of: bannerFinder,
      matching: find.text(
        AppLocalizations.of(tester.element(bannerFinder))!.signInToSync,
      ),
    );
    expect(bannerContentFinder, findsOneWidget);

    // Pump again; banner should not duplicate
    await tester.pump();
    expect(bannerFinder, findsOneWidget);
  });
}
