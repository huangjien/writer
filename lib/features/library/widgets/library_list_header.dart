import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class LibraryListHeader extends StatelessWidget {
  const LibraryListHeader({
    super.key,
    required this.visibleCount,
    required this.totalCount,
    required this.sortValue,
    required this.onSortChanged,
  });
  final int visibleCount;
  final int totalCount;
  final String sortValue;
  final ValueChanged<String> onSortChanged;

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
            Text('$visibleCount / $totalCount ${l10n.novels}'),
            const Spacer(),
            const Icon(Icons.sort, size: 16),
            const SizedBox(width: 6),
            DropdownButton<dynamic>(
              key: const Key('sortDropdown'),
              value: sortValue,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem<dynamic>(
                  value: 'titleAsc',
                  child: Text(l10n.titleLabel),
                ),
                DropdownMenuItem<dynamic>(
                  value: 'authorAsc',
                  child: Text(l10n.authorLabel),
                ),
              ],
              onChanged: (v) {
                if (v is String) onSortChanged(v);
              },
            ),
          ],
        ),
        const SizedBox(height: Spacing.s),
      ],
    );
  }
}
