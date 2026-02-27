import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/shared/widgets/empty_state.dart';

class NovelEmptyState extends StatelessWidget {
  const NovelEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      illustration: Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: theme.styleCardShadows,
          border: theme.styleCardBorder,
        ),
        child: Icon(
          Icons.menu_book_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
