import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/widgets/reader_bundle_grid.dart';
import 'package:novel_reader/theme/reader_bundles.dart';

void main() {
  testWidgets('ReaderBundleGrid shows bundles and calls onApply', (
    tester,
  ) async {
    ReaderThemeBundleId? applied;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ReaderBundleGrid(onApply: (id) => applied = id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nord Calm'), findsOneWidget);
    expect(find.text('Solarized Focus'), findsOneWidget);
    expect(find.text('High Contrast Readability'), findsOneWidget);

    await tester.tap(find.text('Solarized Focus'));
    await tester.pump();
    expect(applied, ReaderThemeBundleId.solarizedFocus);
  });
}
