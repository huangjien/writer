import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/theme_preview.dart';
import 'package:writer/theme/themes.dart';

void main() {
  testWidgets(
    'ThemePreviewGrid shows all theme tiles and triggers onSelected',
    (tester) async {
      AppThemeFamily? chosen;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ThemePreviewGrid(
              selected: AppThemeFamily.modernMinimalist,
              onSelected: (f) => chosen = f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final def in themeFactoryThemes) {
        expect(find.text(def.label), findsOneWidget);
      }

      await tester.tap(find.text('Ocean Depths'));
      await tester.pump();
      expect(chosen, AppThemeFamily.oceanDepths);
    },
  );
}
