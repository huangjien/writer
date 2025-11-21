import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('Empty state localization in Chinese', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Force empty novels list
          mockNovelsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Chinese empty-state copy is rendered
    expect(find.text('未找到小说。'), findsOneWidget);
  });
}
