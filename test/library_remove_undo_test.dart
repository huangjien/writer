import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';

// Create a custom SyncStatusIndicator without label to prevent overflow
class CompactSyncStatusIndicator extends StatelessWidget {
  const CompactSyncStatusIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.cloud_done, size: 20);
  }
}

class FakeConnectivityChecker implements ConnectivityChecker {
  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

void main() {
  testWidgets('Remove hides item and undo restores it (offline)', (
    tester,
  ) async {
    // Set mobile screen size to ensure MobileNovelCard is used but prevent overflow
    tester.view.physicalSize = const Size(550, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

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
          // Authentication providers
          isSignedInProvider.overrideWith((ref) => false),
          isAdminProvider.overrideWith((ref) => false),
          adminModeProvider.overrideWith((ref) => AdminModeNotifier(prefs)),
          libraryNovelsProvider.overrideWith((ref) async => novels),
          memberNovelsProvider.overrideWith((ref) async => const []),
          chaptersProvider.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
          removedNovelIdsProvider.overrideWith((ref) => <String>{}),
          motionSettingsProvider.overrideWith(
            (ref) => MotionSettingsNotifier(prefs),
          ),
          // Override sync providers to prevent AppBar overflow from SyncStatusIndicator
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
          isOnlineProvider.overrideWithValue(true),
          pendingOperationsCountProvider.overrideWith((ref) => 0),
          networkMonitorProvider.overrideWith((ref) {
            final monitor = NetworkMonitor(FakeConnectivityChecker());
            ref.onDispose(() => monitor.stopMonitoring());
            return monitor;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Resolve async providers and list build
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Initial count shows all items
    expect(find.text('2 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsOneWidget);
    expect(find.text('The Whispering Forest'), findsOneWidget);

    // Tap more menu icon on the first tile
    final moreMenuButtons = find.byIcon(Icons.more_vert);
    expect(moreMenuButtons, findsWidgets);
    await tester.tap(moreMenuButtons.first);
    await tester.pumpAndSettle();

    // Tap delete action in the menu
    final deleteOptions = find.text('Delete');
    expect(deleteOptions, findsOneWidget);
    await tester.tap(deleteOptions);
    await tester.pump();
    // Ensure SnackBar fully animates in before interacting
    await tester.pumpAndSettle();

    // After local remove, count should update and one title hidden
    expect(find.text('1 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsNothing);
    expect(find.text('The Whispering Forest'), findsOneWidget);

    // SnackBar appears with Undo action
    expect(find.text('Removed from Library'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore
    await tester.tap(find.text('Undo'));
    // Allow state update and UI to settle after Undo
    await tester.pumpAndSettle();

    // Item visibility restored and count reset
    expect(find.text('2 / 2 Novels'), findsOneWidget);
    expect(find.text('Quiet City Nights'), findsOneWidget);
    expect(find.text('The Whispering Forest'), findsOneWidget);
  });
}
