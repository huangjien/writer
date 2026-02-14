import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/theme_aware_card.dart';

/// Screen to display token usage history
class TokenUsageHistoryScreen extends ConsumerStatefulWidget {
  const TokenUsageHistoryScreen({super.key});

  @override
  ConsumerState<TokenUsageHistoryScreen> createState() =>
      _TokenUsageHistoryScreenState();
}

class _TokenUsageHistoryScreenState
    extends ConsumerState<TokenUsageHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentOffset = 0;
  static const _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  void _loadMore() {
    final historyAsync = ref.read(
      usageHistoryProvider(
        UsageHistoryParams(limit: _pageSize, offset: _currentOffset),
      ),
    );
    if (historyAsync.value == null) return;

    final currentHistory = historyAsync.value;
    if (currentHistory != null && currentHistory.records.length >= _pageSize) {
      setState(() {
        _currentOffset += _pageSize;
      });
    }
  }

  void _refresh() {
    ref.invalidate(
      usageHistoryProvider(UsageHistoryParams(limit: _pageSize, offset: 0)),
    );
    setState(() {
      _currentOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(
      usageHistoryProvider(
        UsageHistoryParams(limit: _pageSize, offset: _currentOffset),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.viewHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history == null || history.records.isEmpty) {
            return _EmptyHistory(l10n: l10n);
          }
          return Column(
            children: [
              _SummaryCard(history: history, l10n: l10n),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: history.records.length + 1,
                  itemBuilder: (context, index) {
                    if (index == history.records.length) {
                      return _LoadingMoreIndicator(
                        hasMore: history.records.length >= _pageSize,
                      );
                    }
                    return _UsageHistoryItem(
                      record: history.records[index],
                      l10n: l10n,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          if (err is ApiException && err.statusCode == 401) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ErrorHistory(
            error: err.toString(),
            l10n: l10n,
            onRetry: () {
              setState(() {
                _currentOffset = 0;
              });
              ref.invalidate(
                usageHistoryProvider(
                  UsageHistoryParams(limit: _pageSize, offset: 0),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.history, required this.l10n});

  final TokenUsageHistory history;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    final totalInputTokens = history.records.fold<int>(
      0,
      (sum, r) => sum + r.inputTokens,
    );
    final totalOutputTokens = history.records.fold<int>(
      0,
      (sum, r) => sum + r.outputTokens,
    );
    final totalTokens = totalInputTokens + totalOutputTokens;

    return Container(
      margin: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Radii.m)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.m),
        child: GradientBackground(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          child: Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Column(
              children: [
                Text(
                  l10n.totalRecords(history.totalCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: l10n.inputTokens,
                      value: formatter.format(totalInputTokens),
                      color: theme.colorScheme.primary,
                      icon: Icons.arrow_upward,
                    ),
                    _SummaryItem(
                      label: l10n.outputTokens,
                      value: formatter.format(totalOutputTokens),
                      color: theme.colorScheme.secondary,
                      icon: Icons.arrow_downward,
                    ),
                    _SummaryItem(
                      label: l10n.total,
                      value: formatter.format(totalTokens),
                      color: theme.colorScheme.tertiary,
                      icon: Icons.token_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _UsageHistoryItem extends StatelessWidget {
  const _UsageHistoryItem({required this.record, required this.l10n});

  final TokenUsageRecord record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat.yMd().add_jms();

    return ThemeAwareCard(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getOperationIcon(record.operationType),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.s),
                Expanded(
                  child: Text(
                    record.modelName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (record.createdAt != null)
                  Text(
                    dateFormatter.format(record.createdAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.s),
            Row(
              children: [
                _TokenBadge(
                  label: l10n.inputTokens,
                  value: formatter.format(record.inputTokens),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.s),
                _TokenBadge(
                  label: l10n.outputTokens,
                  value: formatter.format(record.outputTokens),
                  color: theme.colorScheme.secondary,
                ),
                const Spacer(),
                Text(
                  '${formatter.format(record.totalTokens)} ${l10n.total.toLowerCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (record.metadata != null && record.metadata!.isNotEmpty) ...[
              const SizedBox(height: Spacing.s),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: record.metadata!.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getOperationIcon(String operationType) {
    switch (operationType.toLowerCase()) {
      case 'completion':
        return Icons.auto_awesome;
      case 'chat':
        return Icons.chat;
      case 'embedding':
        return Icons.view_in_ar;
      default:
        return Icons.auto_awesome;
    }
  }
}

class _TokenBadge extends StatelessWidget {
  const _TokenBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: theme.textTheme.bodySmall),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: Spacing.m),
            Text(
              l10n.noUsageHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.s),
            Text(
              l10n.startUsingAiFeatures,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorHistory extends StatelessWidget {
  const _ErrorHistory({
    required this.error,
    required this.l10n,
    required this.onRetry,
  });

  final String error;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: Spacing.m),
            Text(
              l10n.errorLoadingUsage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: Spacing.s),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.m),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reload),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator({required this.hasMore});

  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.all(Spacing.m),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
