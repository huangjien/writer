import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/novel_providers.dart';
import '../state/edit_permissions.dart';
import '../features/reader/novel_metadata_editor.dart';

class SideBar extends ConsumerWidget {
  final String novelId;

  const SideBar({super.key, required this.novelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novelAsync = ref.watch(novelProvider(novelId));
    final roleAsync = ref.watch(editRoleProvider(novelId));
    final isOwner = roleAsync.valueOrNull == EditRole.owner;
    final title = novelAsync.asData?.value?.title ?? 'Navigation';
    return SizedBox(
      width: 260,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Chapter Index'),
              onTap: () {
                context.go('/novel/$novelId');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Summary'),
              onTap: () {
                context.go('/novel/$novelId/summary');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Characters'),
              onTap: () {
                context.go('/novel/$novelId/characters');
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie_creation_outlined),
              title: const Text('Scenes'),
              onTap: () {
                context.go('/novel/$novelId/scenes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind_outlined),
              title: const Text('Character Templates'),
              onTap: () {
                context.go('/novel/$novelId/character-templates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Scene Templates'),
              onTap: () {
                context.go('/novel/$novelId/scene-templates');
              },
            ),
            if (isOwner) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Update Novel'),
                onTap: () {
                  Navigator.of(context).pop();
                  try {
                    context.push('/novel/$novelId/edit');
                  } catch (_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Update Novel')),
                          body: NovelMetadataEditor(novelId: novelId),
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Novel'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Novel'),
                      content: const Text(
                        'This will permanently delete the novel. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  final repo = ref.read(novelRepositoryProvider);
                  await repo.deleteNovel(novelId);
                  if (!context.mounted) return;
                  ref.invalidate(novelsProvider);
                  ref.invalidate(memberNovelsProvider);
                  context.goNamed('library');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
