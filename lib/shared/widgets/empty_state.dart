import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'app_buttons.dart';

/// Empty state component for displaying when no content is available
/// Features:
/// - Customizable icon and illustration
/// - Optional action button
/// - Responsive layout
/// - Dark mode support
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration or icon
              illustration ??
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
              const SizedBox(height: Spacing.xl),
              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Spacing.s),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null ||
                  (actionLabel != null && onAction != null)) ...[
                const SizedBox(height: Spacing.xl),
                action ??
                    AppButtons.primary(
                      onPressed: onAction!,
                      label: actionLabel!,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
