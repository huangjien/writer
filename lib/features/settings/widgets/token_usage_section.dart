import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:intl/intl.dart';

class TokenUsageSection extends ConsumerWidget {
  const TokenUsageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(currentMonthUsageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Token Usage (Current Month)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        usageAsync.when(
          data: (usage) {
            if (usage == null) {
              return const ListTile(
                title: Text('No usage recorded this month'),
              );
            }
            final formatter = NumberFormat('#,###');
            return Column(
              children: [
                ListTile(
                  title: const Text('Input Tokens'),
                  trailing: Text(formatter.format(usage.inputTokens)),
                ),
                ListTile(
                  title: const Text('Output Tokens'),
                  trailing: Text(formatter.format(usage.outputTokens)),
                ),
                ListTile(
                  title: const Text('Total Tokens'),
                  trailing: Text(formatter.format(usage.totalTokens)),
                  subtitle: Text('${usage.requestCount} requests'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ListTile(
            title: const Text('Error loading usage'),
            subtitle: Text(err.toString()),
          ),
        ),
      ],
    );
  }
}
