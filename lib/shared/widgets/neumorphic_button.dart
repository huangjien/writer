import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';

class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius,
    this.padding,
    this.color,
    this.depth,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? depth;
  final String? semanticLabel;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null;
    final radius =
        widget.borderRadius ??
        theme.buttonBorderRadius ??
        BorderRadius.circular(Radii.m);
    final depthFactor = isDisabled
        ? 0.0
        : ((widget.depth ?? 6.0) + (_isHovered ? 1.0 : 0.0)) / 6.0;

    Color background =
        widget.color ??
        theme.buttonBackgroundColor ??
        theme.colorScheme.surface;

    if (isDisabled) {
      background = background.withValues(alpha: 0.6);
    }

    List<BoxShadow>? scaleShadows(List<BoxShadow>? shadows) {
      if (shadows == null) return null;
      return shadows
          .map(
            (s) => s.copyWith(
              blurRadius: s.blurRadius * depthFactor,
              spreadRadius: s.spreadRadius * depthFactor,
              offset: Offset(
                s.offset.dx * depthFactor,
                s.offset.dy * depthFactor,
              ),
            ),
          )
          .toList(growable: false);
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: !isDisabled,
        mouseCursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onShowHoverHighlight: (value) {
          if (isDisabled) return;
          if (_isHovered == value) return;
          setState(() => _isHovered = value);
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTapDown: isDisabled
              ? null
              : (_) => setState(() => _isPressed = true),
          onTapUp: isDisabled
              ? null
              : (_) => setState(() => _isPressed = false),
          onTapCancel: isDisabled
              ? null
              : () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: Spacing.l,
                  vertical: Spacing.m,
                ),
            decoration: BoxDecoration(
              color: _isPressed
                  ? (theme.buttonPressedColor ?? background)
                  : background,
              borderRadius: radius,
              boxShadow: _isPressed
                  ? scaleShadows(theme.buttonPressedShadows)
                  : scaleShadows(theme.buttonShadows),
              border: theme.buttonBorder,
            ),
            transform: _isPressed && !isDisabled
                ? Matrix4.translationValues(1, 1, 0)
                : (_isHovered && !isDisabled
                      ? Matrix4.translationValues(0, -0.5, 0)
                      : Matrix4.identity()),
            child: Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
