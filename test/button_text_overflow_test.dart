import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/shared/widgets/responsive_button_row.dart';

void main() {
  testWidgets('AppButtons do not overflow with long labels and large text', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                child: AppButtons.primary(
                  fullWidth: true,
                  label:
                      'This is a very long primary button label that must fit',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final overflowErrors = errors.where(
      (e) => e.exceptionAsString().contains('overflowed'),
    );
    expect(overflowErrors, isEmpty);
  });

  testWidgets('ResponsiveButtonRow wraps without overflow on narrow widths', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: ResponsiveButtonRow(
                  alignment: WrapAlignment.start,
                  children: [
                    AppButtons.text(
                      label: 'Cancel with a long label',
                      onPressed: () {},
                    ),
                    AppButtons.secondary(
                      label: 'AI Action With Long Label',
                      onPressed: () {},
                    ),
                    AppButtons.primary(
                      label: 'Save Changes Now',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final overflowErrors = errors.where(
      (e) => e.exceptionAsString().contains('overflowed'),
    );
    expect(overflowErrors, isEmpty);
  });

  testWidgets('NeumorphicButton shrink-wraps content by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AppButtons.primary(label: 'Save', onPressed: _noop),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.widgetWithText(NeumorphicButton, 'Save');
    expect(button, findsOneWidget);
    expect(tester.getSize(button).width, lessThan(360));
  });
}

void _noop() {}
