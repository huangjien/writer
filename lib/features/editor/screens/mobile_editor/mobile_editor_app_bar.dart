import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';

class MobileEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MobileEditorAppBar({
    super.key,
    required this.l10n,
    required this.hasUnsavedChanges,
    required this.onOpenMenu,
  });

  final AppLocalizations l10n;
  final bool hasUnsavedChanges;
  final VoidCallback onOpenMenu;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.edit, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: Spacing.s),
          Text(
            'Editor',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(left: Spacing.s),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s,
                vertical: Spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(Radii.s),
              ),
              child: Text(
                'Unsaved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
          onPressed: onOpenMenu,
        ),
      ],
    );
  }
}
