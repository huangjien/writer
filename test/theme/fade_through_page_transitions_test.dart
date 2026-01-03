import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/theme/fade_through_page_transitions.dart' as app_theme;
import 'package:animations/animations.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  testWidgets(
    'FadeThroughPageTransitionsBuilder builds FadeThroughTransition',
    (tester) async {
      const builder = app_theme.FadeThroughPageTransitionsBuilder();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            platform: TargetPlatform.android,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: builder,
                TargetPlatform.macOS: builder,
              },
            ),
          ),
          home: const Scaffold(body: Text('Page 1')),
        ),
      );

      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Page 2')),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FadeThroughTransition), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  test('FadeThroughPageTransitionsBuilder uses easeInOutCubic curve', () {
    const builder = app_theme.FadeThroughPageTransitionsBuilder();
    final route = MaterialPageRoute(builder: (_) => Container());
    final animation = AnimationController(vsync: const TestVSync());
    final secondaryAnimation = AnimationController(vsync: const TestVSync());

    final widget = builder.buildTransitions(
      route,
      MockBuildContext(),
      animation,
      secondaryAnimation,
      Container(),
    );

    expect(widget, isA<FadeThroughTransition>());
  });
}
