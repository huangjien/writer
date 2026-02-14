import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';

@immutable
class EditorScreenState {
  final bool isSaving;
  final bool hasUnsavedChanges;
  final bool isLoading;
  final bool isDiscarding;
  final bool preview;
  final bool zenMode;
  final Chapter? chapter;
  final int streakDays;
  final MobileNavTab currentTab;

  const EditorScreenState({
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.isLoading = true,
    this.isDiscarding = false,
    this.preview = false,
    this.zenMode = false,
    this.chapter,
    this.streakDays = 0,
    this.currentTab = MobileNavTab.write,
  });

  EditorScreenState copyWith({
    bool? isSaving,
    bool? hasUnsavedChanges,
    bool? isLoading,
    bool? isDiscarding,
    bool? preview,
    bool? zenMode,
    Chapter? chapter,
    int? streakDays,
    MobileNavTab? currentTab,
  }) {
    return EditorScreenState(
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isLoading: isLoading ?? this.isLoading,
      isDiscarding: isDiscarding ?? this.isDiscarding,
      preview: preview ?? this.preview,
      zenMode: zenMode ?? this.zenMode,
      chapter: chapter ?? this.chapter,
      streakDays: streakDays ?? this.streakDays,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class EditorScreenNotifier extends Notifier<EditorScreenState> {
  @override
  EditorScreenState build() => const EditorScreenState();

  void setSaving(bool value) {
    state = state.copyWith(isSaving: value);
  }

  void setUnsavedChanges(bool value) {
    state = state.copyWith(hasUnsavedChanges: value);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setDiscarding(bool value) {
    state = state.copyWith(isDiscarding: value);
  }

  void togglePreview() {
    state = state.copyWith(preview: !state.preview);
  }

  void setZenMode(bool value) {
    state = state.copyWith(zenMode: value);
  }

  void setChapter(Chapter? value) {
    state = state.copyWith(chapter: value);
  }

  void setStreakDays(int value) {
    state = state.copyWith(streakDays: value);
  }

  void setCurrentTab(MobileNavTab value) {
    state = state.copyWith(currentTab: value);
  }
}

final editorScreenProvider =
    NotifierProvider<EditorScreenNotifier, EditorScreenState>(
      EditorScreenNotifier.new,
    );
