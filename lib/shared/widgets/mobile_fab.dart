import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'glass_card.dart';
import 'spring_animated_container.dart';
import 'focus_wrapper.dart';

/// Mobile-optimized Floating Action Button
/// Features:
/// - Extended FAB with label for better discoverability
/// - Material 3 design
/// - Smooth animations
/// - Haptic feedback support
enum MobileFabType {
  primary, // Create Novel
  secondary, // Save
  action, // Next Chapter
}

class MobileFab extends StatelessWidget {
  const MobileFab({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.type = MobileFabType.primary,
    this.extended = true,
    this.isLoading = false,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final MobileFabType type;
  final bool extended;
  final bool isLoading;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getBackgroundColor() {
      switch (type) {
        case MobileFabType.primary:
          return colorScheme.primary;
        case MobileFabType.secondary:
          return colorScheme.secondary;
        case MobileFabType.action:
          return colorScheme.tertiary;
      }
    }

    Color getForegroundColor() {
      switch (type) {
        case MobileFabType.primary:
          return colorScheme.onPrimary;
        case MobileFabType.secondary:
          return colorScheme.onSecondary;
        case MobileFabType.action:
          return colorScheme.onTertiary;
      }
    }

    Widget buildChild() {
      if (isLoading) {
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }

      if (extended) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: Spacing.s),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        );
      }

      return Icon(icon, size: 24);
    }

    if (extended) {
      return Semantics(
        button: true,
        label: label,
        enabled: !isLoading,
        child: FocusWrapper(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(Radii.xl),
          child: FloatingActionButton.extended(
            heroTag: heroTag ?? 'mobile_fab_$type',
            onPressed: isLoading ? null : onPressed,
            backgroundColor: getBackgroundColor(),
            foregroundColor: getForegroundColor(),
            elevation: 6,
            tooltip: label,
            extendedPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.l,
              vertical: Spacing.m,
            ),
            label: buildChild(),
          ),
        ),
      );
    } else {
      return Semantics(
        button: true,
        label: label,
        enabled: !isLoading,
        child: FocusWrapper(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(Radii.xl),
          child: FloatingActionButton(
            heroTag: heroTag ?? 'mobile_fab_$type',
            onPressed: isLoading ? null : onPressed,
            backgroundColor: getBackgroundColor(),
            foregroundColor: getForegroundColor(),
            elevation: 6,
            tooltip: label,
            child: Icon(icon),
          ),
        ),
      );
    }
  }
}

/// Mini FAB for secondary actions
class MobileMiniFab extends StatelessWidget {
  const MobileMiniFab({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      key: const ValueKey('mini_fab_container'),
      width: 40,
      height: 40,
      child: Semantics(
        button: true,
        label: tooltip,
        child: FocusWrapper(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(Radii.xl),
          child: FloatingActionButton.small(
            heroTag: heroTag ?? 'mini_fab_$tooltip',
            key: const ValueKey('mini_fab_button'),
            onPressed: onPressed,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            elevation: 4,
            tooltip: tooltip,
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}

/// FAB with menu support
class MobileFabWithMenu extends StatefulWidget {
  const MobileFabWithMenu({
    super.key,
    required this.items,
    required this.mainLabel,
    required this.mainIcon,
  });

  final List<FabMenuItem> items;
  final String mainLabel;
  final IconData mainIcon;

  @override
  State<MobileFabWithMenu> createState() => _MobileFabWithMenuState();
}

class _MobileFabWithMenuState extends State<MobileFabWithMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MobileMotion.fabExpand,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded menu items
        if (_isExpanded)
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return SpringAnimatedContainer(
                  expanded: true,
                  delay: Duration(milliseconds: 30 * index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.s),
                    child: _FabMenuItem(
                      label: item.label,
                      icon: item.icon,
                      onTap: () {
                        _toggle();
                        item.onTap();
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        // Main FAB
        Semantics(
          button: true,
          label: widget.mainLabel,
          child: FocusWrapper(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(Radii.xl),
            child: FloatingActionButton.extended(
              onPressed: _toggle,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 6,
              icon: RotationTransition(
                key: const ValueKey('fab_menu_rotation'),
                turns: _rotateAnimation,
                child: Icon(widget.mainIcon),
              ),
              label: Text(widget.mainLabel),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabMenuItem extends StatelessWidget {
  const _FabMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: FocusWrapper(
        borderRadius: BorderRadius.circular(Radii.m),
        child: GlassCard(
          key: ValueKey('fab_menu_item_$label'),
          borderRadius: BorderRadius.circular(Radii.m),
          shadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(Radii.m),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: Spacing.s),
                    Icon(icon, size: 20, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FabMenuItem {
  const FabMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}
