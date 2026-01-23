import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/providers.dart';
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
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/feedback/enhanced_toast.dart';
import '../../common/errors/failures.dart';
import '../../shared/api_exception.dart';

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
  bool _betaLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    if (widget.initialOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(widget.initialOffset);
        ref.read(readerSessionProvider.notifier).loadInitial();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(readerSessionProvider.notifier).loadInitial();
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
          try {
            await _onNextPressed();
          } catch (_) {}
          break;
        case 'prev':
          try {
            await _onPrevPressed();
          } catch (_) {}
          break;
      }
    });
  }

  void _showAutoplayPrompt() {
    if (!mounted) return;
    showEnhancedToast(
      context,
      message: AppLocalizations.of(context)!.autoplayBlocked,
      tone: EnhancedToastTone.info,
      actionLabel: AppLocalizations.of(context)!.continueLabel,
      onAction: () async {
        ref.read(readerSessionProvider.notifier).setAutoplayBlocked(false);
        await ref.read(readerSessionProvider.notifier).startTts();
      },
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _onNextPressed() async {
    final notifier = ref.read(readerSessionProvider.notifier);
    final state = ref.read(readerSessionProvider);
    if (state.editMode && await _handleDirtyEdit()) return;

    try {
      final success = await notifier.loadNextChapter();
      if (!success && mounted) {
        showEnhancedToast(
          context,
          message: AppLocalizations.of(context)!.reachedLastChapter,
          tone: EnhancedToastTone.info,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showEnhancedToast(
        context,
        message: e is AppFailure ? e.message : 'Failed to load chapter',
        tone: EnhancedToastTone.error,
        actionLabel: 'Retry',
        onAction: () => _onNextPressed(),
      );
    }
  }

  Future<void> _onPrevPressed() async {
    final notifier = ref.read(readerSessionProvider.notifier);
    final state = ref.read(readerSessionProvider);
    if (state.editMode && await _handleDirtyEdit()) return;

    try {
      final success = await notifier.loadPrevChapter();
      if (!success && mounted) {
        showEnhancedToast(
          context,
          message: AppLocalizations.of(context)!.reachedFirstChapter,
          tone: EnhancedToastTone.info,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showEnhancedToast(
        context,
        message: e is AppFailure ? e.message : 'Failed to load chapter',
        tone: EnhancedToastTone.error,
        actionLabel: 'Retry',
        onAction: () => _onPrevPressed(),
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
            title: state.title.isNotEmpty ? state.title : null,
            content: state.content?.isNotEmpty == true ? state.content : null,
          );

    final dirty = isEditDirty(ref, current);

    if (dirty) {
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
    // Navigate to mobile editor screen
    if (!mounted) return;
    final state = ref.read(readerSessionProvider);
    context.push('/novel/${widget.novelId}/chapters/${state.chapterId}/edit');
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
    setState(() {
      _betaLoading = true;
    });
    final state = ref.read(readerSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    if ((state.content ?? '').trim().isEmpty) {
      showEnhancedToast(
        context,
        message: l10n.betaEvaluationFailed,
        tone: EnhancedToastTone.error,
      );
      setState(() {
        _betaLoading = false;
      });
      return;
    }
    showEnhancedToast(
      context,
      message: l10n.betaEvaluating,
      tone: EnhancedToastTone.info,
    );
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
        showEnhancedToast(
          context,
          message: l10n.betaEvaluationFailed,
          tone: EnhancedToastTone.error,
        );
        setState(() {
          _betaLoading = false;
        });
        return;
      }
      showEnhancedToast(
        context,
        message: l10n.betaEvaluationReady,
        tone: EnhancedToastTone.success,
      );
      await showDialog(
        context: context,
        builder: (context) {
          return BetaEvaluationDialog(evaluation: eval);
        },
      );
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        setState(() => _betaLoading = false);
        return;
      }
      if (!mounted) return;
      showEnhancedToast(
        context,
        message: l10n.betaEvaluationFailed,
        tone: EnhancedToastTone.error,
      );
    }
    if (mounted) {
      setState(() {
        _betaLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerSessionProvider);
    final notifier = ref.read(readerSessionProvider.notifier);

    // Check for load failures in the session state if applicable
    // But readerSessionProvider.state usually holds current data.
    // If the *load* of the chapter content failed, we might need a way to see that.
    // The current ReaderSessionNotifier seems to handle loading internally.
    // However, if we want to show full screen error, we should check if content is null/empty AND there was an error.
    // Assuming ReaderSessionNotifier or a provider exposing AsyncValue<Chapter> is what we'd watch.
    // In this architecture, it seems ReaderSessionNotifier manages state.
    // If we want to catch load errors, we might need to look at how data is fetched.
    // Since we don't have a direct "AsyncValue" in the build method here (it's hidden in notifier),
    // and we just have 'state', we might need to rely on the repository throwing to the notifier,
    // and the notifier updating state with an error flag?
    // Current ReaderSessionState doesn't seem to have an 'error' field.
    // For now, let's wrap the logic in a safe way or if the state implies error.

    ref.listen(readerSessionProvider, (prev, next) {
      if (prev?.chapterId != next.chapterId) {
        if (_controller.hasClients) {
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (prev?.chapterId != null && mounted) {
          final l10n = AppLocalizations.of(context)!;
          showEnhancedToast(
            context,
            message: l10n.chapterLabel(next.currentIdx + 1),
            tone: EnhancedToastTone.success,
            duration: const Duration(milliseconds: 1500),
          );
        }
      }
      if (next.playbackCompleted && prev?.playbackCompleted != true) {
        if (!mounted) return;
        showEnhancedToast(
          context,
          message: AppLocalizations.of(context)!.reachedLastChapter,
          tone: EnhancedToastTone.info,
          duration: const Duration(seconds: 3),
        );
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
        ? state.allChapters[state.currentIdx].copyWith(
            title: state.title.isNotEmpty
                ? state.title
                : state.allChapters[state.currentIdx].title,
            content: state.content?.isNotEmpty == true
                ? state.content
                : state.allChapters[state.currentIdx].content,
          )
        : Chapter(
            id: state.chapterId,
            novelId: widget.novelId,
            idx: state.currentIdx + 1,
            title: state.title.isNotEmpty ? state.title : null,
            content: state.content?.isNotEmpty == true ? state.content : null,
          );

    final isAiChatOpen = ref.watch(aiChatUiProvider);
    final isSignedIn = ref.watch(isSignedInProvider);

    final readerScaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: state.fullScreen
          ? null
          : ReaderAppBar(title: state.title, onBack: _onBackPressed),
      endDrawer: state.fullScreen ? null : SideBar(novelId: widget.novelId),
      body: Stack(
        children: [
          Positioned.fill(
            child: state.failure != null
                ? ErrorView(
                    message: state.failure!.message,
                    onRetry: () {
                      notifier.loadInitial();
                    },
                  )
                : state.editMode
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
                    boldEnabled: state.boldEnabled,
                    reduceMotion: motion.reduceMotion,
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

                      // Handling Error in Edit Permissions Provider as well
                      if (editPerms.hasError) {
                        // If we can't check permissions, assume false but don't crash
                        // or maybe show a small icon? For now, default false.
                      }

                      final bool canEdit = editPerms.asData?.value ?? false;

                      final baseLen = (state.content?.length ?? 1).toDouble();
                      final denom =
                          state.progressDenomLockedIndex?.toDouble() ?? baseLen;

                      final num =
                          (state.progressDenomLockedIndex != null ||
                              state.ttsIndexVisual > 0)
                          ? state.ttsIndexVisual.toDouble()
                          : (state.scrollProgress * denom);

                      final barProgress = (denom > 0 ? (num / denom) : 0.0)
                          .clamp(0.0, 1.0);

                      return ReaderBottomBarShell(
                        canEdit: canEdit,
                        editMode: state.editMode,
                        speaking: state.speaking,
                        scrollProgress: barProgress,
                        boldEnabled: state.boldEnabled,
                        onEditToggle: _onEditTogglePressed,
                        onPrev: _onPrevPressed,
                        onNext: _onNextPressed,
                        onToggleBold: notifier.toggleBold,
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
                        showBeta: isSignedIn,
                        betaLoading: _betaLoading,
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

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_controller.offset / max).clamp(0.0, 1.0);
    ref.read(readerSessionProvider.notifier).updateScrollProgress(progress);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }
}
