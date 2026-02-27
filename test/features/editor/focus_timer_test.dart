import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/focus_timer.dart';
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
  testWidgets('FocusTimerSheet shows timer', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const Center(child: FocusTimerSheet())),
    );

    expect(find.byType(FocusTimerSheet), findsOneWidget);
  });

  testWidgets('FocusTimerSheet starts timer on Start', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const Center(child: FocusTimerSheet())),
    );

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('FocusTimerSheet pauses timer on Pause', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const Center(child: FocusTimerSheet())),
    );

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('FocusTimerSheet resets timer on Reset', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const Center(child: FocusTimerSheet())),
    );

    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('25:00'), findsOneWidget);
  });
}
