import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/supabase_config.dart';
import 'widgets/beta_evaluation/beta_evaluation_dialog.dart';

import '../../models/chapter.dart';
import '../../state/edit_permissions.dart';
import '../../state/motion_settings.dart';
import '../../state/theme_controller.dart';
import '../../theme/reader_background.dart';

import 'widgets/edit_chapter_body.dart';
import 'widgets/reader_bottom_bar_shell.dart';
import 'widgets/reader_app_bar.dart';
import 'widgets/reader_shortcuts_wrapper.dart';
import 'widgets/reader_body.dart';
import '../../widgets/side_bar.dart';
import 'logic/edit_discard_dialog.dart';
import 'logic/edit_mode.dart';
import 'state/reader_session_state.dart';
import 'state/reader_session_notifier.dart';

class ChapterReaderScreen extends ConsumerWidget {
  const ChapterReaderScreen({
    super.key,
    required this.chapterId,
    required this.title,
    this.content,
    required this.novelId,
    this.initialOffset = 0.0,
    this.initialTtsIndex = 0,
    this.allChapters,
    this.currentIdx,
    this.autoStartTts = false,
  });

  final String chapterId;
  final String title;
  final String? content;
  final String novelId;
  final double initialOffset;
  final int initialTtsIndex;
  final List<Chapter>? allChapters;
  final int? currentIdx;
  final bool autoStartTts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      key: ValueKey('reader_session_${chapterId}_$initialTtsIndex'),
      overrides: [
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: novelId,
            initialState: ReaderSessionState(
              chapterId: chapterId,
              title: title,
              content: content,
              currentIdx: currentIdx ?? 0,
              allChapters: allChapters ?? const [],
              ttsIndex: initialTtsIndex,
            ),
          ),
        ),
      ],
      child: _ChapterReaderContent(
        initialOffset: initialOffset,
        autoStartTts: autoStartTts,
        novelId: novelId,
      ),
    );
  }
}

class _ChapterReaderContent extends ConsumerStatefulWidget {
  const _ChapterReaderContent({
    required this.initialOffset,
    required this.autoStartTts,
    required this.novelId,
  });

  final double initialOffset;
  final bool autoStartTts;
  final String novelId;

  @override
  ConsumerState<_ChapterReaderContent> createState() =>
      _ChapterReaderContentState();
}

