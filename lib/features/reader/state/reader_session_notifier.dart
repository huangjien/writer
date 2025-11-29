import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../repositories/chapter_repository.dart';
import '../../../state/app_settings.dart';
import '../../../state/performance_settings.dart';
import '../../../state/providers.dart';
import '../../../state/tts_settings.dart';
import '../logic/reader_navigation.dart';
import '../logic/reader_playback_controller.dart';
import '../logic/tts_driver.dart';
import '../logic/progress_saver.dart';
import 'reader_session_state.dart';

final readerSessionProvider =
    StateNotifierProvider.autoDispose<
      ReaderSessionNotifier,
      ReaderSessionState
    >((ref) {
      throw UnimplementedError('Must be overridden');
    });

class ReaderSessionNotifier extends StateNotifier<ReaderSessionState> {
  final Ref ref;
  final String novelId;
  late final ReaderPlaybackController _playback;
  late final TtsDriver _ttsDriver;

  ReaderSessionNotifier({
    required this.ref,
    required this.novelId,
    required ReaderSessionState initialState,
  }) : super(initialState) {
    _ttsDriver = ref.read(ttsDriverProvider);
    _playback = ReaderPlaybackController(_ttsDriver, ref);

    ref.listen<Locale>(appSettingsProvider, (prev, next) {
      _configureTts(next);
    });

    // Initial configuration
    _configureTts(ref.read(appSettingsProvider));

    ref.onDispose(() {
      _playback.dispose();
      _ttsDriver.stop();
    });
  }

  void _configureTts(Locale locale) {
    try {
      final current = ref.read(ttsSettingsProvider);
      final mapped = switch (locale.languageCode) {
        'zh' => 'zh-CN',
        'en' => 'en-US',
        _ => 'en-US',
      };
      _ttsDriver.configure(
        voiceName: current.voiceName,
        voiceLocale: current.voiceLocale,
        defaultLocale: mapped,
      );
    } catch (_) {}
  }

  Future<bool> loadNextChapter() async {
    final res = computeNext(state.allChapters, state.currentIdx, novelId);
    if (res == null) {
      return false;
    }
    state = state.copyWith(
      chapterId: res.chapterId,
      title: res.title,
      content: res.content,
      currentIdx: res.currentIdx,
      ttsIndex: 0,
      ttsIndexVisual: 0,
      speaking: false,
      autoplayBlocked: false,
      progressDenomLockedIndex: null,
    );

    await startTts(optimistic: true);
    await _prefetchNext(res.currentIdx);
    return true;
  }

  Future<bool> loadPrevChapter() async {
    final res = computePrev(state.allChapters, state.currentIdx, novelId);
    if (res == null) {
      return false;
    }
    state = state.copyWith(
      chapterId: res.chapterId,
      title: res.title,
      content: res.content,
      currentIdx: res.currentIdx,
      ttsIndex: 0,
      speaking: false,
    );
    await _playback.stop();
    return true;
  }

  Future<void> _prefetchNext(int fromIdx) async {
    final perf = ref.read(performanceSettingsProvider);
    final supEnabled = ref.read(supabaseEnabledProvider);
    if (!perf.prefetchNextChapter || !supEnabled) return;
    final idx = fromIdx + 1;
    if (idx >= state.allChapters.length) return;
    final next = state.allChapters[idx];
    final repo = ref.read(chapterRepositoryProvider);
    await repo.getChapter(next);
  }

  Future<void> startTts({bool optimistic = true}) async {
    if (optimistic) {
      state = state.copyWith(speaking: true);
    }
    state = state.copyWith(progressDenomLockedIndex: null);

    await _playback.start(
      content: state.content ?? '',
      startIndex: state.ttsIndex,
      onProgress: (i) {
        state = state.copyWith(ttsIndex: i);
      },
      onVisualProgress: (i) {
        state = state.copyWith(ttsIndexVisual: i, speaking: true);
      },
      onStart: () {
        state = state.copyWith(speaking: true);
      },
      onCancel: () {
        state = state.copyWith(speaking: false);
      },
      onError: (msg) {
        state = state.copyWith(speaking: false);
        // Error handling might need a stream or callback
      },
      onComplete: () async {
        state = state.copyWith(
          speaking: false,
          progressDenomLockedIndex: _ttsDriver.index,
        );
        await loadNextChapter();
      },
    );
  }

  Future<void> stopTts() async {
    await _playback.stop();
    state = state.copyWith(speaking: false);
  }

  Future<void> playStop(double scrollOffset) async {
    if (state.speaking) {
      await stopTts();
      await saveProgress(scrollOffset);
    } else {
      state = state.copyWith(autoplayBlocked: false);
      await startTts();
    }
  }

  Future<SaveStatus> saveProgress(double scrollOffset) async {
    return await saveReaderProgress(
      ref: ref,
      novelId: novelId,
      chapterId: state.chapterId,
      scrollOffset: scrollOffset,
      ttsIndex: state.ttsIndex,
    );
  }

  void toggleFullScreen() {
    state = state.copyWith(fullScreen: !state.fullScreen);
  }

  void togglePreviewMode() {
    state = state.copyWith(previewMode: !state.previewMode);
  }

  void setEditMode(bool value) {
    state = state.copyWith(editMode: value, previewMode: false);
  }

  void setDiscardDialogOpen(bool value) {
    state = state.copyWith(discardDialogOpen: value);
  }

  void setAutoplayBlocked(bool value) {
    state = state.copyWith(autoplayBlocked: value);
  }

  void tryAutoStartTts(VoidCallback showPrompt) {
    _playback.tryAutoStart(
      content: state.content ?? '',
      startIndex: state.ttsIndex,
      setAutoplayBlocked: (b) {
        state = state.copyWith(autoplayBlocked: b);
        if (b) showPrompt();
      },
      showAutoplayPrompt: showPrompt,
      onProgress: (i) {
        state = state.copyWith(ttsIndex: i);
      },
      onVisualProgress: (i) {
        state = state.copyWith(ttsIndexVisual: i, speaking: true);
      },
      onStart: () {
        state = state.copyWith(speaking: true);
      },
      onCancel: () {
        state = state.copyWith(speaking: false);
      },
      onError: (msg) {
        state = state.copyWith(speaking: false);
      },
      onComplete: () async {
        state = state.copyWith(
          speaking: false,
          progressDenomLockedIndex: _ttsDriver.index,
        );
        await loadNextChapter();
      },
    );

    final startSnapshot = state.ttsIndex;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      final noRealStart = !state.speaking && state.ttsIndex == startSnapshot;
      if (noRealStart) {
        state = state.copyWith(autoplayBlocked: true);
        showPrompt();
      }
    });
  }

  // Cleanup is registered via ref.onDispose in the constructor.
}
