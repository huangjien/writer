import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/novel_providers.dart';
import '../../../shared/widgets/app_buttons.dart';

class LibraryErrorSection extends ConsumerWidget {
  const LibraryErrorSection({
    super.key,
    required this.error,
    this.message,
    this.onRetry,
  });
  final Object error;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: error.toString(),
            child: const Icon(Icons.warning_amber_rounded, size: 48),
          ),
          const SizedBox(height: 8),
          Text(message ?? l10n.error),
          const SizedBox(height: 8),
          AppButtons.secondary(
            label: l10n.reload,
            icon: Icons.refresh,
            onPressed:
                onRetry ??
                () {
                  ref.invalidate(libraryNovelsProvider);
                  ref.invalidate(memberNovelsProvider);
                  ref.invalidate(novelsProvider);
                },
          ),
        ],
      ),
    );
  }
}
