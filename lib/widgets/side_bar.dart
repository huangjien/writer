import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/novel_providers.dart';
import '../state/edit_permissions.dart';
import '../features/reader/novel_metadata_editor.dart';
import '../l10n/app_localizations.dart';
import '../repositories/novel_repository.dart';

class SideBar extends ConsumerWidget {
  final String novelId;

  const SideBar({super.key, required this.novelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final novelAsync = ref.watch(novelProvider(novelId));
    final roleAsync = ref.watch(editRoleProvider(novelId));
    final isOwner = roleAsync.value == EditRole.owner;
    final title = novelAsync.asData?.value?.title ?? l10n.navigation;
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
              title: Text(l10n.home),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: Text(l10n.prompts),
              onTap: () {
                context.go('/prompts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(l10n.patterns),
              onTap: () {
                context.go('/patterns');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () {
                context.go('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: Text(l10n.chapterIndex),
              onTap: () {
                context.go('/novel/$novelId');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: Text(l10n.summary),
              onTap: () {
                context.go('/novel/$novelId/summary');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.characters),
              onTap: () {
                context.go('/novel/$novelId/characters');
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie_creation_outlined),
              title: Text(l10n.scenes),
              onTap: () {
                context.go('/novel/$novelId/scenes');
              },
            ),
            if (isOwner) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.updateNovel),
                onTap: () {
                  Navigator.of(context).pop();
                  try {
                    context.pushNamed(
                      'editNovel',
                      pathParameters: {'id': novelId},
                    );
                  } catch (_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text(l10n.updateNovel)),
                          body: NovelMetadataEditor(novelId: novelId),
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(l10n.deleteNovel),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.deleteNovel),
                      content: Text(l10n.deleteNovelConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(l10n.delete),
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