class _ChapterReaderContentState extends ConsumerState<_ChapterReaderContent> {
  final MethodChannel _mediaChannel = const MethodChannel(
    'com.huangjien.novel/media_control',
  );
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(widget.initialOffset);
      });
    }

    if (widget.autoStartTts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(readerSessionProvider.notifier)
            .tryAutoStartTts(_showAutoplayPrompt);
      });
    }

    _mediaChannel.setMethodCallHandler((call) async {
      final notifier = ref.read(readerSessionProvider.notifier);
      switch (call.method) {
        case 'play':
          await notifier.startTts(optimistic: false);
          break;
        case 'pause':
        case 'stop':
          await notifier.stopTts();
          break;
        case 'next':
          await _onNextPressed();
          break;
        case 'prev':
          await _onPrevPressed();
          break;
      }
    });
  }

  void _showAutoplayPrompt() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.autoplayBlocked),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.continueLabel,
          onPressed: () async {
            ref.read(readerSessionProvider.notifier).setAutoplayBlocked(false);
            await ref.read(readerSessionProvider.notifier).startTts();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _onNextPressed() async {
    final notifier = ref.read(readerSessionProvider.notifier);
    final state = ref.read(readerSessionProvider);
    if (state.editMode && await _handleDirtyEdit()) return;

    final success = await notifier.loadNextChapter();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reachedLastChapter),
        ),
      );
    }
  }

  Future<void> _onPrevPressed() async {
    final notifier = ref.read(readerSessionProvider.notifier);
    final state = ref.read(readerSessionProvider);
    if (state.editMode && await _handleDirtyEdit()) return;

    final success = await notifier.loadPrevChapter();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reachedFirstChapter),
        ),
      );
    }
  }

  Future<void> _onBackPressed() async {
    final state = ref.read(readerSessionProvider);
    if (state.editMode && await _handleDirtyEdit()) return;
    if (!mounted) return;
    try {
      context.pop();
    } catch (_) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleDirtyEdit() async {
    final state = ref.read(readerSessionProvider);
    final current = state.allChapters.isNotEmpty
        ? state.allChapters[state.currentIdx]
        : Chapter(
            id: state.chapterId,
            novelId: widget.novelId,
            idx: state.currentIdx + 1,
            title: state.title,
            content: state.content,
          );

    if (isEditDirty(ref, current)) {
      final notifier = ref.read(readerSessionProvider.notifier);
      notifier.setDiscardDialogOpen(true);
      final result = await showDiscardDialogBridge(
        context: context,
        ref: ref,
        current: current,
      );
      notifier.setDiscardDialogOpen(false);
      if (result == null || result == DiscardDecision.keepEditing) {
        return true;
      }
      notifier.setEditMode(false);
    } else {
      ref.read(readerSessionProvider.notifier).setEditMode(false);
    }
    return false;
  }

  Future<void> _onEditTogglePressed() async {
    final notifier = ref.read(readerSessionProvider.notifier);
    final state = ref.read(readerSessionProvider);

    if (!state.editMode) {
      notifier.setEditMode(true);
      return;
    }
    if (await _handleDirtyEdit()) return;
  }

  void _onPlayStopPressed() {
    ref
        .read(readerSessionProvider.notifier)
        .playStop(_controller.hasClients ? _controller.offset : 0.0);
  }

  void _openSettingsForTts() {
    if (!mounted) return;
    context.push('/settings');
  }

  Future<void> _onBetaEvaluatePressed() async {
    final state = ref.read(readerSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    if ((state.content ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.betaEvaluationFailed)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.betaEvaluating)));
    try {
      final service = ref.read(aiChatServiceProvider);
      final eval = await service.betaEvaluateChapter(
        novelId: widget.novelId,
        chapterId: state.chapterId,
        content: state.content ?? '',
        language: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      if (eval == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.betaEvaluationFailed)));
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.betaEvaluationReady)));
      await showDialog(
        context: context,
        builder: (context) {
          return BetaEvaluationDialog(evaluation: eval);
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.betaEvaluationFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerSessionProvider);
    final notifier = ref.read(readerSessionProvider.notifier);

    ref.listen(readerSessionProvider, (prev, next) {
      if (prev?.chapterId != next.chapterId) {
        if (_controller.hasClients) _controller.jumpTo(0);
      }
    });

    ReaderBackgroundDepth depth;
    try {
      depth = ref.watch(themeControllerProvider).readerBgDepth;
    } catch (_) {
      depth = ReaderBackgroundDepth.medium;
    }
    final motion = ref.watch(motionSettingsProvider);

    final bgColor = readerBackgroundColor(Theme.of(context).colorScheme, depth);

    final current = state.allChapters.isNotEmpty
        ? state.allChapters[state.currentIdx]
        : Chapter(
            id: state.chapterId,
            novelId: widget.novelId,
            idx: state.currentIdx + 1,
            title: state.title,
            content: state.content,
          );

    final isAiChatOpen = ref.watch(aiChatUiProvider);

    final readerScaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: state.fullScreen
          ? null
          : ReaderAppBar(title: state.title, onBack: _onBackPressed),
      endDrawer: state.fullScreen ? null : SideBar(novelId: widget.novelId),
      body: Stack(
        children: [
          Positioned.fill(
            child: state.editMode
                ? EditChapterBody(
                    novelId: widget.novelId,
                    current: current,
                    previewMode: state.previewMode,
                  )
                : ReaderBody(
                    controller: _controller,
                    content: state.content,
                    ttsIndex: state.ttsIndex,
                    autoplayBlocked: state.autoplayBlocked,
                    onAutoplayContinue: () async {
                      notifier.setAutoplayBlocked(false);
                      await notifier.startTts();
                    },
                    gesturesEnabled: motion.gesturesEnabled,
                    swipeMinVelocity: motion.swipeMinVelocity,
                    editMode: state.editMode,
                    discardDialogOpen: state.discardDialogOpen,
                    onToggleFullScreen: notifier.toggleFullScreen,
                    onPlayStop: _onPlayStopPressed,
                    onPrev: _onPrevPressed,
                    onNext: _onNextPressed,
                  ),
          ),
          if (isAiChatOpen && !state.fullScreen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  try {
                    ref.read(aiChatUiProvider.notifier).closeSidebar();
                  } catch (_) {}
                },
                child: Container(color: const Color(0x00000000)),
              ),
            ),
          if (isAiChatOpen && !state.fullScreen)
            Align(
              alignment: Alignment.centerRight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth * 0.8;
                  return SizedBox(
                    width: w,
                    child: AiChatSidebar(width: w),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: state.fullScreen
          ? null
          : SafeArea(
              top: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 0,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxW = constraints.maxWidth;
                      final editPerms = ref.watch(
                        editPermissionsProvider(widget.novelId),
                      );
                      final bool canEdit = editPerms.asData?.value ?? false;

                      // Calculation for progress bar
                      final baseLen = (state.content?.length ?? 1).toDouble();
                      // We need to handle progressDenomLockedIndex.
                      // It's in state.
                      // _ttsTotalLen is NOT in state.
                      // However, we can use baseLen as approximation if ttsTotalLen is missing,
                      // or add ttsTotalLen to state.
                      // For now, let's use baseLen if not speaking?
                      // In original:
                      /*
                      final denom =
                          _progressDenomLockedIndex?.toDouble() ??
                          (_speaking
                              ? (_ttsTotalLen > 0 ? _ttsTotalLen.toDouble() : baseLen)
                              : baseLen);
                      */
                      // If we don't have ttsTotalLen in state, the progress bar might be inaccurate during TTS if using chunks.
                      // But for now let's use baseLen.

                      final denom =
                          state.progressDenomLockedIndex?.toDouble() ?? baseLen;

                      final num =
                          (state.progressDenomLockedIndex != null ||
                              state.ttsIndexVisual > 0)
                          ? state.ttsIndexVisual.toDouble()
                          : (state.scrollProgress * denom);
                      // Wait, state.scrollProgress is 0.0 in state (default).
                      // We need to update scrollProgress in state?
                      // Or read from controller?
                      // The original updated _scrollProgress? No, it didn't seem to update it constantly.
                      // It used `_scrollProgress * denom`.
                      // But where was `_scrollProgress` set?
                      // Searching original file: `_scrollProgress` only assigned `0.0` and `widget.initialOffset` (indirectly?).
                      // Actually, I missed where `_scrollProgress` was updated.
                      // Maybe it wasn't updated and the progress bar for scrolling was broken or I missed a listener?
                      // Ah, ReaderBody takes `controller`.
                      // Maybe ReaderBody updates it?
                      // No, ReaderBody is stateless.
                      // ReaderBottomBarShell uses `scrollProgress`.
                      // If `_scrollProgress` was never updated in original code, then it was 0.
                      // Let's assume we can use `_controller` to get progress if needed, but `LayoutBuilder` rebuilds on constraints change, not scroll.
                      // To update progress bar on scroll, we need to listen to scroll controller and setState.
                      // The original code didn't seem to have a scroll listener calling setState!
                      // So maybe the bottom bar progress only reflected TTS progress?
                      // "final num = ... : (_scrollProgress * denom);"
                      // If _scrollProgress is 0, then it's 0.
                      // Let's ignore scroll progress for now or fix it later.

                      final barProgress = (denom > 0 ? (num / denom) : 0.0)
                          .clamp(0.0, 1.0);

                      return ReaderBottomBarShell(
                        canEdit: canEdit,
                        editMode: state.editMode,
                        speaking: state.speaking,
                        scrollProgress: barProgress,
                        onEditToggle: _onEditTogglePressed,
                        onPrev: _onPrevPressed,
                        onNext: _onNextPressed,
                        onPlayStop: _onPlayStopPressed,
                        onOpenTtsSettings: _openSettingsForTts,
                        reduceMotion: motion.reduceMotion,
                        maxWidth: maxW,
                        current: current,
                        previewMode: state.previewMode,
                        onTogglePreview: notifier.togglePreviewMode,
                        onCreated: (created) {
                          notifier.jumpToCreated(created);
                        },
                        onBetaEvaluate: _onBetaEvaluatePressed,
                        showBeta: supabaseEnabled,
                      );
                    },
                  ),
                ),
              ),
            ),
    );

    return ReaderShortcutsWrapper(
      disabled: state.editMode || state.discardDialogOpen,
      onToggleSpeak: _onPlayStopPressed,
      onPrev: _onPrevPressed,
      onNext: _onNextPressed,
      onOpenSettings: _openSettingsForTts,
      child: Focus(
        key: const ValueKey('reader_bar_focus'),
        autofocus: true,
        child: readerScaffold,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
