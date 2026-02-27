import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/shared/strings.dart';

import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';
import 'package:writer/shared/widgets/feedback/enhanced_toast.dart';
import 'package:writer/features/editor/focus_timer.dart';
import 'package:writer/features/editor/writing_prompts.dart';
import 'package:writer/features/editor/services/writing_streak_tracker.dart';
import 'mobile_editor/mobile_editor_app_bar.dart';
import 'mobile_editor/mobile_editor_body.dart';
import 'mobile_editor/mobile_editor_menus.dart';
import 'mobile_editor/mobile_editor_shortcuts.dart';

/// Mobile-optimized editor screen
/// Features:
/// - Inline formatting toolbar
/// - Auto-save indicator
/// - Keyboard-aware layout
/// - Haptic feedback
/// - Long-press menus
class MobileEditorScreen extends ConsumerStatefulWidget {
  const MobileEditorScreen({
    super.key,
    required this.novelId,
    this.chapterId,
    this.initialContent,
  });

  final String novelId;
  final String? chapterId;
  final String? initialContent;

  @override
  ConsumerState<MobileEditorScreen> createState() => _MobileEditorScreenState();
}

class _MobileEditorScreenState extends ConsumerState<MobileEditorScreen> {
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _isDiscarding = false;
  bool _preview = false;
  bool _zenMode = false;
  Chapter? _chapter;
  int _streakDays = 0;
  final WritingStreakTracker _streakTracker = const WritingStreakTracker();

  MobileNavTab _currentTab = MobileNavTab.write;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _titleController = TextEditingController();

    _contentController.addListener(_onContentChanged);
    _titleController.addListener(_onContentChanged);

    if (widget.chapterId != null) {
      _loadChapter();
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    _loadWritingStreak();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    try {
      final chapters = await ref.read(
        chaptersProviderV2(widget.novelId).future,
      );
      final chapter = chapters.firstWhere(
        (c) => c.id == widget.chapterId,
        orElse: () => throw Exception('Chapter not found'),
      );

      // Ensure we have full content
      final repo = ref.read(chapterRepositoryProvider);
      final fullChapter = await repo.getChapter(chapter);

      if (mounted) {
        setState(() {
          _chapter = fullChapter;
          _titleController.text = fullChapter.title ?? '';
          if (widget.initialContent == null) {
            _contentController.text = fullChapter.content ?? '';
          }
          _isLoading = false;
          _hasUnsavedChanges = false; // Reset after load
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showEnhancedToast(
          context,
          message: 'Failed to load chapter: $e',
          tone: EnhancedToastTone.error,
          actionLabel: 'Retry',
          onAction: _loadChapter,
        );
      }
    }
  }

  void _onContentChanged() {
    if (!_isLoading && !_isDiscarding) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveContent() async {
    if (!_hasUnsavedChanges) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      final repo = ref.read(chapterRepositoryProvider);

      if (_chapter != null) {
        // Update existing
        final updated = _chapter!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        );
        await repo.updateChapter(updated);
        _chapter = updated;
      } else {
        // Create new
        final nextIdx = await repo.getNextIdx(widget.novelId);
        final created = await repo.createChapter(
          novelId: widget.novelId,
          idx: nextIdx,
          title: _titleController.text.isEmpty
              ? 'Chapter $nextIdx'
              : _titleController.text,
          content: _contentController.text,
        );
        _chapter = created;
      }

      await _recordWritingSessionIfNeeded();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = false;
        });
        showEnhancedToast(
          context,
          message: l10n.saved,
          tone: EnhancedToastTone.success,
        );
        // Refresh chapters list
        ref.invalidate(chaptersProviderV2(widget.novelId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showEnhancedToast(
          context,
          message: 'Save failed: $e',
          tone: EnhancedToastTone.error,
          actionLabel: 'Retry',
          onAction: _saveContent,
        );
      }
    }
  }

  void _togglePreview() {
    setState(() => _preview = !_preview);
    HapticFeedback.selectionClick();
  }

  Future<void> _loadWritingStreak() async {
    final storage = ref.read(storageServiceProvider);
    final streak = await _streakTracker.loadStreak(storage);
    if (!mounted) return;
    setState(() => _streakDays = streak);
  }

  Future<void> _recordWritingSessionIfNeeded() async {
    final words = countWords(_contentController.text);
    if (words <= 0) return;

    final storage = ref.read(storageServiceProvider);
    final next = await _streakTracker.recordWritingSessionIfNeeded(
      storage,
      words: words,
    );
    if (next == null || !mounted) return;
    setState(() => _streakDays = next);
  }

