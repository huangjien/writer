import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('Library shows empty state when no novels found', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // Override mockNovelsProvider to return empty list.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          libraryNovelsProvider.overrideWith((ref) async => const []),
          memberNovelsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    // Allow async providers to resolve
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('No novels found.'), findsOneWidget);
  });
}
