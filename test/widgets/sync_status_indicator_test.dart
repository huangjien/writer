import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/widgets/sync_status_indicator.dart';

void main() {
  testWidgets('SyncStatusIndicator shows syncing state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStateValueProvider.overrideWith(
            (ref) => const SyncState(status: SyncStatus.syncing),
          ),
          hasPendingOperationsProvider.overrideWith((ref) => false),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: true)),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Syncing...'), findsOneWidget);
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
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: true)),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
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
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: true)),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text('Pending sync'), findsOneWidget);
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
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: true)),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
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
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: true)),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Sync failed'), findsOneWidget);
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
        child: const MaterialApp(
          home: Scaffold(body: SyncStatusIndicator(showLabel: false)),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(find.text('Synced'), findsNothing);
  });
}
