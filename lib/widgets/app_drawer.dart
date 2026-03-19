import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Center(
                child: kIsWeb
                    ? Image.network(
                        '/icons/Icon-192.png',
                        height: 80,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.menu_book, size: 80),
                      )
                    : Image.asset(
                        'web/icons/Icon-192.png',
                        height: 80,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.menu_book, size: 80),
                      ),
              ),
            ),
          ),
          _DrawerListItem(
            leading: const Icon(Icons.home),
            title: Text(l10n.home),
            onTap: () {
              context.go('/');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              context.go('/settings');
            },
          ),
          const Divider(),
          _DrawerListItem(
            leading: const Icon(Icons.assignment_ind_outlined),
            title: Text(l10n.characterTemplates),
            onTap: () {
              context.go('/character-templates');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(l10n.sceneTemplates),
            onTap: () {
              context.go('/scene-templates');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.text_snippet),
            title: Text(l10n.prompts),
            onTap: () {
              context.go('/prompts');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.auto_awesome),
            title: Text(l10n.patterns),
            onTap: () {
              context.go('/patterns');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.timeline),
            title: Text(l10n.storyLines),
            onTap: () {
              context.go('/story_lines');
            },
          ),
          const Divider(),
          _DrawerListItem(
            leading: const Icon(Icons.add),
            title: Text(l10n.createNovel),
            onTap: () {
              context.go('/create-novel');
            },
          ),
          _DrawerListItem(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              context.go('/about');
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerListItem extends StatelessWidget {
  const _DrawerListItem({
    required this.leading,
    required this.title,
    required this.onTap,
  });

  final Widget leading;
  final Widget title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 48, child: leading),
              Expanded(child: title),
            ],
          ),
        ),
      ),
    );
  }
}
