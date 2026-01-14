import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import '../../theme/design_tokens.dart';
import 'feedback/error_animation.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon == Icons.error_outline
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
            if (onRetry != null) ...[
              const SizedBox(height: Spacing.xl),
              RetryPulse(
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.retry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
