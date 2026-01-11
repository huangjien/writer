import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/mobile_bottom_nav_bar.dart';
import '../../shared/widgets/mobile_fab.dart';
import '../../repositories/chapter_repository.dart';
import '../../models/chapter.dart';
import '../../state/novel_providers.dart';

import '../../shared/widgets/mobile_bottom_sheet.dart';
import '../../shared/widgets/feedback/enhanced_toast.dart';
import '../../shared/widgets/rich_text_editor.dart';
import '../../shared/widgets/rich_text_toolbar.dart';

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
  Chapter? _chapter;

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
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    try {
      final chapters = await ref.read(chaptersProvider(widget.novelId).future);
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

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = false;
        });
        showEnhancedToast(
          context,
          message: 'Saved',
          tone: EnhancedToastTone.success,
        );
        // Refresh chapters list
        ref.invalidate(chaptersProvider(widget.novelId));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardHeight = bottomInset > 0 ? bottomInset : 0.0;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: SafeArea(
        child: Column(
          children: [
            // Title input
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Chapter Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.m),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                style: theme.textTheme.titleLarge,
              ),
            ),
            // Formatting toolbar
            RichTextToolbar(
              preview: _preview,
              onTogglePreview: _togglePreview,
              onBold: () => MarkdownEditActions.toggleBold(_contentController),
              onItalic: () =>
                  MarkdownEditActions.toggleItalic(_contentController),
              onUnderline: () =>
                  MarkdownEditActions.toggleUnderline(_contentController),
              onHeading: () =>
                  MarkdownEditActions.insertHeading(_contentController),
              onQuote: () =>
                  MarkdownEditActions.insertQuote(_contentController),
              onCode: () =>
                  MarkdownEditActions.toggleInlineCode(_contentController),
              onBullet: () =>
                  MarkdownEditActions.insertBullet(_contentController),
              onNumbered: () =>
                  MarkdownEditActions.insertNumbered(_contentController),
              onLink: () => MarkdownEditActions.insertLink(_contentController),
            ),
            // Content editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                child: RichTextEditor(
                  controller: _contentController,
                  preview: _preview,
                  hintText: 'Start writing...',
                ),
              ),
            ),
            // Auto-save indicator
            if (_isSaving)
              Container(
                padding: EdgeInsets.only(bottom: Spacing.m + keyboardHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: Spacing.s),
                    Text('Saving...', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            // Bottom padding for keyboard
            if (!_isSaving) SizedBox(height: Spacing.m + keyboardHeight),
          ],
        ),
      ),
      floatingActionButton: MobileFab(
        onPressed: _saveContent,
        label: 'Save',
        icon: Icons.save,
        type: MobileFabType.secondary,
        isLoading: _isSaving,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MobileBottomNavBar(
        currentTab: _currentTab,
        onTabChanged: _onTabChanged,
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
        // Navigate to tools
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
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(); // Close sheet
    }
  }
}
