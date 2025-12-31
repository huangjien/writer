import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/theme/design_tokens.dart';

/// Enum for haptic feedback intensity
enum HapticImpact { light, medium, heavy }

/// Mobile gestures and haptic feedback utilities
/// Features:
/// - Haptic feedback on button presses
/// - Long-press menus for context actions
/// - Gesture detectors for swipe actions
class MobileGestures {
  /// Light haptic feedback for button presses
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for successful actions
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for destructive actions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection feedback
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Haptic feedback for toggle actions
  static void toggleImpact() {
    HapticFeedback.lightImpact();
  }
}

/// Widget wrapper for haptic feedback
/// Wraps any widget with haptic feedback on tap
class HapticTap extends StatelessWidget {
  const HapticTap({
    super.key,
    required this.child,
    this.impact = HapticImpact.light,
    this.onLongPress,
  });

  final Widget child;
  final HapticImpact impact;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (impact) {
          case HapticImpact.light:
            MobileGestures.lightImpact();
            break;
          case HapticImpact.medium:
            MobileGestures.mediumImpact();
            break;
          case HapticImpact.heavy:
            MobileGestures.heavyImpact();
            break;
        }
      },
      onLongPress: () {
        if (onLongPress != null) {
          MobileGestures.heavyImpact();
          onLongPress!();
        }
      },
      child: child,
    );
  }
}

/// Widget wrapper for long-press menus
/// Shows context menu on long press
class LongPressMenu extends StatefulWidget {
  const LongPressMenu({
    super.key,
    required this.child,
    required this.menuItems,
    required this.onItemSelected,
  });

  final Widget child;
  final List<MenuItem> menuItems;
  final ValueChanged<int?> onItemSelected;

  @override
  State<LongPressMenu> createState() => _LongPressMenuState();
}

class _LongPressMenuState extends State<LongPressMenu> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        widget.child,
        if (_selectedIndex != null)
          Positioned.fill(child: _buildMenuOverlay(context, theme)),
      ],
    );
  }

  Widget _buildMenuOverlay(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = null;
        });
      },
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...widget.menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onItemSelected(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.m,
                      vertical: Spacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.s),
                    ),
                    child: Row(
                      children: [
                        if (item.icon != null)
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        if (item.icon != null) const SizedBox(width: Spacing.s),
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu item for long-press menus
class MenuItem {
  const MenuItem({required this.label, this.icon, this.value});

  final String label;
  final IconData? icon;
  final dynamic value;
}

/// Swipe action wrapper with haptic feedback
class SwipeAction extends StatelessWidget {
  const SwipeAction({
    super.key,
    required this.child,
    required this.onSwipe,
    required this.direction,
  });

  final Widget child;
  final VoidCallback onSwipe;
  final SwipeDirection direction;

  DismissDirection _getDismissDirection() {
    switch (direction) {
      case SwipeDirection.endToStart:
        return DismissDirection.endToStart;
      case SwipeDirection.startToEnd:
        return DismissDirection.startToEnd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe_${direction.name}'),
      direction: _getDismissDirection(),
      confirmDismiss: (direction) async {
        // Provide haptic feedback
        MobileGestures.lightImpact();
        onSwipe();
        return true;
      },
      background: _buildSwipeBackground(context, direction),
      child: child,
    );
  }

  Widget _buildSwipeBackground(BuildContext context, SwipeDirection direction) {
    final theme = Theme.of(context);
    final isLeft = direction == SwipeDirection.endToStart;

    Color getBackgroundColor() {
      switch (direction) {
        case SwipeDirection.endToStart:
          return theme.colorScheme.errorContainer;
        case SwipeDirection.startToEnd:
          return theme.colorScheme.primaryContainer;
      }
    }

    IconData getIcon() {
      switch (direction) {
        case SwipeDirection.endToStart:
          return Icons.delete;
        case SwipeDirection.startToEnd:
          return Icons.archive;
      }
    }

    Color getIconColor() {
      switch (direction) {
        case SwipeDirection.endToStart:
          return theme.colorScheme.onError;
        case SwipeDirection.startToEnd:
          return theme.colorScheme.onPrimaryContainer;
      }
    }

    return Container(
      color: getBackgroundColor(),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Icon(getIcon(), size: 32, color: getIconColor()),
        ),
      ),
    );
  }
}

/// Enum for swipe direction
enum SwipeDirection { endToStart, startToEnd }
