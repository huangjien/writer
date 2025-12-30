import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/app.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';

Future<ProviderScope> _buildScope({required bool reduceMotion}) async {
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

  SharedPreferences.setMockInitialValues({
    'reduce_motion_enabled': reduceMotion,
  });
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appRouterProvider.overrideWithValue(router),
      motionSettingsProvider.overrideWith(
        (ref) => MotionSettingsNotifier(prefs),
      ),
    ],
    child: const App(),
  );
}

void main() {
  testWidgets('FadeThrough animates on route change when motion allowed', (
    tester,
  ) async {
    final scope = await _buildScope(reduceMotion: false);
    await tester.pumpWidget(scope);
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
    final scope = await _buildScope(reduceMotion: true);
    await tester.pumpWidget(scope);
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
