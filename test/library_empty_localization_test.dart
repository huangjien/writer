import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('Empty state localization in Chinese', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryNovelsProviderV2.overrideWith((ref) async => const []),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
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
