import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'reader_paragraphs.dart';
import 'autoplay_blocked_card.dart';

class ReaderBody extends StatelessWidget {
  const ReaderBody({
    super.key,
    required this.controller,
    required this.content,
    required this.ttsIndex,
    required this.autoplayBlocked,
    required this.onAutoplayContinue,
    required this.gesturesEnabled,
    required this.swipeMinVelocity,
    required this.boldEnabled,
    required this.reduceMotion,
    required this.editMode,
    required this.discardDialogOpen,
    required this.onToggleFullScreen,
    required this.onPlayStop,
    required this.onPrev,
    required this.onNext,
  });

  final ScrollController controller;
  final String? content;
  final int ttsIndex;
  final bool autoplayBlocked;
  final VoidCallback onAutoplayContinue;
  final bool gesturesEnabled;
  final double swipeMinVelocity;
  final bool boldEnabled;
  final bool reduceMotion;
  final bool editMode;
  final bool discardDialogOpen;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onPlayStop;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final listView = ListView(
      controller: controller,
      padding: const EdgeInsets.all(Spacing.l),
      children: [
        if (autoplayBlocked)
          AutoplayBlockedCard(onContinue: onAutoplayContinue),
        const SizedBox(height: Spacing.m),
        ReaderParagraphs(
          text: content ?? '',
          ttsIndex: ttsIndex,
          forceBold: boldEnabled,
          reduceMotion: reduceMotion,
        ),
        const SizedBox(height: Spacing.xl),
        const SizedBox(height: Spacing.m),
      ],
    );
    final platformGestures =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final enableGestures = platformGestures && gesturesEnabled;
    if (!enableGestures) return listView;
    return GestureDetector(
      onTap: () {
        if (editMode || discardDialogOpen) return;
        onToggleFullScreen();
      },
      onDoubleTap: () {
        if (editMode || discardDialogOpen) return;
        onPlayStop();
      },
      onHorizontalDragEnd: (details) {
        if (editMode || discardDialogOpen) return;
        final v = details.primaryVelocity ?? 0.0;
        final min = swipeMinVelocity;
        if (v.abs() < min) return;
        if (v > 0) {
          onPrev();
        } else if (v < 0) {
          onNext();
        }
      },
      child: listView,
    );
  }
}
