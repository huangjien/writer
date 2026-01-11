import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class LibraryLoadingList extends StatelessWidget {
  const LibraryLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

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
          child: Skeletonizer(
            effect: ShimmerEffect(
              baseColor: theme.colorScheme.surfaceContainer,
              highlightColor: theme.colorScheme.surfaceContainerHighest,
              duration: const Duration(milliseconds: 1500),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(6, (index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            borderRadius: BorderRadius.circular(Radii.s),
                          ),
                        ),
                        title: Container(height: 16, color: placeholderColor),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(height: 12, color: placeholderColor),
                        ),
                        trailing: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      if (index < 5) const Divider(height: 1),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
