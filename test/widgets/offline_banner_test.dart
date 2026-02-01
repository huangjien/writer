import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/widgets/offline_banner.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/state/network_monitor_provider.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    );
  }

  testWidgets('OfflineBanner shows nothing when online', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => true),
          hasPendingOperationsProvider.overrideWith((ref) => false),
          pendingOperationsCountProvider.overrideWith((ref) async => 0),
        ],
        child: buildTestWidget(const OfflineBanner()),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.text("You're offline"), findsNothing);
  });

  testWidgets(
    'OfflineBanner shows nothing when offline but no pending operations',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isOnlineProvider.overrideWith((ref) => false),
            hasPendingOperationsProvider.overrideWith((ref) => false),
            pendingOperationsCountProvider.overrideWith((ref) async => 0),
          ],
          child: buildTestWidget(const OfflineBanner()),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text("You're offline"), findsNothing);
    },
  );

  testWidgets(
    'OfflineBanner shows banner when offline and pending operations exist',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isOnlineProvider.overrideWith((ref) => false),
            hasPendingOperationsProvider.overrideWith((ref) => true),
            pendingOperationsCountProvider.overrideWith((ref) async => 5),
          ],
          child: buildTestWidget(const OfflineBanner()),
        ),
      );

      await tester.pump();

      expect(find.text("You're offline"), findsOneWidget);
      expect(
        find.text("5 change(s) will sync when you're back online"),
        findsOneWidget,
      );
    },
  );

  testWidgets('OfflineBanner calls onRetry when retry button tapped', (
    tester,
  ) async {
    bool retried = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => false),
          hasPendingOperationsProvider.overrideWith((ref) => true),
          pendingOperationsCountProvider.overrideWith((ref) async => 1),
        ],
        child: buildTestWidget(OfflineBanner(onRetry: () => retried = true)),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Retry'));
    expect(retried, true);
  });

  testWidgets('OfflineBanner calls onDismiss when dismiss button tapped', (
    tester,
  ) async {
    bool dismissed = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => false),
          hasPendingOperationsProvider.overrideWith((ref) => true),
          pendingOperationsCountProvider.overrideWith((ref) async => 1),
        ],
        child: buildTestWidget(
          OfflineBanner(onDismiss: () => dismissed = true),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    expect(dismissed, true);
  });
}
