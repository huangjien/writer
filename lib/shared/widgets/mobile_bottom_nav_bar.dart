import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Mobile-optimized bottom navigation bar
/// Features:
/// - 5-tab navigation for quick access
/// - Material 3 design
/// - Thumb-friendly placement
/// - Active state indicators
enum MobileNavTab { home, write, read, tools, more }

class MobileBottomNavBar extends StatelessWidget {
  const MobileBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.showBadgeOnTab,
  });

  final MobileNavTab currentTab;
  final ValueChanged<MobileNavTab> onTabChanged;
  final Set<MobileNavTab>? showBadgeOnTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MobileSpacing.bottomNavHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: MobileNavTab.values.map((tab) {
            final isSelected = currentTab == tab;
            final hasBadge = showBadgeOnTab?.contains(tab) ?? false;

            return _NavTabItem(
              tab: tab,
              isSelected: isSelected,
              hasBadge: hasBadge,
              onTap: () => onTabChanged(tab),
              colorScheme: colorScheme,
              theme: theme,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.tab,
    required this.isSelected,
    required this.hasBadge,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  final MobileNavTab tab;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  IconData get _icon {
    switch (tab) {
      case MobileNavTab.home:
        return Icons.menu_book_outlined;
      case MobileNavTab.write:
        return Icons.edit_outlined;
      case MobileNavTab.read:
        return Icons.book_outlined;
      case MobileNavTab.tools:
        return Icons.build_outlined;
      case MobileNavTab.more:
        return Icons.more_horiz;
    }
  }

  IconData get _selectedIcon {
    switch (tab) {
      case MobileNavTab.home:
        return Icons.menu_book;
      case MobileNavTab.write:
        return Icons.edit;
      case MobileNavTab.read:
        return Icons.book;
      case MobileNavTab.tools:
        return Icons.build;
      case MobileNavTab.more:
        return Icons.more_horiz;
    }
  }

  String _getLabel(BuildContext context) {
    switch (tab) {
      case MobileNavTab.home:
        return 'Home';
      case MobileNavTab.write:
        return 'Write';
      case MobileNavTab.read:
        return 'Read';
      case MobileNavTab.tools:
        return 'Tools';
      case MobileNavTab.more:
        return 'More';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.m),
      child: Container(
        width: MobileSpacing.touchTargetComfortable,
        height: MobileSpacing.touchTargetComfortable,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? _selectedIcon : _icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: Spacing.xxs),
                Flexible(
                  child: Text(
                    _getLabel(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (hasBadge)
              Positioned(
                top: 4,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
