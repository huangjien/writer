import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/settings/widgets/reader_bundle_grid.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/reader_bundles.dart';

void main() {
  testWidgets('ReaderBundleGrid renders correctly', (
    WidgetTester tester,
  ) async {
    ReaderThemeBundleId? appliedBundle;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderBundleGrid(
            onApply: (bundle) {
              appliedBundle = bundle;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nord Calm'), findsOneWidget);
    expect(find.text('Solarized Focus'), findsOneWidget);
    expect(find.text('High Contrast Readability'), findsOneWidget);

    await tester.tap(find.text('Nord Calm'));
    expect(appliedBundle, ReaderThemeBundleId.nordCalm);
  });
}
