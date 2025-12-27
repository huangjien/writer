import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:intl/intl.dart';
import '../../../theme/design_tokens.dart';

/// Enhanced token usage section with modern design
/// Features:
/// - Summary card with gradient background
/// - Token breakdown with icons
/// - View history action
/// - Loading and error states
class TokenUsageSection extends ConsumerWidget {
  const TokenUsageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(currentMonthUsageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          child: Row(
            children: [
              Icon(
                Icons.token_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: Spacing.s),
              Text(
                'Token Usage',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        usageAsync.when(
          data: (usage) {
            if (usage == null) {
              return _EmptyUsage();
            }
            return _UsageData(usage: usage);
          },
          loading: () => _LoadingUsage(),
          error: (err, stack) => _ErrorUsage(error: err.toString()),
        ),
      ],
    );
  }
}

class _UsageData extends StatelessWidget {
  const _UsageData({required this.usage});

  final TokenUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: Column(
        children: [
          // Summary card with gradient
          Container(
            padding: const EdgeInsets.all(Spacing.l),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(Radii.m),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total This Month',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: Spacing.s),
                Text(
                  formatter.format(usage.totalTokens),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  '${usage.requestCount} requests',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.m),
          // Token breakdown
          _UsageRow(
            label: 'Input Tokens',
            value: formatter.format(usage.inputTokens),
            color: theme.colorScheme.primary,
            icon: Icons.arrow_upward,
          ),
          _UsageRow(
            label: 'Output Tokens',
            value: formatter.format(usage.outputTokens),
            color: theme.colorScheme.secondary,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(height: Spacing.m),
          // View history button
          TextButton.icon(
            onPressed: () {
              // TODO: Navigate to history screen
            },
            icon: const Icon(Icons.history),
            label: const Text('View History'),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.token_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.m),
          Text(
            'No usage this month',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.s),
          Text(
            'Start using AI features to see your token consumption',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Spacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorUsage extends StatelessWidget {
  const _ErrorUsage({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(Spacing.m),
      child: Container(
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(Radii.m),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: Spacing.s),
            Expanded(
              child: Text(
                'Error loading usage',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
