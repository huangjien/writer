import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/app.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/theme/no_animation_transitions.dart';
import 'package:writer/theme/fade_through_page_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderScope> _buildScope({required bool reduceMotion}) async {
  SharedPreferences.setMockInitialValues({
    'reduce_motion_enabled': reduceMotion,
  });
  final prefs = await SharedPreferences.getInstance();
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
    ],
  );

  return ProviderScope(
    overrides: [
      appRouterProvider.overrideWithValue(router),
      motionSettingsProvider.overrideWith(
        (ref) => MotionSettingsNotifier(prefs),
      ),
    ],
    child: const App(),
  );
}

void main() {
  testWidgets('Reduce Motion: uses NoAnimation PageTransitions builders', (
    tester,
  ) async {
    final scope = await _buildScope(reduceMotion: true);
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final ThemeData? theme = app.theme;
    expect(theme, isNotNull);

    final builders = theme!.pageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.android],
      isA<NoAnimationPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.iOS],
      isA<NoAnimationPageTransitionsBuilder>(),
    );
  });

  testWidgets('Motion allowed: uses FadeThrough PageTransitions builders', (
    tester,
  ) async {
    final scope = await _buildScope(reduceMotion: false);
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final ThemeData? theme = app.theme;
    expect(theme, isNotNull);

    final builders = theme!.pageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.android],
      isA<FadeThroughPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.iOS],
      isA<FadeThroughPageTransitionsBuilder>(),
    );
  });
}
