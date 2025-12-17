import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/novel_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final libraryAsync = ref.watch(libraryNovelsProvider);
    final defaultNovelId = libraryAsync.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first.id : null,
      orElse: () => null,
    );
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind_outlined),
            title: Text(l10n.characterTemplates),
            onTap: () {
              Navigator.pop(context);
              final id = defaultNovelId;
              if (id != null) {
                context.go('/novel/$id/character-templates');
              } else {
                context.go('/my-novels');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(l10n.sceneTemplates),
            onTap: () {
              Navigator.pop(context);
              final id = defaultNovelId;
              if (id != null) {
                context.go('/novel/$id/scene-templates');
              } else {
                context.go('/my-novels');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_snippet),
            title: Text(l10n.prompts),
            onTap: () {
              Navigator.pop(context);
              context.go('/prompts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: Text(l10n.patterns),
            onTap: () {
              Navigator.pop(context);
              context.go('/patterns');
            },
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: Text(l10n.storyLines),
            onTap: () {
              Navigator.pop(context);
              context.go('/story_lines');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.createNovel),
            onTap: () {
              Navigator.pop(context);
              context.go('/create-novel');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              Navigator.pop(context);
              context.go('/about');
            },
          ),
        ],
      ),
    );
  }
}
