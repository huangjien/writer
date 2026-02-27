import 'package:flutter/material.dart';
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
                'Zen mode',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: preview ? 'Exit preview' : 'Preview',
                onPressed: onTogglePreview,
                icon: Icon(preview ? Icons.edit : Icons.visibility),
              ),
              IconButton(
                tooltip: 'Save',
                onPressed: onSave,
                icon: const Icon(Icons.save),
              ),
              IconButton(
                tooltip: 'Exit Zen mode',
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
