import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/state/providers.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Library shows Sign In when Supabase enabled and no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => true),
          supabaseSessionProvider.overrideWith((_) => null),
          authStateProvider.overrideWith((_) => const Stream.empty()),
          novelsProvider.overrideWith((_) async => const []),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Sign In'), findsOneWidget);
  });
}
