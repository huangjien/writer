import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/zen_mode.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('ZenModeBar wires buttons when preview is off', (tester) async {
    int exitCount = 0;
    int saveCount = 0;
    int toggleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ZenModeBar(
            preview: false,
            onExit: () => exitCount++,
            onSave: () => saveCount++,
            onTogglePreview: () => toggleCount++,
          ),
        ),
      ),
    );

    expect(find.text('Preview mode'), findsOneWidget);
    expect(find.byTooltip('Preview'), findsOneWidget);
    expect(find.byTooltip('Save'), findsOneWidget);
    expect(find.byTooltip('Exit Zen mode'), findsOneWidget);

    await tester.tap(find.byTooltip('Preview'));
    await tester.tap(find.byTooltip('Save'));
    await tester.tap(find.byTooltip('Exit Zen mode'));
    await tester.pump();

    expect(toggleCount, 1);
    expect(saveCount, 1);
    expect(exitCount, 1);
  });

  testWidgets('ZenModeBar changes preview tooltip when preview is on', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ZenModeBar(
            preview: true,
            onExit: () {},
            onSave: () {},
            onTogglePreview: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Exit preview'), findsOneWidget);
    expect(find.byTooltip('Preview'), findsNothing);
  });
}
