import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers.dart';
import '../../../state/novel_providers.dart';
import '../../../state/mock_providers.dart';

class LibraryErrorSection extends ConsumerWidget {
  const LibraryErrorSection({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSupabaseEnabled = ref.watch(supabaseEnabledProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: error.toString(),
            child: const Icon(Icons.warning_amber_rounded, size: 48),
          ),
          const SizedBox(height: 8),
          Text(l10n.error),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(l10n.reload),
            onPressed: () {
              if (isSupabaseEnabled) {
                ref.invalidate(novelsProvider);
              } else {
                ref.invalidate(mockNovelsProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}
