import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore_for_file: unnecessary_underscores, always_use_single_underscore
import '../l10n/app_localizations.dart';
import '../state/novel_providers.dart';
import '../state/providers.dart';
import '../theme/design_tokens.dart';
import '../shared/widgets/gradient_background.dart';

/// Enhanced app drawer with sectioned navigation
/// Features:
/// - Gradient header with user info
/// - Sectioned navigation items
/// - Visual hierarchy
/// - Dark mode support
class EnhancedAppDrawer extends ConsumerWidget {
  const EnhancedAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Drawer(
      child: Column(
        children: [
          // Header with gradient
          SizedBox(
            height: 160,
            child: GradientBackground(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: Spacing.m),
                          Text(
                            'Author Console',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isSignedIn)
                        userAsync.when(
                          data: (user) => Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.onPrimary,
                                child: Text(
                                  (user?.email ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Spacing.s),
                              Expanded(
                                child: Text(
                                  user?.email ?? 'User',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerSection(
                  title: 'Library',
                  items: [
                    _DrawerItem(
                      icon: Icons.home,
                      label: l10n.home,
                      onTap: () => _navigateToHome(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.add,
                      label: l10n.createNovel,
                      onTap: () => _navigateToCreateNovel(context, ref),
                    ),
                  ],
                ),
                _DrawerSection(
                  title: 'Tools',
                  items: [
                    _DrawerItem(
                      icon: Icons.assignment_ind_outlined,
                      label: l10n.characterTemplates,
                      onTap: () => _navigateToCharacterTemplates(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.assignment_outlined,
                      label: l10n.sceneTemplates,
                      onTap: () => _navigateToSceneTemplates(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.text_snippet,
                      label: l10n.prompts,
                      onTap: () => _navigateToPrompts(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.auto_awesome,
                      label: l10n.patterns,
                      onTap: () => _navigateToPatterns(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.timeline,
                      label: l10n.storyLines,
                      onTap: () => _navigateToStoryLines(context, ref),
                    ),
                  ],
                ),
                _DrawerSection(
                  title: 'Account',
                  items: [
                    _DrawerItem(
                      icon: Icons.settings,
                      label: l10n.settings,
                      onTap: () => _navigateToSettings(context, ref),
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline,
                      label: l10n.about,
                      onTap: () => _navigateToAbout(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/');
  }

  void _navigateToCreateNovel(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/create-novel');
  }

  void _navigateToCharacterTemplates(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    final libraryAsync = ref.read(libraryNovelsProvider);
    final defaultNovelId = libraryAsync.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first.id : null,
      orElse: () => null,
    );
    if (defaultNovelId != null) {
      GoRouter.of(context).go('/novel/$defaultNovelId/character-templates');
    } else {
      GoRouter.of(context).go('/my-novels');
    }
  }

  void _navigateToSceneTemplates(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    final libraryAsync = ref.read(libraryNovelsProvider);
    final defaultNovelId = libraryAsync.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first.id : null,
      orElse: () => null,
    );
    if (defaultNovelId != null) {
      GoRouter.of(context).go('/novel/$defaultNovelId/scene-templates');
    } else {
      GoRouter.of(context).go('/my-novels');
    }
  }

  void _navigateToPrompts(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/prompts');
  }

  void _navigateToPatterns(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/patterns');
  }

  void _navigateToStoryLines(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/story_lines');
  }

  void _navigateToSettings(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/settings');
  }

  void _navigateToAbout(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    GoRouter.of(context).go('/about');
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.items});

  final String title;
  final List<_DrawerItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            Spacing.l,
            Spacing.l,
            Spacing.s,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
