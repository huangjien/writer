import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/storage_service_provider.dart';

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

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          libraryNovelsProviderV2.overrideWith((ref) async {
            // artificial delay to show loading UI
            await Future<void>.delayed(const Duration(seconds: 1));
            return novels;
          }),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    // Pump short time to remain in loading state
    await tester.pump(const Duration(milliseconds: 100));

    // Skeleton header and placeholder tiles visible
    expect(find.text('Loading novels…'), findsOneWidget);
    final placeholders = find.byType(LibraryItemRowSkeleton);
    expect(placeholders, findsNWidgets(6));

    // After delay, actual content shows
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Loading novels…'), findsNothing);
    expect(find.text('A'), findsOneWidget);
  });
}
