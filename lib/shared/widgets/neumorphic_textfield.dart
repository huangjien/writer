import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';

class NeumorphicTextField extends StatefulWidget {
  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.semanticLabel,
    this.obscureLabel,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final String? obscureLabel;

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  FocusNode? _internalFocusNode;
  FocusNode? _listeningFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _listeningFocusNode = _focusNode..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant NeumorphicTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _listeningFocusNode?.removeListener(_handleFocusChanged);
      _listeningFocusNode = _focusNode..addListener(_handleFocusChanged);
    }
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _listeningFocusNode?.removeListener(_handleFocusChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = widget.semanticLabel ?? widget.hintText;
    final focusNode = _focusNode;
    final isFocused = focusNode.hasFocus;

    final resolvedBorderRadius =
        theme.inputBorderRadius ?? BorderRadius.circular(Radii.m);
    final resolvedBackgroundColor =
        theme.inputBackgroundColor ?? theme.colorScheme.surface;
    final resolvedBorder =
        theme.inputBorder ??
        Border.all(
          color: isFocused
              ? (theme.inputFocusedBorderColor ?? theme.colorScheme.primary)
              : theme.colorScheme.outlineVariant,
          width: 1,
        );

    return Semantics(
      textField: true,
      label: label,
      hint: widget.hintText,
      obscured: widget.obscureText,
      child: Container(
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: resolvedBorderRadius,
          border: resolvedBorder,
          boxShadow: theme.styleCardShadows,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextField(
          controller: widget.controller,
          focusNode: focusNode,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.m,
            ),
          ),
        ),
      ),
    );
  }
}
