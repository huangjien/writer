import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

enum LibraryViewMode { list, grid }

class LibraryListHeader extends StatelessWidget {
  const LibraryListHeader({
    super.key,
    required this.visibleCount,
    required this.totalCount,
    required this.sortValue,
    required this.onSortChanged,
    required this.viewMode,
    required this.onViewModeChanged,
  });
  final int visibleCount;
  final int totalCount;
  final String sortValue;
  final ValueChanged<String> onSortChanged;
  final LibraryViewMode viewMode;
  final ValueChanged<LibraryViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

            // View mode toggle
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Radii.s),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeButton(
                    icon: Icons.view_list,
                    isSelected: viewMode == LibraryViewMode.list,
                    onTap: () => onViewModeChanged(LibraryViewMode.list),
                    tooltip: l10n.listView,
                  ),
                  _ViewModeButton(
                    icon: Icons.grid_view,
                    isSelected: viewMode == LibraryViewMode.grid,
                    onTap: () => onViewModeChanged(LibraryViewMode.grid),
                    tooltip: l10n.gridView,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Sort dropdown
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          ],
        ),
        const SizedBox(height: Spacing.s),
      ],
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.s),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.s,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.s),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
