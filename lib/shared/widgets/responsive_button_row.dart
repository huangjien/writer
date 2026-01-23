import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class ResponsiveButtonRow extends StatelessWidget {
  const ResponsiveButtonRow({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.end,
    this.spacing = Spacing.s,
    this.runSpacing = Spacing.s,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  final List<Widget> children;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: alignment,
    spacing: spacing,
    runSpacing: runSpacing,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}
