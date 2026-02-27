import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

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
            _DrawerListItem(
              leading: const Icon(Icons.list),
              title: Text(l10n.chapterIndex),
              onTap: () {
                context.go('/novel/$novelId');
              },
            ),
            const Divider(),
            _DrawerListItem(
              leading: const Icon(Icons.summarize),
              title: Text(l10n.summary),
              onTap: () {
                context.go('/novel/$novelId/summary');
              },
            ),
            _DrawerListItem(
              leading: const Icon(Icons.person),
              title: Text(l10n.characters),
              onTap: () {
                context.go('/novel/$novelId/characters');
              },
            ),
            _DrawerListItem(
              leading: const Icon(Icons.movie_creation_outlined),
              title: Text(l10n.scenes),
              onTap: () {
                context.go('/novel/$novelId/scenes');
              },
            ),
            if (isOwner) ...[
              const Divider(),
              _DrawerListItem(
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
              _DrawerListItem(
                leading: const Icon(Icons.delete),
                title: Text(l10n.deleteNovel),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AppDialog(
                      title: l10n.deleteNovel,
                      content: Text(l10n.deleteNovelConfirmation),
                      actions: [
                        AppButtons.text(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          label: l10n.cancel,
                        ),
                        AppButtons.text(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          label: l10n.delete,
                          color: Theme.of(ctx).colorScheme.error,
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
    final label = title is Text ? (title as Text).data ?? '' : '';
    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        label: label,
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
      ),
    );
  }
}
