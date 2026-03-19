import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';

class ZenModeBar extends StatelessWidget {
  const ZenModeBar({
    super.key,
    required this.onExit,
    required this.onSave,
    required this.preview,
    required this.onTogglePreview,
  });

  final VoidCallback onExit;
  final VoidCallback onSave;
  final bool preview;
  final VoidCallback onTogglePreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          child: Row(
            children: [
              Text(
                l10n.previewMode,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: preview ? l10n.exitPreview : l10n.preview,
                onPressed: onTogglePreview,
                icon: Icon(preview ? Icons.edit : Icons.visibility),
              ),
              IconButton(
                tooltip: l10n.save,
                onPressed: onSave,
                icon: const Icon(Icons.save),
              ),
              IconButton(
                tooltip: l10n.exitZenMode,
                onPressed: onExit,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