  void _enterZenMode() {
    setState(() => _zenMode = true);
    HapticFeedback.selectionClick();
  }

  void _exitZenMode() {
    setState(() => _zenMode = false);
    HapticFeedback.selectionClick();
  }

  void _showFocusTimer(BuildContext context) {
    MobileBottomSheet.show(
      context: context,
      title: 'Focus timer',
      builder: (_) => const FocusTimerSheet(),
    );
  }

  void _showWritingPrompts(BuildContext context) {
    MobileBottomSheet.show(
      context: context,
      title: 'Writing prompts',
      builder: (sheetContext) => WritingPromptsSheet(
        onInsert: (prompt) {
          Navigator.of(sheetContext).pop();
          _insertTextAtCursor('$prompt\n\n');
        },
      ),
    );
  }

  void _insertTextAtCursor(String insertion) {
    final selection = _contentController.selection;
    final text = _contentController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final updated = text.replaceRange(start, end, insertion);
    _contentController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardHeight = bottomInset > 0 ? bottomInset : 0.0;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.loadingProgress)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: MobileEditorShortcuts(
        contentController: _contentController,
        preview: _preview,
        onSave: _saveContent,
        onTogglePreview: _togglePreview,
        onShowHelp: () => showMobileEditorShortcutsHelp(context),
        onDismiss: () => Navigator.of(context).maybePop(),
        child: Scaffold(
          appBar: _zenMode
              ? null
              : MobileEditorAppBar(
                  l10n: l10n,
                  hasUnsavedChanges: _hasUnsavedChanges,
                  onOpenMenu: () => _openMoreMenu(context),
                ),
          body: SafeArea(
            child: MobileEditorBody(
              l10n: l10n,
              theme: theme,
              keyboardHeight: keyboardHeight,
              zenMode: _zenMode,
              preview: _preview,
              isSaving: _isSaving,
              streakDays: _streakDays,
              titleController: _titleController,
              contentController: _contentController,
              onSave: _saveContent,
              onExitZenMode: _exitZenMode,
              onTogglePreview: _togglePreview,
            ),
          ),
          floatingActionButton: null,
          bottomNavigationBar: _zenMode
              ? null
              : MobileBottomNavBar(
                  currentTab: _currentTab,
                  onTabChanged: _onTabChanged,
                  showLabels: false,
                ),
        ),
      ),
    );
  }

  void _openMoreMenu(BuildContext context) {
    showMobileEditorMoreMenu(
      context: context,
      onEnterZenMode: _enterZenMode,
      onShowFocusTimer: () => _showFocusTimer(context),
      onShowWritingPrompts: () => _showWritingPrompts(context),
      onShowWordCount: () => _showWordCount(context),
      onShowCharacterCount: () => _showCharacterCount(context),
      onDiscardChanges: () => _discardChanges(context),
      onOpenSettings: () => context.push('/settings'),
      onShowShortcutsHelp: () => showMobileEditorShortcutsHelp(context),
    );
  }

  void _onTabChanged(MobileNavTab tab) {
    setState(() {
      _currentTab = tab;
    });
    _handleTabNavigation(tab, context);
  }

  void _handleTabNavigation(MobileNavTab tab, BuildContext context) {
    switch (tab) {
      case MobileNavTab.home:
        context.push('/');
        break;
      case MobileNavTab.write:
        // Already on write
        break;
      case MobileNavTab.read:
        // Navigate to reading screen
        // We need to know which chapter to read? Or just novel view?
        context.push('/novel/${widget.novelId}');
        break;
      case MobileNavTab.tools:
        context.pushNamed('tools');
        break;
      case MobileNavTab.more:
        _openMoreMenu(context);
        break;
    }
  }

  void _showWordCount(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final text = _contentController.text;
    final wordCount = text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Word count: $wordCount'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCharacterCount(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final text = _contentController.text;
    final charCount = text.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Character count: $charCount'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _discardChanges(BuildContext context) {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AppDialog(
          title: 'Discard Changes?',
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            AppButtons.text(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Cancel',
            ),
            AppButtons.text(
              onPressed: () {
                Navigator.of(context).pop();

                _isDiscarding = true;
                if (_chapter != null) {
                  _contentController.text = _chapter!.content ?? '';
                  _titleController.text = _chapter!.title ?? '';
                } else {
                  _contentController.clear();
                  _titleController.clear();
                }
                _hasUnsavedChanges = false;
                _isDiscarding = false;

                setState(() {});
              },
              label: 'Discard',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(); // Close sheet
    }
  }
}
