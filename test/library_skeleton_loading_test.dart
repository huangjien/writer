import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('Library shows skeleton loading while fetching novels', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'A',
        author: 'X',
        description: 'd',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mockNovelsProvider.overrideWith((ref) async {
            // artificial delay to show loading UI
            await Future<void>.delayed(const Duration(seconds: 1));
            return novels;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Pump short time to remain in loading state
    await tester.pump(const Duration(milliseconds: 100));

    // Skeleton header and placeholder tiles visible
    expect(find.text('Loading novels…'), findsOneWidget);
    final tiles = find.byType(ListTile);
    expect(tiles, findsNWidgets(6));

    // After delay, actual content shows
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Loading novels…'), findsNothing);
    expect(find.text('A'), findsOneWidget);
  });
}
