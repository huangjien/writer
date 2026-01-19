import 'package:flutter/foundation.dart';
import '../../../models/chapter.dart';
import '../../../common/errors/failures.dart';

@immutable
class ReaderSessionState {
  final String chapterId;
  final String title;
  final String? content;
  final int currentIdx;
  final int ttsIndex;
  final int ttsIndexVisual;
  final bool speaking;
  final bool autoplayBlocked;
  final double scrollProgress;
  final bool boldEnabled;
  final bool editMode;
  final bool discardDialogOpen;
  final bool previewMode;
  final bool fullScreen;
  final int? progressDenomLockedIndex;
  final List<Chapter> allChapters;
  final AppFailure? failure;

  const ReaderSessionState({
    required this.chapterId,
    required this.title,
    this.content,
    required this.currentIdx,
    this.ttsIndex = 0,
    this.ttsIndexVisual = 0,
    this.speaking = false,
    this.autoplayBlocked = false,
    this.scrollProgress = 0.0,
    this.boldEnabled = false,
    this.editMode = false,
    this.discardDialogOpen = false,
    this.previewMode = false,
    this.fullScreen = false,
    this.progressDenomLockedIndex,
    this.allChapters = const [],
    this.failure,
  });

  ReaderSessionState copyWith({
    String? chapterId,
    String? title,
    String? content,
    int? currentIdx,
    int? ttsIndex,
    int? ttsIndexVisual,
    bool? speaking,
    bool? autoplayBlocked,
    double? scrollProgress,
    bool? boldEnabled,
    bool? editMode,
    bool? discardDialogOpen,
    bool? previewMode,
    bool? fullScreen,
    int? progressDenomLockedIndex,
    List<Chapter>? allChapters,
    AppFailure? failure,
    bool clearFailure = false, // Helper to clear failure
  }) {
    return ReaderSessionState(
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      content: content ?? this.content,
      currentIdx: currentIdx ?? this.currentIdx,
      ttsIndex: ttsIndex ?? this.ttsIndex,
      ttsIndexVisual: ttsIndexVisual ?? this.ttsIndexVisual,
      speaking: speaking ?? this.speaking,
      autoplayBlocked: autoplayBlocked ?? this.autoplayBlocked,
      scrollProgress: scrollProgress ?? this.scrollProgress,
      boldEnabled: boldEnabled ?? this.boldEnabled,
      editMode: editMode ?? this.editMode,
      discardDialogOpen: discardDialogOpen ?? this.discardDialogOpen,
      previewMode: previewMode ?? this.previewMode,
      fullScreen: fullScreen ?? this.fullScreen,
      progressDenomLockedIndex:
          progressDenomLockedIndex ?? this.progressDenomLockedIndex,
      allChapters: allChapters ?? this.allChapters,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
