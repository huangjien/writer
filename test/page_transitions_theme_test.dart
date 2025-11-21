import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_reader/app.dart';
import 'package:novel_reader/routing/app_router.dart';
import 'package:novel_reader/state/motion_settings.dart';
import 'package:novel_reader/theme/no_animation_transitions.dart';
import 'package:novel_reader/theme/fade_through_page_transitions.dart';

class _TestMotionSettingsNotifier extends MotionSettingsNotifier {
  _TestMotionSettingsNotifier(bool reduceMotion) : super.lazy() {
    state = state.copyWith(reduceMotion: reduceMotion);
  }
}

ProviderScope _buildScope({required bool reduceMotion}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
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
  testWidgets('Reduce Motion: uses NoAnimation PageTransitions builders', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScope(reduceMotion: true));
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
    await tester.pumpWidget(_buildScope(reduceMotion: false));
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
