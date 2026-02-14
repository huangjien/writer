import 'package:go_router/go_router.dart';

import 'package:writer/features/summary/screens/characters/character_templates_screen.dart';
import 'package:writer/features/summary/screens/characters/characters_list_screen.dart';
import 'package:writer/features/summary/screens/characters/characters_screen.dart';
import 'package:writer/features/summary/screens/scenes/scene_templates_screen.dart';
import 'package:writer/features/summary/screens/scenes/scenes_list_screen.dart';
import 'package:writer/features/summary/screens/scenes/scenes_screen.dart';
import 'package:writer/features/summary/screens/summary_screen.dart';

final summaryRoutes = [
  GoRoute(
    path: '/novels/:id/summary',
    name: 'summary',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return SummaryScreen(novelId: id!);
    },
  ),
  GoRoute(
    path: '/novels/:id/characters',
    name: 'characters',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return CharactersListScreen(novelId: id!);
    },
    routes: [
      GoRoute(
        path: ':idx',
        name: 'charactersEdit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final idx = state.pathParameters['idx'];
          return CharactersScreen(
            novelId: id!,
            idx: idx != null ? int.tryParse(idx)! : null,
          );
        },
      ),
      GoRoute(
        path: 'new',
        name: 'charactersNew',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return CharactersScreen(novelId: id!);
        },
      ),
    ],
  ),
  GoRoute(
    path: '/novels/:id/scenes',
    name: 'scenes',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return ScenesListScreen(novelId: id!);
    },
    routes: [
      GoRoute(
        path: ':idx',
        name: 'scenesEdit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final idx = state.pathParameters['idx'];
          return ScenesScreen(
            novelId: id!,
            idx: idx != null ? int.tryParse(idx)! : null,
          );
        },
      ),
      GoRoute(
        path: 'new',
        name: 'scenesNew',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ScenesScreen(novelId: id!);
        },
      ),
    ],
  ),
  GoRoute(
    path: '/novels/:id/character-templates',
    name: 'characterTemplates',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return CharacterTemplatesScreen(novelId: id!);
    },
    routes: [
      GoRoute(
        path: ':tid',
        name: 'characterTemplatesEdit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final tid = state.pathParameters['tid'];
          return CharacterTemplatesScreen(novelId: id!, templateId: tid!);
        },
      ),
    ],
  ),
  GoRoute(
    path: '/novels/:id/scene-templates',
    name: 'sceneTemplates',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return SceneTemplatesScreen(novelId: id!);
    },
    routes: [
      GoRoute(
        path: ':tid',
        name: 'sceneTemplatesEdit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final tid = state.pathParameters['tid'];
          return SceneTemplatesScreen(novelId: id!, templateId: tid!);
        },
      ),
    ],
  ),
];
