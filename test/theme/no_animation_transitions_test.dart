import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/no_animation_transitions.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  test('NoAnimationPageTransitionsBuilder returns child directly', () {
    const builder = NoAnimationPageTransitionsBuilder();
    final route = MaterialPageRoute(builder: (_) => Container());
    final animation = AnimationController(vsync: const TestVSync());
    final secondaryAnimation = AnimationController(vsync: const TestVSync());
    final child = Container();

    final widget = builder.buildTransitions(
      route,
      MockBuildContext(),
      animation,
      secondaryAnimation,
      child,
    );

    expect(widget, same(child));
  });
}

class MockBuildContext extends Mock implements BuildContext {}
