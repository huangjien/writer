import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/mobile_bottom_nav_bar.dart';
import '../../repositories/chapter_repository.dart';
import '../../models/chapter.dart';
import '../../state/novel_providers_v2.dart';
import '../../state/storage_service_provider.dart';
import '../../shared/strings.dart';

import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/mobile_bottom_sheet.dart';
import '../../shared/widgets/feedback/enhanced_toast.dart';
import 'focus_timer.dart';
import 'formatting_toolbar.dart';
import 'rich_text_editor.dart';
import 'writing_prompts.dart';
import 'writing_stats.dart';
import 'zen_mode.dart';

class _StorageKeys {
  static const String lastWriteDate = 'writer.editor.last_write_date';
  static const String streakDays = 'writer.editor.streak_days';
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _TogglePreviewIntent extends Intent {
  const _TogglePreviewIntent();
}

class _HelpIntent extends Intent {
  const _HelpIntent();
}

class _BoldIntent extends Intent {
  const _BoldIntent();
}

class _ItalicIntent extends Intent {
  const _ItalicIntent();
}

class _UnderlineIntent extends Intent {
  const _UnderlineIntent();
}

class _HeadingIntent extends Intent {
  const _HeadingIntent();
}

class _LinkIntent extends Intent {
  const _LinkIntent();
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}

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
          onAction: () => _loadChapter(),
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
          onAction: () => _saveContent(),
        );
      }
    }
  }

  void _togglePreview() {
    setState(() => _preview = !_preview);
    HapticFeedback.selectionClick();
  }

  Future<void> _loadWritingStreak() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final last = storage.getString(_StorageKeys.lastWriteDate);
      final streakRaw = storage.getString(_StorageKeys.streakDays);
      final storedStreak = int.tryParse(streakRaw ?? '') ?? 0;

      if (last == null) {
        if (mounted) setState(() => _streakDays = 0);
        return;
      }

      final lastDate = DateTime.tryParse(last);
      if (lastDate == null) {
        if (mounted) setState(() => _streakDays = 0);
        return;
      }

      final today = _todayDate();
      final diff = today.difference(_dateOnly(lastDate)).inDays;
      final effective = (diff == 0 || diff == 1) ? storedStreak : 0;
      if (mounted) setState(() => _streakDays = effective);
    } catch (_) {
      if (mounted) setState(() => _streakDays = 0);
    }
  }

  Future<void> _recordWritingSessionIfNeeded() async {
    final words = countWords(_contentController.text);
    if (words <= 0) return;

    try {
      final storage = ref.read(storageServiceProvider);
      final today = _todayDate();
      final todayKey = _formatDate(today);

      final last = storage.getString(_StorageKeys.lastWriteDate);
      final streakRaw = storage.getString(_StorageKeys.streakDays);
      final currentStreak = int.tryParse(streakRaw ?? '') ?? 0;

      if (last == null) {
        await storage.setString(_StorageKeys.lastWriteDate, todayKey);
        await storage.setString(_StorageKeys.streakDays, '1');
        if (mounted) setState(() => _streakDays = 1);
        return;
      }

      final lastDate = DateTime.tryParse(last);
      if (lastDate == null) {
        await storage.setString(_StorageKeys.lastWriteDate, todayKey);
        await storage.setString(_StorageKeys.streakDays, '1');
        if (mounted) setState(() => _streakDays = 1);
        return;
      }

      final diff = today.difference(_dateOnly(lastDate)).inDays;
      if (diff == 0) {
        if (mounted) setState(() => _streakDays = currentStreak);
        return;
      }

      final next = diff == 1 ? (currentStreak <= 0 ? 2 : currentStreak + 1) : 1;
      await storage.setString(_StorageKeys.lastWriteDate, todayKey);
      await storage.setString(_StorageKeys.streakDays, '$next');
      if (mounted) setState(() => _streakDays = next);
    } catch (_) {
      return;
    }
  }

  static DateTime _todayDate() {
    return _dateOnly(DateTime.now());
  }

  static DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyS, control: true):
              _SaveIntent(),
          SingleActivator(LogicalKeyboardKey.keyS, meta: true): _SaveIntent(),
          SingleActivator(LogicalKeyboardKey.keyP, control: true):
              _TogglePreviewIntent(),
          SingleActivator(LogicalKeyboardKey.keyP, meta: true):
              _TogglePreviewIntent(),
          SingleActivator(LogicalKeyboardKey.slash, control: true):
              _HelpIntent(),
          SingleActivator(LogicalKeyboardKey.slash, meta: true): _HelpIntent(),
          SingleActivator(LogicalKeyboardKey.keyB, control: true):
              _BoldIntent(),
          SingleActivator(LogicalKeyboardKey.keyB, meta: true): _BoldIntent(),
          SingleActivator(LogicalKeyboardKey.keyI, control: true):
              _ItalicIntent(),
          SingleActivator(LogicalKeyboardKey.keyI, meta: true): _ItalicIntent(),
          SingleActivator(LogicalKeyboardKey.keyU, control: true):
              _UnderlineIntent(),
          SingleActivator(LogicalKeyboardKey.keyU, meta: true):
              _UnderlineIntent(),
          SingleActivator(LogicalKeyboardKey.digit1, control: true):
              _HeadingIntent(),
          SingleActivator(LogicalKeyboardKey.digit1, meta: true):
              _HeadingIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, control: true):
              _LinkIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, meta: true): _LinkIntent(),
          SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _SaveIntent: CallbackAction<_SaveIntent>(
              onInvoke: (_) {
                _saveContent();
                return null;
              },
            ),
            _TogglePreviewIntent: CallbackAction<_TogglePreviewIntent>(
              onInvoke: (_) {
                _togglePreview();
                return null;
              },
            ),
            _HelpIntent: CallbackAction<_HelpIntent>(
              onInvoke: (_) {
                _showShortcutsHelp(context);
                return null;
              },
            ),
            _BoldIntent: CallbackAction<_BoldIntent>(
              onInvoke: (_) {
                MarkdownEditActions.toggleBold(_contentController);
                return null;
              },
            ),
            _ItalicIntent: CallbackAction<_ItalicIntent>(
              onInvoke: (_) {
                MarkdownEditActions.toggleItalic(_contentController);
                return null;
              },
            ),
            _UnderlineIntent: CallbackAction<_UnderlineIntent>(
              onInvoke: (_) {
                MarkdownEditActions.toggleUnderline(_contentController);
                return null;
              },
            ),
            _HeadingIntent: CallbackAction<_HeadingIntent>(
              onInvoke: (_) {
                MarkdownEditActions.insertHeading(_contentController);
                return null;
              },
            ),
            _LinkIntent: CallbackAction<_LinkIntent>(
              onInvoke: (_) {
                MarkdownEditActions.insertLink(_contentController);
                return null;
              },
            ),
            _DismissIntent: CallbackAction<_DismissIntent>(
              onInvoke: (_) {
                if (_preview) {
                  _togglePreview();
                  return null;
                }
                Navigator.of(context).maybePop();
                return null;
              },
            ),
          },
          child: Scaffold(
            appBar: _zenMode ? null : _buildAppBar(context, l10n),
            body: SafeArea(
              child: Column(
                children: [
                  if (_zenMode)
                    ZenModeBar(
                      onExit: _exitZenMode,
                      onSave: _saveContent,
                      preview: _preview,
                      onTogglePreview: _togglePreview,
                    ),
                  if (!_zenMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.m,
                        Spacing.m,
                        Spacing.m,
                        Spacing.s,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextField(
                                controller: _titleController,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  labelText: l10n.chapterTitle,
                                  hintText: l10n.enterChapterTitle,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: Spacing.m,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      Radii.m,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.s),
                          AppButtons.primary(
                            onPressed: _isSaving ? () {} : _saveContent,
                            icon: Icons.save,
                            label: l10n.save,
                            isLoading: _isSaving,
                            enabled: !_isSaving,
                          ),
                        ],
                      ),
                    ),
                  if (!_zenMode)
                    RichTextToolbar(
                      preview: _preview,
                      controller: _contentController,
                      onTogglePreview: _togglePreview,
                      onBold: () =>
                          MarkdownEditActions.toggleBold(_contentController),
                      onItalic: () =>
                          MarkdownEditActions.toggleItalic(_contentController),
                      onUnderline: () => MarkdownEditActions.toggleUnderline(
                        _contentController,
                      ),
                      onHeading: () =>
                          MarkdownEditActions.insertHeading(_contentController),
                      onQuote: () =>
                          MarkdownEditActions.insertQuote(_contentController),
                      onCode: () => MarkdownEditActions.toggleInlineCode(
                        _contentController,
                      ),
                      onBullet: () =>
                          MarkdownEditActions.insertBullet(_contentController),
                      onNumbered: () => MarkdownEditActions.insertNumbered(
                        _contentController,
                      ),
                      onLink: () =>
                          MarkdownEditActions.insertLink(_contentController),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: RichTextEditor(
                        controller: _contentController,
                        preview: _preview,
                        hintText: l10n.startWriting,
                        semanticsLabel: l10n.chapterContent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: WritingStats(
                      controller: _contentController,
                      streakDays: _streakDays,
                      showCounts: false,
                    ),
                  ),
                  if (_isSaving)
                    Container(
                      padding: EdgeInsets.only(bottom: keyboardHeight),
                      child: Semantics(
                        container: true,
                        liveRegion: true,
                        label: l10n.saving,
                        child: ExcludeSemantics(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: Spacing.s),
                              Text(
                                l10n.saving,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!_isSaving) SizedBox(height: keyboardHeight),
                ],
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.edit, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: Spacing.s),
          Text(
            'Editor',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(left: Spacing.s),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s,
                vertical: Spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(Radii.s),
              ),
              child: Text(
                'Unsaved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
          onPressed: () => _showMoreMenu(context, l10n),
        ),
      ],
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
        _showMoreMenu(context, AppLocalizations.of(context)!);
        break;
    }
  }

  void _showMoreMenu(BuildContext context, AppLocalizations l10n) {
    MobileBottomSheet.showActionSheet(
      context: context,
      items: [
        ActionSheetItem(
          label: 'Zen mode',
          icon: Icons.center_focus_strong,
          value: 'zen',
          onPressed: _enterZenMode,
        ),
        ActionSheetItem(
          label: 'Focus timer',
          icon: Icons.timer,
          value: 'focus_timer',
          onPressed: () => _showFocusTimer(context),
        ),
        ActionSheetItem(
          label: 'Writing prompts',
          icon: Icons.lightbulb_outline,
          value: 'writing_prompts',
          onPressed: () => _showWritingPrompts(context),
        ),
        ActionSheetItem(
          label: 'Word Count',
          icon: Icons.format_size,
          value: 'wordcount',
          onPressed: () => _showWordCount(context),
        ),
        ActionSheetItem(
          label: 'Character Count',
          icon: Icons.text_fields,
          value: 'charcount',
          onPressed: () => _showCharacterCount(context),
        ),
        ActionSheetItem(
          label: 'Discard Changes',
          icon: Icons.delete_outline,
          value: 'discard',
          isDestructive: true,
          onPressed: () => _discardChanges(context),
        ),
        ActionSheetItem(
          label: 'Settings',
          icon: Icons.settings,
          value: 'settings',
          onPressed: () => context.push('/settings'),
        ),
        ActionSheetItem(
          label: 'Keyboard shortcuts',
          icon: Icons.keyboard,
          value: 'shortcuts',
          onPressed: () => _showShortcutsHelp(context),
        ),
      ],
    );
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
                _isDiscarding = false;

                setState(() {
                  _hasUnsavedChanges = false;
                });
                HapticFeedback.heavyImpact();
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

  void _showShortcutsHelp(BuildContext context) {
    MobileBottomSheet.show(
      context: context,
      title: 'Keyboard shortcuts',
      builder: (context) {
        final items = <(String, String)>[
          ('Save', 'Ctrl/⌘ + S'),
          ('Preview', 'Ctrl/⌘ + P'),
          ('Bold', 'Ctrl/⌘ + B'),
          ('Italic', 'Ctrl/⌘ + I'),
          ('Underline', 'Ctrl/⌘ + U'),
          ('Heading', 'Ctrl/⌘ + 1'),
          ('Insert link', 'Ctrl/⌘ + K'),
          ('Shortcuts help', 'Ctrl/⌘ + /'),
          ('Close', 'Esc'),
        ];
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Spacing.l),
          itemBuilder: (context, i) {
            final it = items[i];
            return Row(
              children: [
                Expanded(
                  child: Text(
                    it.$1,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  it.$2,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
          separatorBuilder: (context, _) => const SizedBox(height: Spacing.m),
          itemCount: items.length,
        );
      },
    );
  }
}
