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
  bool _hasFocusWithin = false;
  bool _showFocusHighlightFromManager = false;
  bool? _showFocusHighlightOverride;

  late final FocusNode _focusNode = FocusNode(
    canRequestFocus: widget.autofocus,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();

    _showFocusHighlightFromManager =
        FocusManager.instance.highlightMode != FocusHighlightMode.touch;

    _focusNode.addListener(_handleFocusChange);
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChange);
  }

  @override
  void didUpdateWidget(covariant FocusWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autofocus != widget.autofocus) {
      _focusNode.canRequestFocus = widget.autofocus;
    }
  }

  void _handleFocusChange() {
    final value = _focusNode.hasFocus;
    if (_hasFocusWithin == value) return;
    setState(() => _hasFocusWithin = value);
  }

  void _handleHighlightModeChange(FocusHighlightMode mode) {
    final value = mode != FocusHighlightMode.touch;
    if (_showFocusHighlightFromManager == value) return;
    setState(() => _showFocusHighlightFromManager = value);
  }

  void _handleShowFocusHighlight(bool value) {
    if (_showFocusHighlightOverride == value) return;
    setState(() => _showFocusHighlightOverride = value);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChange,
    );
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
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

    final showFocus =
        _hasFocusWithin &&
        (_showFocusHighlightOverride ?? _showFocusHighlightFromManager);

    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: _handleShowFocusHighlight,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: showFocus
              ? Border.all(color: ringColor, width: FocusTokens.borderWidth)
              : null,
          boxShadow: showFocus
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
