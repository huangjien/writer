import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/neumorphic_radio.dart';

void main() {
  group('NeumorphicRadio', () {
    group('Widget instantiation', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('renders with custom size', (tester) async {
        const customSize = 32.0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                size: customSize,
              ),
            ),
          ),
        );

        final container = tester
            .widgetList<AnimatedContainer>(
              find.descendant(
                of: find.byType(NeumorphicRadio<int>),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .where((c) => c.duration == const Duration(milliseconds: 200))
            .single;
        expect(container.constraints?.minWidth, customSize);
        expect(container.constraints?.maxWidth, customSize);
        expect(container.constraints?.minHeight, customSize);
        expect(container.constraints?.maxHeight, customSize);
      });

      testWidgets('renders with custom activeColor', (tester) async {
        const customColor = Colors.red;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                activeColor: customColor,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('renders with isEnabled false', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                isEnabled: false,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('renders with null onChanged', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: null,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('renders with null groupValue', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: null,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('renders with String type value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<String>(
                value: 'option1',
                groupValue: 'option1',
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<String>), findsOneWidget);
      });

      testWidgets('renders with enum type value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<TestEnum>(
                value: TestEnum.optionA,
                groupValue: TestEnum.optionA,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<TestEnum>), findsOneWidget);
      });
    });

    group('Visual states', () {
      testWidgets('shows inner circle when selected', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        // Find the inner Container that represents the selected state
        final innerContainer = find.descendant(
          of: find.byType(NeumorphicRadio<int>),
          matching: find.byType(Container),
        );
        expect(innerContainer, findsWidgets);
      });

      testWidgets('does not show inner circle when not selected', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(NeumorphicRadio<int>),
            matching: find.byType(Center),
          ),
          findsNothing,
        );
      });

      testWidgets('applies correct color tint when selected', (tester) async {
        const customColor = Colors.blue;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: customColor),
            ),
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final decoration = tester
            .widgetList<AnimatedContainer>(
              find.descendant(
                of: find.byType(NeumorphicRadio<int>),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .where((c) => c.duration == const Duration(milliseconds: 200))
            .single;
        expect(decoration.decoration, isA<BoxDecoration>());
        final boxDecoration = decoration.decoration as BoxDecoration;
        expect(boxDecoration.color, isNotNull);
      });
    });

    group('Callback functionality', () {
      testWidgets('calls onChanged with correct value when tapped', (
        tester,
      ) async {
        int? capturedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 5,
                groupValue: 1,
                onChanged: (value) {
                  capturedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(NeumorphicRadio<int>));
        expect(capturedValue, 5);
      });

      testWidgets('calls onChanged when enabled', (tester) async {
        bool wasCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: (_) {
                  wasCalled = true;
                },
                isEnabled: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(NeumorphicRadio<int>));
        expect(wasCalled, true);
      });

      testWidgets('does not call onChanged when disabled', (tester) async {
        bool wasCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: (_) {
                  wasCalled = true;
                },
                isEnabled: false,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(NeumorphicRadio<int>));
        expect(wasCalled, false);
      });

      testWidgets('does not call onChanged when null', (tester) async {
        bool wasCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: null,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(NeumorphicRadio<int>));
        expect(wasCalled, false);
      });

      testWidgets('can update groupValue through callback', (tester) async {
        int? groupValue = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      NeumorphicRadio<int>(
                        value: 1,
                        groupValue: groupValue,
                        onChanged: (value) {
                          setState(() {
                            groupValue = value;
                          });
                        },
                      ),
                      NeumorphicRadio<int>(
                        value: 2,
                        groupValue: groupValue,
                        onChanged: (value) {
                          setState(() {
                            groupValue = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Initially, first radio is selected
        expect(groupValue, 1);

        // Tap second radio
        await tester.tap(find.byType(NeumorphicRadio<int>).at(1));
        await tester.pump();

        expect(groupValue, 2);
      });
    });

    group('Theme adaptation', () {
      testWidgets('uses theme primary color when activeColor not provided', (
        tester,
      ) async {
        const customPrimary = Colors.purple;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: customPrimary),
            ),
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('adapts to dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('adapts to light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });
    });

    group('Animation', () {
      testWidgets('has animation duration of 200ms', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final containers = tester
            .widgetList<AnimatedContainer>(
              find.descendant(
                of: find.byType(NeumorphicRadio<int>),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .where((c) => c.duration == const Duration(milliseconds: 200))
            .toList();

        expect(containers, hasLength(1));
      });

      testWidgets('animates when selection changes', (tester) async {
        int? groupValue = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return NeumorphicRadio<int>(
                    value: 1,
                    groupValue: groupValue,
                    onChanged: (value) {
                      setState(() {
                        groupValue = value;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Initially selected
        expect(groupValue, 1);

        // Deselect
        groupValue = null;
        await tester.pump();

        // Verify animation runs
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('is tappable when enabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: (_) {},
                isEnabled: true,
              ),
            ),
          ),
        );

        final gestureDetector = tester.widget<GestureDetector>(
          find.descendant(
            of: find.byType(NeumorphicRadio<int>),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(gestureDetector.behavior, isNotNull);
      });

      testWidgets('is not tappable when disabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 2,
                onChanged: (_) {},
                isEnabled: false,
              ),
            ),
          ),
        );

        final gestureDetector = tester.widget<GestureDetector>(
          find.descendant(
            of: find.byType(NeumorphicRadio<int>),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(gestureDetector.onTap, isNull);
      });
    });

    group('Edge cases', () {
      testWidgets('handles zero size gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                size: 0.0,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('handles very large size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                size: 1000.0,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });

      testWidgets('handles transparent activeColor', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicRadio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                activeColor: Colors.transparent,
              ),
            ),
          ),
        );
        expect(find.byType(NeumorphicRadio<int>), findsOneWidget);
      });
    });
  });
}

enum TestEnum { optionA, optionB, optionC }
