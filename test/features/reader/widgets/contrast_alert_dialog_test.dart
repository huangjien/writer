import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/contrast_alert_dialog.dart';
import 'package:writer/features/reader/widgets/contrast_monitor.dart';
import 'package:writer/features/reader/widgets/contrast_validator.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: child,
  );
}

void main() {
  group('ContrastAlertDialog', () {
    testWidgets('shows no issues when all pass', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Colors.black,
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Colors.black,
                  ),
                ),
            ),
          ],
          child: buildTestWidget(
            ContrastAlertDialog(onDismiss: () => dismissed = true),
          ),
        ),
      );

      expect(find.text('All Good!'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('shows contrast issues', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Colors.white,
                    secondaryText: Colors.white,
                    accentText: Colors.white,
                    linkText: Colors.white,
                  ),
                ),
            ),
          ],
          child: buildTestWidget(ContrastAlertDialog(onDismiss: () {})),
        ),
      );

      expect(find.text('Contrast Issues Detected'), findsOneWidget);
    });

    testWidgets('shows Apply Best Fix for critical issues', (tester) async {
      bool applied = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Colors.white,
                    secondaryText: Colors.white,
                    accentText: Colors.white,
                    linkText: Colors.white,
                  ),
                ),
            ),
          ],
          child: buildTestWidget(
            ContrastAlertDialog(
              onDismiss: () {},
              onApplyPreset: () => applied = true,
            ),
          ),
        ),
      );

      expect(find.text('Apply Best Fix'), findsOneWidget);

      await tester.tap(find.text('Apply Best Fix'));
      await tester.pump();

      expect(applied, isTrue);
    });
  });
}
