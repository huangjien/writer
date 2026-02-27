import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';

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

    Widget viewModeToggle() {
      return Container(
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
      );
    }

    Widget sortControl() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort, size: 16),
          const SizedBox(width: 6),
          NeumorphicDropdown<String>(
            key: const Key('sortDropdown'),
            value: sortValue,
            items: [
              DropdownMenuItem<String>(
                value: 'titleAsc',
                child: Text(l10n.titleLabel),
              ),
              DropdownMenuItem<String>(
                value: 'authorAsc',
                child: Text(l10n.authorLabel),
              ),
            ],
            onChanged: (v) {
              if (v != null) onSortChanged(v);
            },
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.library_books, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$visibleCount / $totalCount ${l10n.novels}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.s),
              Wrap(
                spacing: Spacing.m,
                runSpacing: Spacing.s,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [viewModeToggle(), sortControl()],
              ),
              const SizedBox(height: Spacing.s),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.library_books, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$visibleCount / $totalCount ${l10n.novels}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                viewModeToggle(),
                const SizedBox(width: 12),
                sortControl(),
              ],
            ),
            const SizedBox(height: Spacing.s),
          ],
        );
      },
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
      child: SizedBox(
        width: 38,
        height: 38,
        child: NeumorphicButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(Radii.s),
          depth: isSelected ? 3 : 6,
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : null,
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
