import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/novel_providers.dart';

class RecentChapters extends ConsumerWidget {
  const RecentChapters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentProgressDetails = ref.watch(recentProgressDetailsProvider);
    return recentProgressDetails.when(
      data: (detailsList) {
        if (detailsList.isEmpty) {
          return const Center(child: Text('No recent chapters'));
        }
        return ListView.builder(
          itemCount: detailsList.length,
          itemBuilder: (context, index) {
            final details = detailsList[index];
            return ListTile(
              title: Text(details.novel.title),
              subtitle: Text(
                'Chapter: ${details.chapter.title}\nLast read: ${details.userProgress.updatedAt}',
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
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
