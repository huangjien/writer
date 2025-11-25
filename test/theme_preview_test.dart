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
              selected: AppThemeFamily.defaultFamily,
              onSelected: (f) => chosen = f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Sepia'), findsOneWidget);
      expect(find.text('Solarized'), findsOneWidget);
      expect(find.text('Solarized Tan'), findsOneWidget);
      expect(find.text('Nord'), findsOneWidget);
      expect(find.text('Nord Frost'), findsOneWidget);
      expect(find.text('Nord Snowstorm'), findsOneWidget);
      expect(find.text('High Contrast'), findsOneWidget);

      await tester.tap(find.text('Sepia'));
      await tester.pump();
      expect(chosen, AppThemeFamily.sepia);
    },
  );
}
