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
            selected: AppThemeFamily.modernMinimalist,
            onSelected: (family) {
              selectedFamily = family;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modern Minimalist'), findsOneWidget);
    expect(find.text('Ocean Depths'), findsOneWidget);

    await tester.tap(find.text('Ocean Depths'));
    expect(selectedFamily, AppThemeFamily.oceanDepths);
  });
}
