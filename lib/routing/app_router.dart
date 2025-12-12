import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import '../features/library/library_screen.dart';
import '../features/library/create_novel_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/library/my_novels_screen.dart';
import '../features/about/about_screen.dart';
import '../features/summary/summary_screen.dart';
import '../features/summary/characters_list_screen.dart';
import '../features/summary/scenes_list_screen.dart';
import '../features/summary/characters_screen.dart';
import '../features/summary/scenes_screen.dart';
import '../features/summary/character_templates_list_screen.dart';
import '../features/summary/scene_templates_list_screen.dart';
import '../features/summary/character_templates_screen.dart';
import '../features/summary/scene_templates_screen.dart';
import '../features/reader/novel_metadata_editor.dart';
import '../screens/prompts_list_screen.dart';
import '../screens/prompt_form_screen.dart';
import '../screens/patterns_list_screen.dart';
import '../screens/pattern_form_screen.dart';
import '../models/prompt.dart';
import '../models/pattern.dart';
import '../state/providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/prompts',
        name: 'prompts',
        builder: (context, state) {
          final svc = ref.watch(promptsServiceProvider);
          final isAdmin = ref.watch(isAdminProvider);
          return PromptsListScreen(service: svc, isAdmin: isAdmin);
        },
      ),
      GoRoute(
        path: '/patterns',
        name: 'patterns',
        builder: (context, state) => const PatternsListScreen(),
      ),
      GoRoute(
        path: '/prompt_form',
        name: 'promptForm',
        builder: (context, state) {
          final svc = ref.watch(promptsServiceProvider);
          final initial = state.extra is Prompt ? state.extra as Prompt? : null;
          final isAdmin = ref.watch(isAdminProvider);
          final session = ref.watch(supabaseSessionProvider);
          final isSignedIn = session != null;
          final ownerId = initial?.userId;
          final currentUserId = session?.user.id;
          final canEdit = initial == null
              ? true
              : (isAdmin || (ownerId != null && ownerId == currentUserId));
          return PromptFormScreen(
            service: svc,
            initial: initial,
            isAdmin: isAdmin,
            isSignedIn: isSignedIn,
            canEdit: canEdit,
          );
        },
      ),
      GoRoute(
        path: '/pattern_form',
        name: 'patternForm',
        builder: (context, state) {
          final initial = state.extra is Pattern
              ? state.extra as Pattern?
              : null;
          return PatternFormScreen(initial: initial);
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/my-novels',
        name: 'myNovels',
        builder: (context, state) => const MyNovelsScreen(),
      ),
      GoRoute(
        path: '/create-novel',
        name: 'createNovel',
        builder: (context, state) => const CreateNovelScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/novel/:id',
        name: 'novel',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReaderScreen(novelId: id);
        },
        routes: [
          GoRoute(
            path: 'chapters/:chapterId',
            name: 'chapter',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              final chapterId = state.pathParameters['chapterId']!;
              return ReaderScreen(novelId: novelId, chapterId: chapterId);
            },
          ),
          GoRoute(
            path: 'summary',
            name: 'summary',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return SummaryScreen(novelId: novelId);
            },
          ),
          GoRoute(
            path: 'characters',
            name: 'characters',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return CharactersListScreen(novelId: novelId);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'charactersNew',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  return CharactersScreen(novelId: novelId);
                },
              ),
              GoRoute(
                path: ':idx',
                name: 'charactersEdit',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  final idx = int.tryParse(state.pathParameters['idx'] ?? '');
                  return CharactersScreen(novelId: novelId, idx: idx);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'scenes',
            name: 'scenes',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return ScenesListScreen(novelId: novelId);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'scenesNew',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  return ScenesScreen(novelId: novelId);
                },
              ),
              GoRoute(
                path: ':idx',
                name: 'scenesEdit',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  final idx = int.tryParse(state.pathParameters['idx'] ?? '');
                  return ScenesScreen(novelId: novelId, idx: idx);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'character-templates',
            name: 'characterTemplates',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return CharacterTemplatesListScreen(novelId: novelId);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'characterTemplatesNew',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  return CharacterTemplatesScreen(novelId: novelId);
                },
              ),
              GoRoute(
                path: ':tid',
                name: 'characterTemplatesEdit',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  final tid = state.pathParameters['tid']!;
                  return CharacterTemplatesScreen(
                    novelId: novelId,
                    templateId: tid,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'scene-templates',
            name: 'sceneTemplates',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return SceneTemplatesListScreen(novelId: novelId);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'sceneTemplatesNew',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  return SceneTemplatesScreen(novelId: novelId);
                },
              ),
              GoRoute(
                path: ':tid',
                name: 'sceneTemplatesEdit',
                builder: (context, state) {
                  final novelId = state.pathParameters['id']!;
                  final tid = state.pathParameters['tid']!;
                  return SceneTemplatesScreen(
                    novelId: novelId,
                    templateId: tid,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'edit',
            name: 'editNovel',
            builder: (context, state) {
              final novelId = state.pathParameters['id']!;
              return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.updateNovel),
                ),
                body: NovelMetadataEditor(novelId: novelId),
              );
            },
          ),
        ],
      ),
    ],
  );
});
