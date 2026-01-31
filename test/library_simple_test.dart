import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('Library screen renders without hanging', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Authentication providers
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(LocalStorageService(prefs)),
          ),
          isSignedInProvider.overrideWith((ref) => false),
          isAdminProvider.overrideWith((ref) => false),
          adminModeProvider.overrideWith((ref) => AdminModeNotifier(prefs)),

          // Library providers
          libraryNovelsProviderV2.overrideWith((ref) async => const []),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          removedNovelIdsProvider.overrideWith((ref) => <String>{}),
          motionSettingsProvider.overrideWith(
            (ref) => MotionSettingsNotifier(prefs),
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

    await tester.pump(const Duration(milliseconds: 100));
  });
}
