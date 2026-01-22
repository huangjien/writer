import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/settings/widgets/theme_preview.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/themes.dart';

void main() {
  testWidgets('ThemePreviewGrid renders correctly', (
    WidgetTester tester,
  ) async {
    AppThemeFamily? selectedFamily;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ThemePreviewGrid(
            selected: AppThemeFamily.defaultFamily,
            onSelected: (family) {
              selectedFamily = family;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Sepia'), findsOneWidget);

    await tester.tap(find.text('Sepia'));
    expect(selectedFamily, AppThemeFamily.sepia);
  });
}
