import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class FocusWrapper extends StatefulWidget {
  const FocusWrapper({
    super.key,
    required this.child,
    this.borderRadius,
    this.enabled = true,
    this.autofocus = false,
    this.padding = const EdgeInsets.all(2),
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final bool enabled;
  final bool autofocus;
  final EdgeInsets padding;

  @override
  State<FocusWrapper> createState() => _FocusWrapperState();
}

class _FocusWrapperState extends State<FocusWrapper> {
  bool _showFocus = false;

  void _setShowFocus(bool value) {
    if (_showFocus == value) return;
    setState(() => _showFocus = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final theme = Theme.of(context);
    final mq = MediaQuery.maybeOf(context);
    final disableAnimations = mq?.disableAnimations ?? false;
    final duration = disableAnimations ? Duration.zero : FocusTokens.duration;

    final radius = widget.borderRadius ?? BorderRadius.circular(Radii.m + 2);
    final ringColor = theme.colorScheme.primary;

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onShowFocusHighlight: _setShowFocus,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: _showFocus
              ? Border.all(color: ringColor, width: FocusTokens.borderWidth)
              : null,
          boxShadow: _showFocus
              ? [
                  BoxShadow(
                    color: ringColor.withValues(alpha: FocusTokens.glowOpacity),
                    blurRadius: FocusTokens.glowBlurRadius,
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
