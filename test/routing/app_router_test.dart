import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/features/library/my_novels_screen.dart';
import 'package:writer/features/library/create_novel_screen.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/about/about_screen.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/features/summary/summary_screen.dart';
import 'package:writer/features/summary/characters_list_screen.dart';
import 'package:writer/features/summary/characters_screen.dart';
import 'package:writer/features/summary/scenes_list_screen.dart';
import 'package:writer/features/summary/scenes_screen.dart';
import 'package:writer/features/summary/character_templates_list_screen.dart';
import 'package:writer/features/summary/scene_templates_list_screen.dart';
import 'package:writer/features/summary/character_templates_screen.dart';
import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('AppRouter routes return correct widgets', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    final routes = router.configuration.routes;

    // Helper to find route by name
    GoRoute? findRoute(List<RouteBase> routes, String name) {
      for (final route in routes) {
        if (route is GoRoute && route.name == name) return route;
        if (route is GoRoute && route.routes.isNotEmpty) {
          final found = findRoute(route.routes, name);
          if (found != null) return found;
        }
      }
      return null;
    }

    void verifyRoute<T>(String name, {Map<String, String> params = const {}}) {
      final route = findRoute(routes, name);
      expect(route, isNotNull, reason: 'Route $name not found');

      final state = MockGoRouterState();
      when(() => state.pathParameters).thenReturn(params);
      when(() => state.name).thenReturn(name);

      // Create a dummy context
      final context = tester.element(
        find.byType(Container),
      ); // requires pumping a widget first

      final widget = route!.builder!(context, state);
      expect(widget, isA<T>(), reason: 'Route $name did not return $T');
    }

    await tester.pumpWidget(Container()); // Provide a context

    // Verify top-level routes
    verifyRoute<LibraryScreen>('library');
    verifyRoute<SignInScreen>('auth');
    verifyRoute<MyNovelsScreen>('myNovels');
    verifyRoute<CreateNovelScreen>('createNovel');
    verifyRoute<SettingsScreen>('settings');
    verifyRoute<AboutScreen>('about');

    // Verify nested routes (requires params)
    verifyRoute<ReaderScreen>('novel', params: {'id': '123'});
    verifyRoute<ReaderScreen>(
      'chapter',
      params: {'id': '123', 'chapterId': '456'},
    );
    verifyRoute<SummaryScreen>('summary', params: {'id': '123'});

    verifyRoute<CharactersListScreen>('characters', params: {'id': '123'});
    verifyRoute<CharactersScreen>('charactersNew', params: {'id': '123'});
    verifyRoute<CharactersScreen>(
      'charactersEdit',
      params: {'id': '123', 'idx': '0'},
    );

    verifyRoute<ScenesListScreen>('scenes', params: {'id': '123'});
    verifyRoute<ScenesScreen>('scenesNew', params: {'id': '123'});
    verifyRoute<ScenesScreen>('scenesEdit', params: {'id': '123', 'idx': '0'});

    verifyRoute<CharacterTemplatesListScreen>(
      'characterTemplates',
      params: {'id': '123'},
    );
    verifyRoute<CharacterTemplatesScreen>(
      'characterTemplatesNew',
      params: {'id': '123'},
    );
    verifyRoute<CharacterTemplatesScreen>(
      'characterTemplatesEdit',
      params: {'id': '123', 'tid': 'template1'},
    );

    verifyRoute<SceneTemplatesListScreen>(
      'sceneTemplates',
      params: {'id': '123'},
    );
    verifyRoute<SceneTemplatesScreen>(
      'sceneTemplatesNew',
      params: {'id': '123'},
    );
    verifyRoute<SceneTemplatesScreen>(
      'sceneTemplatesEdit',
      params: {'id': '123', 'tid': 'template1'},
    );

    verifyRoute<Scaffold>('editNovel', params: {'id': '123'});
  });
}

class MockGoRouter extends Fake implements GoRouter {}

class MockGoRouterState extends Mock implements GoRouterState {}
