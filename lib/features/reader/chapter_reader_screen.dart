import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chapter.dart';
import '../../repositories/chapter_repository.dart';
import '../../state/app_settings.dart';
import '../../state/chapter_edit_controller.dart';
import '../../state/edit_permissions.dart';
import '../../state/motion_settings.dart';
import '../../state/performance_settings.dart';
import '../../state/providers.dart';
import '../../state/tts_settings.dart';
import '../../theme/reader_background.dart';
import '../../state/theme_controller.dart';
// removed unused imports after refactor
import 'widgets/edit_chapter_body.dart';
import 'logic/edit_discard_dialog.dart';
import 'logic/tts_driver.dart';
import '../../widgets/side_bar.dart';
import 'widgets/reader_bottom_bar_shell.dart';
import 'widgets/reader_app_bar.dart';
import 'widgets/reader_shortcuts_wrapper.dart';
import 'widgets/reader_body.dart';
import 'logic/progress_saver.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChapterReaderScreen> createState() =>
      _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  final MethodChannel _mediaChannel = const MethodChannel(
    'com.huangjien.novel/media_control',
  );
  final _controller = ScrollController();
  late final TtsDriver _ttsDriver;
  bool _speaking = false;
  int _ttsIndex = 0;
  Timer? _autoStartRetry;
  int _autoStartAttempts = 0;
  static const int _maxAutoStartAttempts = 5;
  bool _autoplayBlocked = false;
  bool _autoplaySnackShown = false;
  double _scrollProgress = 0.0;
  bool _editMode = false;
  bool _discardDialogOpen = false;
  bool _previewMode = false;
  bool _fullScreen = false;

  late String _chapterId;
  late String _title;
  late String? _content;
  late int _currentIdx;
  List<Chapter> _allChapters = const [];

  @override
  void initState() {
    super.initState();
    _ttsDriver = ref.read(ttsDriverProvider);
    _mediaChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'play':
          if (!_speaking) await _startTts();
          break;
        case 'pause':
          await _ttsDriver.pause();
          if (mounted) setState(() => _speaking = false);
          break;
        case 'stop':
          await _ttsDriver.stop();
          if (mounted) setState(() => _speaking = false);
          break;
        case 'next':
          await _onNextPressed();
          break;
        case 'prev':
          await _onPrevPressed();
          break;
      }
    });
    _chapterId = widget.chapterId;
    _title = widget.title;
    _content = widget.content;
    _currentIdx = widget.currentIdx ?? 0;
    _allChapters = widget.allChapters ?? const [];
    _ttsIndex = widget.initialTtsIndex;
    try {
      final current = ref.read(ttsSettingsProvider);
      final appLocale = ref.read(appSettingsProvider);
      final mapped = switch (appLocale.languageCode) {
        'zh' => 'zh-CN',
        'en' => 'en-US',
        _ => 'en-US',
      };
      _ttsDriver.configure(
        voiceName: current.voiceName,
        voiceLocale: current.voiceLocale,
        defaultLocale: mapped,
      );
      ref.listen<Locale>(appSettingsProvider, (prev, next) {
        final curr = ref.read(ttsSettingsProvider);
        final locale = switch (next.languageCode) {
          'zh' => 'zh-CN',
          'en' => 'en-US',
          _ => 'en-US',
        };
        _ttsDriver.configure(
          voiceName: curr.voiceName,
          voiceLocale: curr.voiceLocale,
          defaultLocale: locale,
        );
      });
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialOffset > 0 && _controller.hasClients) {
        _controller.jumpTo(widget.initialOffset);
      }
    });
    _controller.addListener(() {
      if (!mounted || !_controller.hasClients) return;
      final max = _controller.position.hasContentDimensions
          ? _controller.position.maxScrollExtent
          : 0.0;
      final offset = _controller.offset.clamp(0.0, max);
      final progress = max > 0.0 ? (offset / max) : 0.0;
      if (progress != _scrollProgress) {
        setState(() => _scrollProgress = progress);
      }
    });
    if (widget.autoStartTts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoStartTts();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchNextIfEnabled(fromIdx: _currentIdx);
    });
  }

  @override
  void didUpdateWidget(covariant ChapterReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTtsIndex != oldWidget.initialTtsIndex && !_speaking) {
      setState(() {
        _ttsIndex = widget.initialTtsIndex.clamp(0, (_content?.length ?? 0));
      });
    }
    if (widget.content != oldWidget.content) {
      setState(() {
        _content = widget.content;
      });
    }
    if (widget.title != oldWidget.title) {
      setState(() {
        _title = widget.title;
      });
    }
    if (widget.chapterId != oldWidget.chapterId) {
      setState(() {
        _chapterId = widget.chapterId;
      });
    }
  }

  Future<void> _loadNextChapter() async {
    if (!mounted) return;
    final nextIdx = _currentIdx + 1;
    if (nextIdx >= _allChapters.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reachedLastChapter),
          ),
        );
      }
      return;
    }
    final Chapter next = _allChapters[nextIdx];
    setState(() {
      _chapterId = next.id;
      _title = next.title ?? 'Chapter ${next.idx}';
      _content = next.content;
      _currentIdx = nextIdx;
      _ttsIndex = 0;
      _speaking = false;
      _controller.jumpTo(0);
    });
    _tryAutoStartTts();
    await _prefetchNextIfEnabled(fromIdx: nextIdx);
  }

  Future<void> _loadPrevChapter() async {
    if (!mounted) return;
    final prevIdx = _currentIdx - 1;
    if (prevIdx < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reachedFirstChapter),
          ),
        );
      }
      return;
    }
    final Chapter prev = _allChapters[prevIdx];
    setState(() {
      _chapterId = prev.id;
      _title = prev.title ?? 'Chapter ${prev.idx}';
      _content = prev.content;
      _currentIdx = prevIdx;
      _ttsIndex = 0;
      _speaking = false;
      _controller.jumpTo(0);
    });
  }

  Future<void> _prefetchNextIfEnabled({required int fromIdx}) async {
    if (!mounted) return;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final perf = container.read(performanceSettingsProvider);
      final supEnabled = container.read(supabaseEnabledProvider);
      if (!perf.prefetchNextChapter || !supEnabled) return;
      final idx = fromIdx + 1;
      if (idx >= _allChapters.length) return;
      final next = _allChapters[idx];
      final repo = container.read(chapterRepositoryProvider);
      await repo.getChapter(next);
    } catch (_) {}
  }

  void _onPlayStopPressed() async {
    final l10n = AppLocalizations.of(context)!;
    if (_speaking) {
      await _ttsDriver.stop();
      if (!mounted) return;
      setState(() {
        _speaking = false;
      });
      final status = await saveReaderProgress(
        ref: ref,
        novelId: widget.novelId,
        chapterId: _chapterId,
        scrollOffset: _controller.hasClients ? _controller.offset : 0.0,
        ttsIndex: _ttsIndex,
      );
      if (!mounted) return;
      switch (status) {
        case SaveStatus.notEnabled:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.supabaseProgressNotSaved)),
          );
          break;
        case SaveStatus.noUser:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signInToSync)));
          break;
        case SaveStatus.saved:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.progressSaved)));
          break;
        case SaveStatus.error:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.errorSavingProgress)));
          break;
      }
    } else {
      setState(() => _autoplayBlocked = false);
      await _startTts();
    }
  }

  void _openSettingsForTts() {
    if (!mounted) return;
    context.push('/settings');
  }

  Future<void> _onTtsComplete() async {
    if (!mounted) return;
    setState(() => _speaking = false);
    await _loadNextChapter();
  }

  @override
  Widget build(BuildContext context) {
    ReaderBackgroundDepth depth;
    try {
      depth = ref.watch(themeControllerProvider).readerBgDepth;
    } catch (_) {
      depth = ReaderBackgroundDepth.medium;
    }
    final motion = ref.watch(motionSettingsProvider);
    try {
      ref.listen<Locale>(appSettingsProvider, (prev, next) {
        final curr = ref.read(ttsSettingsProvider);
        final locale = switch (next.languageCode) {
          'zh' => 'zh-CN',
          'en' => 'en-US',
          _ => 'en-US',
        };
        _ttsDriver.configure(
          voiceName: curr.voiceName,
          voiceLocale: curr.voiceLocale,
          defaultLocale: locale,
        );
      });
    } catch (_) {}
    final bgColor = readerBackgroundColor(Theme.of(context).colorScheme, depth);
    final readerScaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: _fullScreen
          ? null
          : ReaderAppBar(title: _title, onBack: _onBackPressed),
      endDrawer: _fullScreen ? null : SideBar(novelId: widget.novelId),
      body: _editMode
          ? _buildEditBody(context)
          : ReaderBody(
              controller: _controller,
              content: _content,
              ttsIndex: _ttsIndex,
              autoplayBlocked: _autoplayBlocked,
              onAutoplayContinue: () async {
                setState(() => _autoplayBlocked = false);
                await _startTts();
              },
              gesturesEnabled: motion.gesturesEnabled,
              swipeMinVelocity: motion.swipeMinVelocity,
              editMode: _editMode,
              discardDialogOpen: _discardDialogOpen,
              onToggleFullScreen: () =>
                  setState(() => _fullScreen = !_fullScreen),
              onPlayStop: _onPlayStopPressed,
              onPrev: _onPrevPressed,
              onNext: _onNextPressed,
            ),
      bottomNavigationBar: _fullScreen
          ? null
          : SafeArea(
              top: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxW = constraints.maxWidth;
                      final editPerms = ref.watch(
                        editPermissionsProvider(widget.novelId),
                      );
                      final bool canEdit = editPerms.asData?.value ?? false;

                      final current = _allChapters.isNotEmpty
                          ? _allChapters[_currentIdx]
                          : Chapter(
                              id: _chapterId,
                              novelId: widget.novelId,
                              idx: _currentIdx + 1,
                              title: _title,
                              content: _content,
                            );

                      final barProgress =
                          _speaking && (_content?.isNotEmpty ?? false)
                          ? (_content!.isNotEmpty
                                ? (_ttsIndex / _content!.length).clamp(0.0, 1.0)
                                : 0.0)
                          : _scrollProgress;

                      return ReaderBottomBarShell(
                        canEdit: canEdit,
                        editMode: _editMode,
                        speaking: _speaking,
                        scrollProgress: barProgress,
                        onEditToggle: _onEditTogglePressed,
                        onPrev: _onPrevPressed,
                        onNext: _onNextPressed,
                        onPlayStop: _onPlayStopPressed,
                        onOpenTtsSettings: _openSettingsForTts,
                        reduceMotion: motion.reduceMotion,
                        maxWidth: maxW,
                        current: current,
                        previewMode: _previewMode,
                        onTogglePreview: () =>
                            setState(() => _previewMode = !_previewMode),
                      );
                    },
                  ),
                ),
              ),
            ),
    );

    return ReaderShortcutsWrapper(
      disabled: _editMode || _discardDialogOpen,
      onToggleSpeak: _onPlayStopPressed,
      onPrev: _loadPrevChapter,
      onNext: _loadNextChapter,
      onOpenSettings: _openSettingsForTts,
      child: Focus(
        key: const ValueKey('reader_bar_focus'),
        autofocus: true,
        child: readerScaffold,
      ),
    );
  }

  Widget _buildEditBody(BuildContext context) {
    final current = _allChapters.isNotEmpty
        ? _allChapters[_currentIdx]
        : Chapter(
            id: _chapterId,
            novelId: widget.novelId,
            idx: _currentIdx + 1,
            title: _title,
            content: _content,
          );
    return EditChapterBody(
      novelId: widget.novelId,
      current: current,
      previewMode: _previewMode,
    );
  }

  bool _isEditDirty() {
    final current = _allChapters.isNotEmpty
        ? _allChapters[_currentIdx]
        : Chapter(
            id: _chapterId,
            novelId: widget.novelId,
            idx: _currentIdx + 1,
            title: _title,
            content: _content,
          );
    try {
      final state = ref.read(chapterEditControllerProvider(current));
      return state.isDirty;
    } catch (_) {
      return false;
    }
  }

  Future<DiscardDecision?> _showDiscardDialog() async {
    setState(() => _discardDialogOpen = true);
    final current = _allChapters.isNotEmpty
        ? _allChapters[_currentIdx]
        : Chapter(
            id: _chapterId,
            novelId: widget.novelId,
            idx: _currentIdx + 1,
            title: _title,
            content: _content,
          );
    final result = await showDiscardDialog(
      context: context,
      ref: ref,
      current: current,
    );
    if (mounted) setState(() => _discardDialogOpen = false);
    return result;
  }

  Future<void> _onEditTogglePressed() async {
    if (!_editMode) {
      setState(() => _editMode = true);
      return;
    }
    if (_isEditDirty()) {
      final decision = await _showDiscardDialog();
      if (decision == null || decision == DiscardDecision.keepEditing) {
        return;
      }
    }
    if (mounted) {
      setState(() {
        _editMode = false;
        _previewMode = false;
      });
    }
  }

  Future<void> _onPrevPressed() async {
    if (_editMode && _isEditDirty()) {
      final decision = await _showDiscardDialog();
      if (decision == null || decision == DiscardDecision.keepEditing) {
        return;
      }
      setState(() => _editMode = false);
    }
    await _loadPrevChapter();
  }

  Future<void> _onNextPressed() async {
    if (_editMode && _isEditDirty()) {
      final decision = await _showDiscardDialog();
      if (decision == null || decision == DiscardDecision.keepEditing) {
        return;
      }
      setState(() => _editMode = false);
    }
    await _loadNextChapter();
  }

  Future<void> _onBackPressed() async {
    if (_editMode && _isEditDirty()) {
      final decision = await _showDiscardDialog();
      if (decision == null || decision == DiscardDecision.keepEditing) {
        return;
      }
      setState(() => _editMode = false);
    }
    if (!mounted) return;
    try {
      context.pop();
    } catch (_) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startTts({bool optimistic = true}) async {
    if (optimistic && mounted) {
      setState(() => _speaking = true);
    }
    final current = ref.read(ttsSettingsProvider);
    final appLocale = ref.read(appSettingsProvider);
    final mapped = switch (appLocale.languageCode) {
      'zh' => 'zh-CN',
      'en' => 'en-US',
      _ => 'en-US',
    };
    await _ttsDriver.configure(
      voiceName: current.voiceName,
      voiceLocale: current.voiceLocale,
      defaultLocale: mapped,
      onProgress: (i) {
        if (!mounted) return;
        setState(() => _ttsIndex = i);
      },
      onStart: () {
        if (!mounted) return;
        setState(() => _speaking = true);
      },
      onCancel: () {
        if (!mounted) return;
        setState(() => _speaking = false);
      },
      onError: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.ttsError(msg))),
        );
      },
      onAllComplete: _onTtsComplete,
    );
    await _ttsDriver.setRate(current.rate);
    await _ttsDriver.setVolume(current.volume);
    await _ttsDriver.start(content: _content ?? '', startIndex: _ttsIndex);
  }

  void _tryAutoStartTts() {
    _autoStartAttempts = 0;
    _autoStartRetry?.cancel();
    _startTts(optimistic: false);
    _scheduleAutoStartRetry();
  }

  void _scheduleAutoStartRetry() {
    _autoStartRetry?.cancel();
    final delays = <Duration>[
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
      const Duration(seconds: 8),
    ];
    final idx = _autoStartAttempts.clamp(0, delays.length - 1);
    final delay = delays[idx];
    _autoStartRetry = Timer(delay, () {
      if (!mounted) return;
      final hasProgress = _ttsIndex > 0;
      if (_speaking || hasProgress) {
        _autoStartRetry?.cancel();
        if (_autoplayBlocked) setState(() => _autoplayBlocked = false);
        return;
      }
      _autoStartAttempts += 1;
      if (_autoStartAttempts >= 1 && !_autoplayBlocked) {
        setState(() => _autoplayBlocked = true);
        if (!_autoplaySnackShown) {
          _autoplaySnackShown = true;
          _showAutoplayPrompt();
        }
      }
      if (_autoStartAttempts > _maxAutoStartAttempts) {
        _autoStartRetry?.cancel();
        return;
      }
      _startTts(optimistic: false);
      _scheduleAutoStartRetry();
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
            setState(() => _autoplayBlocked = false);
            await _startTts();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _autoStartRetry?.cancel();
    _controller.dispose();
    _ttsDriver.stop();
    super.dispose();
  }
}
