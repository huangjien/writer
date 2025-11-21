import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('Library shows empty state when no novels found', (tester) async {
    SharedPreferences.setMockInitialValues({});
    // Override mockNovelsProvider to return empty list.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockNovelsProvider.overrideWith((ref) async => const [])],
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

    expect(find.text('No novels found.'), findsOneWidget);
  });
}
