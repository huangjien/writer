import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import 'micro_interactions.dart';
import 'particles/wave_effect.dart';

class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({
    super.key,
    required this.preview,
    required this.onTogglePreview,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onHeading,
    required this.onQuote,
    required this.onCode,
    required this.onBullet,
    required this.onNumbered,
    required this.onLink,
  });

  final bool preview;
  final VoidCallback onTogglePreview;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onCode;
  final VoidCallback onBullet;
  final VoidCallback onNumbered;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolButton(
              icon: preview ? Icons.edit : Icons.visibility,
              label: preview ? 'Edit' : 'Preview',
              isActive: preview,
              onPressed: onTogglePreview,
            ),
            const SizedBox(width: Spacing.s),
            _ToolButton(
              icon: Icons.format_bold,
              label: 'B',
              isActive: false,
              onPressed: onBold,
            ),
            _ToolButton(
              icon: Icons.format_italic,
              label: 'I',
              isActive: false,
              onPressed: onItalic,
            ),
            _ToolButton(
              icon: Icons.format_underlined,
              label: 'U',
              isActive: false,
              onPressed: onUnderline,
            ),
            const SizedBox(width: Spacing.s),
            _ToolButton(
              icon: Icons.title,
              label: 'H',
              isActive: false,
              onPressed: onHeading,
            ),
            _ToolButton(
              icon: Icons.format_quote,
              label: '❝',
              isActive: false,
              onPressed: onQuote,
            ),
            _ToolButton(
              icon: Icons.code,
              label: '</>',
              isActive: false,
              onPressed: onCode,
            ),
            const SizedBox(width: Spacing.s),
            _ToolButton(
              icon: Icons.format_list_bulleted,
              label: '•',
              isActive: false,
              onPressed: onBullet,
            ),
            _ToolButton(
              icon: Icons.format_list_numbered,
              label: '1.',
              isActive: false,
              onPressed: onNumbered,
            ),
            const SizedBox(width: Spacing.s),
            _ToolButton(
              icon: Icons.link,
              label: 'Link',
              isActive: false,
              onPressed: onLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WaveTap(
      borderRadius: BorderRadius.circular(Radii.m),
      onLongPress: () => HapticFeedback.mediumImpact(),
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: PressScale(
        child: Container(
          width: MobileSpacing.touchTargetMin,
          height: MobileSpacing.touchTargetMin,
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(Radii.m),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
