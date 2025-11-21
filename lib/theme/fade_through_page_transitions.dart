import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Material FadeThrough page transitions builder.
///
/// Applies a subtle fade-through between outgoing and incoming routes.
/// Route duration is governed by the page route; we only shape curves.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Avoid animating the initial route to prevent unintended flashes.
    if (route.settings.name == Navigator.defaultRouteName) {
      return child;
    }

    final primary = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOutCubic,
    );

    return FadeThroughTransition(
      animation: primary,
      secondaryAnimation: secondary,
      child: child,
    );
  }
}
