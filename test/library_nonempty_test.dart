import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:writer/models/sync_state.dart';

class FakeConnectivityChecker implements ConnectivityChecker {
  FakeConnectivityChecker();

  @override
  Future<bool> checkConnectivity() async {
    return true;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Stream.value([ConnectivityResult.wifi]);
  }
}

void main() {
  testWidgets('Library shows list, search filter, and disabled download', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'Quiet City Nights',
        author: 'L. Dreamer',
        description: 'Slice-of-life stories set in a peaceful city.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n-2',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

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
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
          chaptersProviderV2.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          removedNovelIdsProvider.overrideWith((ref) => <String>{}),
          motionSettingsProvider.overrideWith(
            (ref) => MotionSettingsNotifier(prefs),
          ),
          syncStateValueProvider.overrideWithValue(
            const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWithValue(false),
          isOnlineProvider.overrideWithValue(true),
          pendingOperationsCountProvider.overrideWith((ref) => 0),
          networkMonitorProvider.overrideWith((ref) {
            final monitor = NetworkMonitor(FakeConnectivityChecker());
            ref.onDispose(() => monitor.stopMonitoring());
            return monitor;
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

    // Allow async providers to resolve
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // Debug what is on screen
    if (find.text('2 / 2 Novels').evaluate().isEmpty) {
      debugDumpApp();
    }

    // Counts
    expect(find.text('2 / 2 Novels'), findsOneWidget);

    // Search field present and filters to one item
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Quiet');
    await tester.pump();
    expect(find.text('1 / 2 Novels'), findsOneWidget);

    expect(find.byKey(const Key('downloadButton_n-1')), findsOneWidget);
  });
}
