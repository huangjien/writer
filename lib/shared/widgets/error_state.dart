import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';
import 'feedback/error_animation.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.showRetry = true,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon == null
                  ? ErrorAnimation(size: 64, color: theme.colorScheme.error)
                  : Icon(icon, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: Spacing.l),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (showRetry && onRetry != null) ...[
                const SizedBox(height: Spacing.xl),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
