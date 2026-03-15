import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';

import 'package:writer/models/recent_progress_details.dart';
import 'package:writer/state/novel_providers.dart';

class RecentChapters extends ConsumerWidget {
  const RecentChapters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentProgressDetails = ref.watch(recentProgressDetailsProvider);
    return recentProgressDetails.when(
      data: (detailsList) {
        if (detailsList.isEmpty) {
          return const RecentChaptersEmptyState();
        }
        return RecentChaptersList(detailsList: detailsList);
      },
      loading: () => const RecentChaptersLoadingState(),
      error: (error, stack) => RecentChaptersErrorState(error: error),
    );
  }
}

class RecentChaptersLoadingState extends StatelessWidget {
  const RecentChaptersLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class RecentChaptersEmptyState extends StatelessWidget {
  const RecentChaptersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.noRecentChapters));
  }
}

class RecentChaptersErrorState extends StatelessWidget {
  final Object error;

  const RecentChaptersErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('${AppLocalizations.of(context)!.error}: $error'),
    );
  }
}

class RecentChaptersList extends StatelessWidget {
  final List<RecentProgressDetails> detailsList;

  const RecentChaptersList({super.key, required this.detailsList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: detailsList.length,
      itemBuilder: (context, index) {
        final details = detailsList[index];
        return RecentChapterTile(
          key: ValueKey(details.chapter.id),
          details: details,
        );
      },
    );
  }
}

class RecentChapterTile extends StatelessWidget {
  final RecentProgressDetails details;

  const RecentChapterTile({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(details.novel.title),
      subtitle: Text(
        '${l10n.chapter}: ${details.chapter.title}\n${l10n.lastRead}: ${details.userProgress.updatedAt}',
      ),
      onTap: () => _navigateToChapter(context, details),
    );
  }

  void _navigateToChapter(BuildContext context, RecentProgressDetails details) {
    try {
      context.push('/novel/${details.novel.id}/chapters/${details.chapter.id}');
    } catch (_) {
      Navigator.of(
        context,
      ).pushNamed('/novel/${details.novel.id}/chapters/${details.chapter.id}');
    }
  }
}
