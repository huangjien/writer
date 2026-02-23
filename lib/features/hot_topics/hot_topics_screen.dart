import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/hot_topic.dart';
import 'package:writer/features/hot_topics/hot_topics_providers.dart';
import 'package:writer/shared/utils/open_url.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';

class HotTopicsScreen extends ConsumerStatefulWidget {
  const HotTopicsScreen({super.key});

  @override
  ConsumerState<HotTopicsScreen> createState() => _HotTopicsScreenState();
}

class _HotTopicsScreenState extends ConsumerState<HotTopicsScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(hotTopicsFilterProvider);
    final latestTopicsAsync = ref.watch(latestHotTopicsProvider);
    final platformsAsync = ref.watch(hotTopicsPlatformsProvider);
    final l10n = AppLocalizations.of(context);

    return GlobalShortcutsWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.hotTopics ?? 'Hot Topics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(latestHotTopicsProvider);
              },
              tooltip: l10n?.reload ?? 'Refresh',
            ),
          ],
        ),
        drawer: null,
        body: Column(
          children: [
            _PlatformFilter(
              currentPlatform: filter.platformKey,
              platformsAsync: platformsAsync,
              onPlatformChanged: (platform) {
                ref.read(hotTopicsFilterProvider.notifier).state = filter
                    .copyWith(platformKey: platform);
                ref.invalidate(latestHotTopicsProvider);
              },
            ),
            Expanded(
              child: latestTopicsAsync.when(
                data: (topics) {
                  if (topics.isEmpty) {
                    return const _EmptyState();
                  }
                  return _TopicsList(topics: topics);
                },
                loading: () => const _LoadingState(),
                error: (error, stack) => _ErrorState(error: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformFilter extends StatelessWidget {
  final String? currentPlatform;
  final AsyncValue<List<HotTopicPlatform>> platformsAsync;
  final ValueChanged<String?> onPlatformChanged;

  static const String _allPlatformsKey = '__all__';

  const _PlatformFilter({
    required this.currentPlatform,
    required this.platformsAsync,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final selectPlatformLabel =
        l10n?.hotTopicsSelectPlatform ?? 'Select platform';
    final allPlatformsLabel = l10n?.hotTopicsAllPlatforms ?? 'All Platforms';

    return platformsAsync.when(
      data: (platforms) {
        if (platforms.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PopupMenuButton<String>(
                  tooltip: selectPlatformLabel,
                  onSelected: (platformKey) {
                    onPlatformChanged(
                      platformKey == _allPlatformsKey ? null : platformKey,
                    );
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: _allPlatformsKey,
                        child: Row(
                          children: [
                            Icon(
                              Icons.public,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(allPlatformsLabel)),
                            if (currentPlatform == null)
                              Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      ...platforms.map((platform) {
                        final isSelected =
                            currentPlatform == platform.platformKey;
                        return PopupMenuItem<String>(
                          value: platform.platformKey,
                          child: Row(
                            children: [
                              Icon(
                                _getPlatformIcon(platform.platformKey),
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_getPlatformLabel(l10n, platform)),
                                    Text(
                                      _getPlatformDescription(
                                        l10n,
                                        platform.platformKey,
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        );
                      }),
                    ];
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentPlatform == null
                              ? Icons.public
                              : _getPlatformIcon(currentPlatform!),
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentPlatform == null
                                ? allPlatformsLabel
                                : _getPlatformLabel(
                                    l10n,
                                    platforms.firstWhere(
                                      (p) => p.platformKey == currentPlatform,
                                      orElse: () => platforms.first,
                                    ),
                                  ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  IconData _getPlatformIcon(String platformKey) {
    switch (platformKey) {
      case 'weibo':
        return Icons.forum;
      case 'zhihu':
        return Icons.help_outline;
      case 'douyin':
        return Icons.video_library;
      default:
        return Icons.public;
    }
  }

  String _getPlatformLabel(AppLocalizations? l10n, HotTopicPlatform platform) {
    switch (platform.platformKey) {
      case 'weibo':
        return l10n?.hotTopicsPlatformWeibo ?? 'Weibo';
      case 'zhihu':
        return l10n?.hotTopicsPlatformZhihu ?? 'Zhihu';
      case 'douyin':
        return l10n?.hotTopicsPlatformDouyin ?? 'Douyin';
      default:
        return platform.name;
    }
  }

  String _getPlatformDescription(AppLocalizations? l10n, String platformKey) {
    switch (platformKey) {
      case 'weibo':
        return l10n?.hotTopicsPlatformDescWeibo ?? 'Chinese microblogging';
      case 'zhihu':
        return l10n?.hotTopicsPlatformDescZhihu ?? 'Q&A platform';
      case 'douyin':
        return l10n?.hotTopicsPlatformDescDouyin ?? 'Video sharing';
      default:
        return '';
    }
  }
}

class _TopicsList extends StatelessWidget {
  final List<HotTopic> topics;

  const _TopicsList({required this.topics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return _TopicCard(
          topic: topic,
          rank: topic.rank > 0 ? topic.rank : index + 1,
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  final HotTopic topic;
  final int rank;

  const _TopicCard({required this.topic, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final url = topic.url;
    final hasUrl = url != null && url.isNotEmpty;
    final description = topic.description?.trim();
    final summaryText = (description != null && description.isNotEmpty)
        ? description
        : (hasUrl ? _displayUrl(url) : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: hasUrl ? () => openUrl(context, url) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _RankBadge(rank: rank),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (summaryText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        summaryText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _PlatformChip(platformKey: topic.platformKey),
                        _DateChip(crawledAt: topic.crawledAt),
                        if ((topic.heatScore ?? 0) > 0)
                          _HeatScoreChip(score: topic.heatScore!),
                        if (topic.likeCount != null)
                          _StatChip(
                            icon: Icons.favorite,
                            value: _formatCount(topic.likeCount!),
                          ),
                        if (topic.commentCount != null)
                          _StatChip(
                            icon: Icons.comment,
                            value: _formatCount(topic.commentCount!),
                          ),
                        if (topic.novelPotentialScore != null)
                          _NovelPotentialChip(
                            score: topic.novelPotentialScore!,
                          ),
                        if (topic.genreTags != null &&
                            topic.genreTags!.isNotEmpty)
                          _GenreChip(genre: topic.genreTags!.first),
                        if (topic.storySentiment != null)
                          _SentimentChip(sentiment: topic.storySentiment!),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasUrl)
                IconButton(
                  tooltip: l10n?.openLink ?? 'Open link',
                  onPressed: () => openUrl(context, url),
                  icon: const Icon(Icons.open_in_new),
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host.isEmpty) return url;
    return uri.host;
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (rank <= 3) {
      color = Theme.of(context).colorScheme.error;
    } else if (rank <= 10) {
      color = Theme.of(context).colorScheme.tertiary;
    } else {
      color = Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String platformKey;

  const _PlatformChip({required this.platformKey});

  String _platformName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (platformKey.toLowerCase()) {
      case 'weibo':
        return l10n?.hotTopicsPlatformWeibo ?? 'Weibo';
      case 'zhihu':
        return l10n?.hotTopicsPlatformZhihu ?? 'Zhihu';
      case 'douyin':
        return l10n?.hotTopicsPlatformDouyin ?? 'Douyin';
      default:
        return platformKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_platformName(context)),
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime crawledAt;

  const _DateChip({required this.crawledAt});

  String _formatDate(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(crawledAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${crawledAt.year}-${crawledAt.month.toString().padLeft(2, '0')}-${crawledAt.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_formatDate(context)),
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        Icons.schedule,
        size: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _HeatScoreChip extends StatelessWidget {
  final int score;

  const _HeatScoreChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score > 1000000
        ? Theme.of(context).colorScheme.error
        : score > 500000
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _formatHeatScore(score),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHeatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NovelPotentialChip extends StatelessWidget {
  final int score;

  const _NovelPotentialChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? Theme.of(context).colorScheme.primary
        : score >= 60
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories, size: 14),
          const SizedBox(width: 4),
          Text(
            'Novel: $score',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String genre;

  const _GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 14,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            genre,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentChip extends StatelessWidget {
  final String sentiment;

  const _SentimentChip({required this.sentiment});

  IconData get _icon {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_very_satisfied;
      case 'negative':
        return Icons.sentiment_very_dissatisfied;
      case 'mixed':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color get _color {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return const Color(0xFF4CAF50);
      case 'negative':
        return const Color(0xFFF44336);
      case 'mixed':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            sentiment,
            style: TextStyle(
              fontSize: 12,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load hot topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hot topics found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different platform',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
