import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

import 'package:novel_reader/app.dart';
import 'package:novel_reader/routing/app_router.dart';
import 'package:novel_reader/state/motion_settings.dart';

class _TestMotionSettingsNotifier extends MotionSettingsNotifier {
  _TestMotionSettingsNotifier(bool reduceMotion) : super.lazy() {
    state = state.copyWith(reduceMotion: reduceMotion);
  }
}

ProviderScope _buildScope({required bool reduceMotion}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Settings'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appRouterProvider.overrideWithValue(router),
      motionSettingsProvider.overrideWith(
        (ref) => _TestMotionSettingsNotifier(reduceMotion),
      ),
    ],
    child: const App(),
  );
}

void main() {
  testWidgets('FadeThrough animates on route change when motion allowed', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScope(reduceMotion: false));
    await tester.pumpAndSettle();

    // Navigate to settings
    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    final router = container.read(appRouterProvider);
    router.go('/settings');

    // Pump a few frames to be mid-transition.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // Assert the FadeThroughTransition is present during the animation.
    expect(find.byType(FadeThroughTransition), findsWidgets);

    // After settling, ensure destination is visible.
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('No animation on route change when Reduce Motion enabled', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScope(reduceMotion: true));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    final router = container.read(appRouterProvider);
    router.go('/settings');

    // Pump one frame and a short duration; no transition widget should appear.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byType(FadeThroughTransition), findsNothing);

    // Destination should be shown promptly.
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}
