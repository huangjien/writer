import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/hot_topic.dart';
import 'package:writer/features/hot_topics/hot_topics_providers.dart';
import 'package:writer/widgets/app_drawer.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';

class HotTopicsScreen extends ConsumerStatefulWidget {
  const HotTopicsScreen({super.key});

  @override
  ConsumerState<HotTopicsScreen> createState() => _HotTopicsScreenState();
}

class _HotTopicsScreenState extends ConsumerState<HotTopicsScreen> {
  MobileNavTab _currentTab = MobileNavTab.home;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(hotTopicsFilterProvider);
    final latestTopicsAsync = ref.watch(latestHotTopicsProvider);
    final platformsAsync = ref.watch(hotTopicsPlatformsProvider);

    return GlobalShortcutsWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hot Topics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(latestHotTopicsProvider);
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        drawer: const AppDrawer(),
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
        bottomNavigationBar: MobileBottomNavBar(
          currentTab: _currentTab,
          onTabChanged: (tab) {
            setState(() {
              _currentTab = tab;
            });
          },
        ),
      ),
    );
  }
}

class _PlatformFilter extends StatelessWidget {
  final String? currentPlatform;
  final AsyncValue<List<HotTopicPlatform>> platformsAsync;
  final ValueChanged<String?> onPlatformChanged;

  const _PlatformFilter({
    required this.currentPlatform,
    required this.platformsAsync,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    return platformsAsync.when(
      data: (platforms) {
        if (platforms.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: platforms.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All Platforms'),
                    selected: currentPlatform == null,
                    onSelected: (_) => onPlatformChanged(null),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                  ),
                );
              }

              final platform = platforms[index - 1];
              final isSelected = currentPlatform == platform.platformKey;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(platform.name),
                  selected: isSelected,
                  onSelected: (_) => onPlatformChanged(platform.platformKey),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                ),
              );
            },
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
        return _TopicCard(topic: topic, rank: index + 1);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: topic.url != null
            ? () {
                // TODO: Open URL or show topic details
              }
            : null,
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
                    if (topic.description != null &&
                        topic.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        topic.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _PlatformChip(platformKey: topic.platformKey),
                        if (topic.heatScore != null)
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
            ],
          ),
        ),
      ),
    );
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

  String get _platformName {
    switch (platformKey.toLowerCase()) {
      case 'weibo':
        return 'Weibo';
      case 'zhihu':
        return 'Zhihu';
      case 'douyin':
        return 'Douyin';
      default:
        return platformKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_platformName),
      visualDensity: VisualDensity.compact,
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
