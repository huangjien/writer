import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/performance_settings.dart';
import '../../../state/providers.dart';

class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final perf = ref.watch(performanceSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.performanceSettings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SwitchListTile(
          title: Text(l10n.prefetchNextChapter),
          subtitle: Text(l10n.prefetchNextChapterDescription),
          value: perf.prefetchNextChapter,
          onChanged: (value) {
            ref
                .read(performanceSettingsProvider.notifier)
                .setPrefetchNextChapter(value);
          },
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: Text(l10n.clearOfflineCache),
          onTap: () async {
            final repo = ref.read(localStorageRepositoryProvider);
            final count = await repo.clearChapterCache();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${l10n.offlineCacheCleared}${count > 0 ? ' ($count)' : ''}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
