import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';

import '../state/novel_providers.dart';

class RecentChapters extends ConsumerWidget {
  const RecentChapters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentProgressDetails = ref.watch(recentProgressDetailsProvider);
    return recentProgressDetails.when(
      data: (detailsList) {
        if (detailsList.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noRecentChapters),
          );
        }
        return ListView.separated(
          itemCount: detailsList.length,
          separatorBuilder: (context, index) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            final details = detailsList[index];
            return ListTile(
              title: Text(details.novel.title),
              subtitle: Text(
                '${AppLocalizations.of(context)!.chapter}: ${details.chapter.title}\n${AppLocalizations.of(context)!.lastRead}: ${details.userProgress.updatedAt}',
              ),
              onTap: () {
                try {
                  context.push(
                    '/novel/${details.novel.id}/chapters/${details.chapter.id}',
                  );
                } catch (_) {
                  Navigator.of(context).pushNamed(
                    '/novel/${details.novel.id}/chapters/${details.chapter.id}',
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${AppLocalizations.of(context)!.error}: $error')),
    );
  }
}
