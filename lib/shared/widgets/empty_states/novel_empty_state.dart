import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../empty_state.dart';
import '../glass_card.dart';

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
      illustration: GlassCard(
        borderRadius: BorderRadius.circular(999),
        padding: const EdgeInsets.all(Spacing.xl),
        child: Icon(
          Icons.menu_book_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
