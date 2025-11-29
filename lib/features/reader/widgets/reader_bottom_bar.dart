import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    super.key,
    required this.canEdit,
    required this.editMode,
    required this.speaking,
    required this.iconSize,
    required this.spacing,
    required this.showPercent,
    required this.scrollProgress,
    required this.onEditToggle,
    required this.onPrev,
    required this.onNext,
    required this.onPlayStop,
    required this.onOpenTtsSettings,
    required this.reduceMotion,
    this.editActions,
  });

  final bool canEdit;
  final bool editMode;
  final bool speaking;
  final double iconSize;
  final double spacing;
  final bool showPercent;
  final double scrollProgress;
  final VoidCallback onEditToggle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlayStop;
  final VoidCallback onOpenTtsSettings;
  final bool reduceMotion;
  final Widget? editActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      child: Row(
        children: [
          if (canEdit) ...[
            Semantics(
              button: true,
              label: editMode ? l10n.exitEditMode : l10n.enterEditMode,
              child: Tooltip(
                message: editMode ? l10n.exitEditMode : l10n.enterEditMode,
                child: IconButton(
                  icon: Icon(editMode ? Icons.close : Icons.edit),
                  iconSize: iconSize,
                  onPressed: onEditToggle,
                ),
              ),
            ),
            SizedBox(width: spacing),
          ],
          Semantics(
            button: true,
            label: l10n.previousChapter,
            child: Tooltip(
              message: l10n.previousChapter,
              child: IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: iconSize,
                onPressed: onPrev,
              ),
            ),
          ),
          SizedBox(width: spacing),
          Semantics(
            button: true,
            label: l10n.nextChapter,
            child: Tooltip(
              message: l10n.nextChapter,
              child: IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: iconSize,
                onPressed: onNext,
              ),
            ),
          ),
          const Spacer(),
          if (!editMode) ...[
            Semantics(
              button: true,
              label: speaking ? l10n.stopTTS : l10n.speak,
              child: Tooltip(
                message: speaking ? l10n.stopTTS : l10n.speak,
                child: AnimatedSwitcher(
                  key: const ValueKey('reader_bar_play_switcher'),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  switchInCurve: reduceMotion ? Curves.linear : Curves.easeOut,
                  switchOutCurve: reduceMotion ? Curves.linear : Curves.easeIn,
                  child: IconButton(
                    key: ValueKey('btn_${speaking ? 'stop' : 'play'}'),
                    icon: Icon(speaking ? Icons.stop : Icons.play_arrow),
                    iconSize: iconSize,
                    onPressed: onPlayStop,
                  ),
                ),
              ),
            ),
          ] else ...[
            if (editActions != null) editActions!,
          ],
          const Spacer(),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.s),
                    child: LinearProgressIndicator(value: scrollProgress),
                  ),
                ),
                if (showPercent) ...[
                  SizedBox(width: spacing),
                  Text('${(scrollProgress * 100).round()}%'),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing),
          if (!editMode) ...[
            Semantics(
              button: true,
              label: l10n.ttsSpeechRate,
              child: Tooltip(
                message: l10n.ttsSpeechRate,
                child: IconButton(
                  icon: const Icon(Icons.speed),
                  iconSize: iconSize,
                  onPressed: onOpenTtsSettings,
                ),
              ),
            ),
            SizedBox(width: spacing),
            Semantics(
              button: true,
              label: l10n.ttsVoice,
              child: Tooltip(
                message: l10n.ttsVoice,
                child: IconButton(
                  icon: const Icon(Icons.record_voice_over),
                  iconSize: iconSize,
                  onPressed: onOpenTtsSettings,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
