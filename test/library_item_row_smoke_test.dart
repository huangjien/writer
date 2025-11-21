import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/library/widgets/library_item_row.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  testWidgets('LibraryItemRow renders title and actions (mock mode)', (
    tester,
  ) async {
    const n = Novel(
      id: 'n-1',
      title: 'Quiet City Nights',
      author: 'L. Dreamer',
      description: 'Slice-of-life stories set in a peaceful city.',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Ensure motion settings are available
          motionSettingsProvider.overrideWith(
            (_) => MotionSettingsNotifier(null),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryItemRow(
              novel: n,
              isSupabaseEnabled: false,
              isSignedIn: false,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Quiet City Nights'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
