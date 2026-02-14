import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Library shows Sign In when Supabase enabled and no session', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    // Don't set session ID to simulate no session

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((_) async => const []),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsWidgets);
  });
}
