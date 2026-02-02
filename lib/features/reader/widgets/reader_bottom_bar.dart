import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/app_buttons.dart';

class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    super.key,
    required this.canEdit,
    required this.editMode,
    required this.speaking,
    required this.iconSize,
    required this.spacing,
    required this.showPercent,
    required this.showTtsControls,
    required this.scrollProgress,
    required this.boldEnabled,
    required this.onEditToggle,
    required this.onPrev,
    required this.onNext,
    required this.onToggleBold,
    required this.onPlayStop,
    required this.onOpenTtsSettings,
    required this.reduceMotion,
    this.editActions,
    this.onBetaEvaluate,
    this.showBeta = false,
    this.betaLoading = false,
  });

  final bool canEdit;
  final bool editMode;
  final bool speaking;
  final double iconSize;
  final double spacing;
  final bool showPercent;
  final bool showTtsControls;
  final double scrollProgress;
  final bool boldEnabled;
  final VoidCallback onEditToggle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggleBold;
  final VoidCallback onPlayStop;
  final VoidCallback onOpenTtsSettings;
  final bool reduceMotion;
  final Widget? editActions;
  final VoidCallback? onBetaEvaluate;
  final bool showBeta;
  final bool betaLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: Row(
        children: [
          if (canEdit) ...[
            AppButtons.icon(
              iconData: editMode ? Icons.close : Icons.edit,
              tooltip: editMode ? l10n.exitEditMode : l10n.enterEditMode,
              onPressed: onEditToggle,
            ),
            SizedBox(width: spacing),
          ],
          AppButtons.icon(
            iconData: Icons.skip_previous,
            tooltip: l10n.previousChapter,
            onPressed: onPrev,
          ),
          SizedBox(width: spacing),
          AppButtons.icon(
            iconData: Icons.skip_next,
            tooltip: l10n.nextChapter,
            onPressed: onNext,
          ),
          if (!editMode) ...[
            SizedBox(width: spacing),
            AppButtons.icon(
              iconData: Icons.format_bold,
              tooltip: l10n.boldShortcut,
              color: boldEnabled ? theme.colorScheme.primary : null,
              onPressed: onToggleBold,
            ),
          ],
          if (editMode) ...[
            Expanded(child: Container()),
            if (editActions != null) editActions!,
            Expanded(child: Container()),
          ] else ...[
            Expanded(child: Container()),
            AnimatedSwitcher(
              key: const ValueKey('reader_bar_play_switcher'),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              switchInCurve: reduceMotion ? Curves.linear : Curves.easeOut,
              switchOutCurve: reduceMotion ? Curves.linear : Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey('btn_${speaking ? 'stop' : 'play'}'),
                child: AppButtons.icon(
                  iconData: speaking ? Icons.stop : Icons.play_arrow,
                  tooltip: speaking ? l10n.stopTTS : l10n.speak,
                  onPressed: onPlayStop,
                ),
              ),
            ),
            Expanded(child: Container()),
          ],
          if (!editMode && showBeta && onBetaEvaluate != null) ...[
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              switchInCurve: reduceMotion ? Curves.linear : Curves.easeOut,
              switchOutCurve: reduceMotion ? Curves.linear : Curves.easeIn,
              child: betaLoading
                  ? SizedBox(
                      key: const ValueKey('beta_spinner'),
                      height: iconSize,
                      width: iconSize,
                      child: const CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Semantics(
                      button: true,
                      label: l10n.betaEvaluate,
                      child: Tooltip(
                        message: l10n.betaEvaluate,
                        child: KeyedSubtree(
                          key: const ValueKey('beta_button'),
                          child: AppButtons.icon(
                            iconData: Icons.science,
                            onPressed: onBetaEvaluate!,
                            tooltip: l10n.betaEvaluate,
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(width: spacing),
          ],
          if (!editMode)
            IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    child: Container(
                      key: const ValueKey('reader_bottom_progress_bar'),
                      height: 14,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(Radii.s),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: scrollProgress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(Radii.s - 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showPercent) ...[
                    SizedBox(width: spacing),
                    Text('${(scrollProgress * 100).round()}%'),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
