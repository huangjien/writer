import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../empty_state.dart';
import '../theme_aware_card.dart';

class OnboardingEmptyState extends StatelessWidget {
  const OnboardingEmptyState({
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
      icon: Icons.auto_awesome_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      illustration: ThemeAwareCard(
        borderRadius: BorderRadius.circular(999),
        semanticType: CardSemanticType.default_,
        padding: const EdgeInsets.all(Spacing.xl),
        child: Icon(
          Icons.auto_awesome_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
