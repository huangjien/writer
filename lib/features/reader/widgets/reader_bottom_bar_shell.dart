import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../theme/neumorphic_styles.dart';
import '../../../models/chapter.dart';
import '../widgets/reader_edit_actions.dart';
import 'reader_bottom_bar.dart';

class ReaderBottomBarShell extends StatelessWidget {
  const ReaderBottomBarShell({
    super.key,
    required this.canEdit,
    required this.editMode,
    required this.speaking,
    required this.scrollProgress,
    required this.boldEnabled,
    required this.onEditToggle,
    required this.onPrev,
    required this.onNext,
    required this.onToggleBold,
    required this.onPlayStop,
    required this.onOpenTtsSettings,
    required this.reduceMotion,
    required this.maxWidth,
    this.current,
    required this.previewMode,
    required this.onTogglePreview,
    required this.onCreated,
    this.onBetaEvaluate,
    this.showBeta = false,
    this.betaLoading = false,
  });

  final bool canEdit;
  final bool editMode;
  final bool speaking;
  final double scrollProgress;
  final bool boldEnabled;
  final VoidCallback onEditToggle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggleBold;
  final VoidCallback onPlayStop;
  final VoidCallback onOpenTtsSettings;
  final bool reduceMotion;
  final double maxWidth;
  final Chapter? current;
  final bool previewMode;
  final VoidCallback onTogglePreview;
  final void Function(Chapter created) onCreated;
  final VoidCallback? onBetaEvaluate;
  final bool showBeta;
  final bool betaLoading;

  @override
  Widget build(BuildContext context) {
    const double compactWidth = 480.0;
    const double cozyWidth = 720.0;
    final bool isCompact = maxWidth < compactWidth;
    final bool isRegular = maxWidth >= cozyWidth;
    final double spacing = isRegular
        ? Spacing.l
        : (isCompact ? Spacing.s : Spacing.m);
    const double iconSize = 24.0;
    final bool showPercent = !isCompact;
    final bool isWideForEdit = maxWidth >= 900.0;

    Widget? editActions;
    if (editMode && current != null) {
      editActions = ReaderEditActions(
        current: current!,
        previewMode: previewMode,
        onTogglePreview: onTogglePreview,
        onCreated: onCreated,
        isCompact: isCompact,
        isWideForEdit: isWideForEdit,
        spacing: spacing,
        iconSize: iconSize,
      );
    }

    final bottomBar = ReaderBottomBar(
      key: const ValueKey('reader_bottom_bar'),
      canEdit: canEdit,
      editMode: editMode,
      speaking: speaking,
      iconSize: iconSize,
      spacing: spacing,
      showPercent: showPercent,
      showTtsControls: !isCompact,
      scrollProgress: scrollProgress,
      boldEnabled: boldEnabled,
      onEditToggle: onEditToggle,
      onPrev: onPrev,
      onNext: onNext,
      onToggleBold: onToggleBold,
      onPlayStop: onPlayStop,
      onOpenTtsSettings: onOpenTtsSettings,
      reduceMotion: reduceMotion,
      editActions: editActions,
      onBetaEvaluate: onBetaEvaluate,
      showBeta: showBeta,
      betaLoading: betaLoading,
    );

    return AnimatedContainer(
      duration: Duration(milliseconds: reduceMotion ? 0 : 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.all(isCompact ? Spacing.m : Spacing.l),
      decoration: NeumorphicStyles.decoration(
        isDark: Theme.of(context).brightness == Brightness.dark,
        borderRadius: BorderRadius.circular(24.0),
        depth: 10, // Subtle depth for floating bar
      ),
      padding: EdgeInsets.zero,
      child: bottomBar,
    );
  }
}
