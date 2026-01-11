import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/micro_interactions.dart';

void main() {
  testWidgets('AppButtons.primary shows loading and disables press', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButtons.primary(
            label: 'Save',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    final pressScale = tester.widget<PressScale>(find.byType(PressScale));
    expect(pressScale.enabled, isFalse);

    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(filled.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('AppButtons.primary shows icon and label when not loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButtons.primary(
            label: 'Save',
            icon: Icons.save,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('AppButtons.primary applies fullWidth minimumSize', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButtons.primary(
            label: 'Continue',
            fullWidth: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = filled.style;
    final minSize = style?.minimumSize?.resolve(<WidgetState>{});
    expect(minSize, const Size(double.infinity, 48));
  });

  testWidgets('AppButtons.icon wraps tooltip when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButtons.icon(
            iconData: Icons.close,
            tooltip: 'Close',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('AppButtons.filledIcon wraps tooltip when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButtons.filledIcon(
            iconData: Icons.play_arrow,
            tooltip: 'Play',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
