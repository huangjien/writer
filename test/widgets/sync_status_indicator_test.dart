import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/widgets/sync_status_indicator.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  final en = AppLocalizationsEn();

  testWidgets('SyncStatusIndicator shows syncing state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.syncing),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(en.loadingProgress), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows synced state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text(en.saved), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows pending sync state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => true),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text(en.changesWillSync), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows offline state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.offline),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text(en.youreOfflineLabel), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.error),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text(en.saveFailed), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows conflict state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(
              status: SyncStatus.error,
              errorMessage: 'Sync conflict detected',
            ),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: true)),
      ),
    );

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text(en.error), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator hides label when showLabel is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.synced),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: buildTestWidget(const SyncStatusIndicator(showLabel: false)),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text(en.saved), findsNothing);
  });
}
