import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading/shimmer_skeleton.dart';
import '../../../shared/widgets/loading/skeleton_list_items.dart';
import '../../../theme/design_tokens.dart';

class LibraryLoadingList extends StatelessWidget {
  const LibraryLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.library_books, size: 16),
            const SizedBox(width: 6),
            Text(l10n.loadingNovels),
          ],
        ),
        const SizedBox(height: Spacing.s),
        Expanded(
          child: ShimmerSkeleton(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  6,
                  (index) => const LibraryItemRowSkeleton(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
