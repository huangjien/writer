import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import 'theme_aware_card.dart';
import 'spring_animated_container.dart';
import 'focus_wrapper.dart';
import 'neumorphic_button.dart';

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
    final fabColor =
        theme.buttonBackgroundColor ??
        theme.cardBackgroundColor ??
        theme.colorScheme.surface;
    final contentColor =
        getForegroundColor(); // Keep original text/icon colors or use primary

    Widget buildChild() {
      if (isLoading) {
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(contentColor),
          ),
        );
      }

      if (extended) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: contentColor),
            const SizedBox(width: Spacing.s),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: contentColor,
              ),
            ),
          ],
        );
      }

      return Icon(icon, size: 24, color: contentColor);
    }

    // Hero tag handling
    final tag = heroTag ?? 'mobile_fab_$type';

    if (extended) {
      return Semantics(
        button: true,
        label: label,
        enabled: !isLoading,
        child: FocusWrapper(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(Radii.xl),
          child: Hero(
            tag: tag,
            child: NeumorphicButton(
              onPressed: isLoading ? null : onPressed,
              color: fabColor,
              depth: 16, // Subtle floating for FAB
              borderRadius: BorderRadius.circular(Radii.xl),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.l,
                vertical: Spacing.m,
              ),
              child: buildChild(),
            ),
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
          child: Hero(
            tag: tag,
            child: SizedBox(
              width: 56,
              height: 56,
              child: NeumorphicButton(
                onPressed: isLoading ? null : onPressed,
                color: fabColor,
                depth: 16, // Subtle floating for FAB
                borderRadius: BorderRadius.circular(Radii.xl),
                padding: EdgeInsets.zero,
                child: buildChild(),
              ),
            ),
          ),
        ),
      );
    }
  }

  Color getForegroundColor() {
    // Use primary color for content to make it pop on the neumorphic background
    // instead of white on primary.
    switch (type) {
      case MobileFabType.primary:
      case MobileFabType.secondary:
      case MobileFabType.action:
        return AppColors.sepiaSeed; // Or use theme.primaryColor
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
        child: ThemeAwareCard(
          key: ValueKey('fab_menu_item_$label'),
          borderRadius: BorderRadius.circular(Radii.m),
          semanticType: CardSemanticType.default_,
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
