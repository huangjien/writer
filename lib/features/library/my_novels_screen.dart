import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/shared/api_exception.dart';

import '../../l10n/app_localizations.dart';
import '../../models/novel.dart';
import '../../state/novel_providers.dart';
import '../../state/providers.dart';
import '../../shared/image_utils.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/empty_states/novel_empty_state.dart';

class MyNovelsScreen extends ConsumerWidget {
  const MyNovelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isSignedIn = ref.watch(isSignedInProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myNovels ?? 'My Novels'),
        actions: [
          AppButtons.icon(
            iconData: Icons.home,
            onPressed: () => context.go('/'),
            tooltip: l10n?.home ?? 'Home',
          ),
        ],
      ),
      body: !isSignedIn
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n?.signInToSync ?? 'Sign in to sync.'),
                  const SizedBox(height: 12),
                  AppButtons.primary(
                    onPressed: () => context.push('/auth'),
                    label: l10n?.signIn ?? 'Sign in',
                  ),
                ],
              ),
            )
          : _MemberNovelsList(l10n: l10n),
    );
  }
}

class _MemberNovelsList extends ConsumerWidget {
  const _MemberNovelsList({required this.l10n});
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novelsAsync = ref.watch(memberNovelsProvider);

    return novelsAsync.when(
      data: (novels) {
        if (novels.isEmpty) {
          return NovelEmptyState(
            title: l10n?.noNovelsFound ?? 'No novels found.',
            subtitle: 'Create your first novel to get started.',
            actionLabel: l10n?.createNovel ?? 'Create Novel',
            onAction: () => context.push('/create-novel'),
          );
        }
        return ListView.separated(
          itemCount: novels.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final n = novels[index];
            return _NovelTile(novel: n);
          },
        );
      },
      loading: () =>
          Center(child: Text(l10n?.loadingNovels ?? 'Loading novels…')),
      error: (err, _) {
        if (err is ApiException && err.statusCode == 401) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: Text(l10n?.errorLoadingNovels ?? 'Error loading novels'),
        );
      },
    );
  }
}

class _NovelTile extends StatelessWidget {
  const _NovelTile({required this.novel});
  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ImageUtils.getFilteredCoverUrl(novel.coverUrl) != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ImageUtils.getFilteredCoverUrl(novel.coverUrl)!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.menu_book),
              ),
            )
          : const Icon(Icons.menu_book),
      title: Text(novel.title),
      subtitle: novel.author != null && novel.author!.isNotEmpty
          ? Text(novel.author!)
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.goNamed('novel', pathParameters: {'id': novel.id}),
    );
  }
}
