import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import 'glass_card.dart';
import 'focus_wrapper.dart';

/// Mobile-optimized bottom sheet
/// Features:
/// - Smooth slide-up animation
/// - Drag handle for dismiss
/// - Rounded top corners
/// - Scrollable content
class MobileBottomSheet {
  /// Show a modal bottom sheet with custom content
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.l)),
      ),
      builder: (context) => _SheetFocusTrap(
        child: _MobileBottomSheetContent(
          title: title,
          child: Builder(builder: builder),
        ),
      ),
    );
  }

  /// Show an action sheet with list items
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required List<ActionSheetItem<T>> items,
    String? title,
    String? cancelLabel,
    Color? cancelColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SheetFocusTrap(
        child: _ActionSheetContent(
          title: title,
          items: items,
          cancelLabel: cancelLabel,
          cancelColor: cancelColor,
        ),
      ),
    );
  }

  /// Show a bottom sheet with a list of options
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required List<SheetOption<T>> options,
    String? title,
    T? selectedValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.l)),
      ),
      builder: (context) => _SheetFocusTrap(
        child: _OptionsSheetContent(
          title: title,
          options: options,
          selectedValue: selectedValue,
        ),
      ),
    );
  }
}

class _MobileBottomSheetContent extends StatelessWidget {
  const _MobileBottomSheetContent({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? AppColors.glassSurfaceDark
        : AppColors.glassSurfaceLight;
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return GlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.l)),
      color: surfaceColor,
      borderColor: borderColor,
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: GlassTokens.shadowOpacity),
          blurRadius: GlassTokens.shadowBlurRadius,
          offset: const Offset(0, -6),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: Spacing.s),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          if (title != null) ...[
            const SizedBox(height: Spacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Spacing.s),
            Divider(height: 1, color: theme.dividerColor),
          ],
          // Content
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _ActionSheetContent extends StatelessWidget {
  const _ActionSheetContent({
    this.title,
    required this.items,
    this.cancelLabel,
    this.cancelColor,
  });

  final String? title;
  final List<ActionSheetItem> items;
  final String? cancelLabel;
  final Color? cancelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = cancelLabel ?? 'Cancel';
    final surfaceColor = theme.brightness == Brightness.dark
        ? AppColors.glassSurfaceDark
        : AppColors.glassSurfaceLight;
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return Padding(
      padding: const EdgeInsets.all(Spacing.m),
      child: GlassCard(
        borderRadius: BorderRadius.circular(Radii.l),
        color: surfaceColor,
        borderColor: borderColor,
        shadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: GlassTokens.shadowOpacity),
            blurRadius: GlassTokens.shadowBlurRadius,
            offset: const Offset(0, -6),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.all(Spacing.l),
                child: Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
            ],
            ...items.map((item) {
              final isDestructive = item.isDestructive;
              return Semantics(
                button: true,
                label: item.label,
                child: FocusWrapper(
                  key: ValueKey('action_sheet_item_${item.value}'),
                  borderRadius: BorderRadius.zero,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(item.value);
                      item.onPressed?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.l,
                        vertical: Spacing.m,
                      ),
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(
                              item.icon,
                              color: isDestructive
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: Spacing.m),
                          ],
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDestructive
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Divider(height: 1, color: theme.dividerColor),
            Semantics(
              button: true,
              label: l10n,
              child: FocusWrapper(
                borderRadius: BorderRadius.zero,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.l,
                      vertical: Spacing.m,
                    ),
                    child: Text(
                      l10n,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cancelColor ?? theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.s),
          ],
        ),
      ),
    );
  }
}

class _OptionsSheetContent extends StatelessWidget {
  const _OptionsSheetContent({
    this.title,
    required this.options,
    this.selectedValue,
  });

  final String? title;
  final List<SheetOption> options;
  final dynamic selectedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? AppColors.glassSurfaceDark
        : AppColors.glassSurfaceLight;
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return GlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.l)),
      color: surfaceColor,
      borderColor: borderColor,
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: GlassTokens.shadowOpacity),
          blurRadius: GlassTokens.shadowBlurRadius,
          offset: const Offset(0, -6),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: Spacing.s),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: Spacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Spacing.s),
            Divider(height: 1, color: theme.dividerColor),
          ],
          ...options.map((option) {
            final isSelected = option.value == selectedValue;
            return Semantics(
              button: true,
              selected: isSelected,
              label: option.label,
              child: FocusWrapper(
                borderRadius: BorderRadius.zero,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(option.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.l,
                      vertical: Spacing.m,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: Spacing.s),
        ],
      ),
    );
  }
}

class _SheetFocusTrap extends StatelessWidget {
  const _SheetFocusTrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: FocusScope(
        autofocus: true,
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  Navigator.of(context).maybePop();
                  return null;
                },
              ),
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

class ActionSheetItem<T> {
  const ActionSheetItem({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
    this.onPressed,
  });

  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onPressed;
}

class SheetOption<T> {
  const SheetOption({required this.label, required this.value});

  final String label;
  final T value;
}

/// Draggable bottom sheet widget for use within a scaffold
class DraggableBottomSheet extends StatefulWidget {
  const DraggableBottomSheet({
    super.key,
    required this.child,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.9,
    this.initialChildSize = 0.5,
    this.snap = true,
    this.snapSizes,
    this.borderRadius,
    this.backgroundColor,
  });

  final Widget child;
  final double minChildSize;
  final double maxChildSize;
  final double initialChildSize;
  final bool snap;
  final List<double>? snapSizes;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? AppColors.glassSurfaceDark
        : AppColors.glassSurfaceLight;
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: widget.snap,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return GlassCard(
          borderRadius:
              widget.borderRadius ??
              const BorderRadius.vertical(top: Radius.circular(Radii.l)),
          color: widget.backgroundColor ?? surfaceColor,
          borderColor: borderColor,
          shadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: GlassTokens.shadowOpacity),
              blurRadius: GlassTokens.shadowBlurRadius,
              offset: const Offset(0, -6),
            ),
          ],
          child: Column(
            children: [
              // Drag handle
              GestureDetector(
                onVerticalDragEnd: (_) {
                  // Handle snap
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: Spacing.s),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
