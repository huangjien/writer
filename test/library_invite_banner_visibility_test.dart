import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Invite banner shows when signed out', (tester) async {
    final prefs = await SharedPreferences.getInstance();
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Use mock novels to avoid actual backend queries in test
          novelsProvider.overrideWith((ref) async => novels),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(LibraryScreen)),
    )!;
    expect(find.text(l10n.signInToSync), findsOneWidget);
    expect(find.text(l10n.signIn), findsWidgets);
  });
}
