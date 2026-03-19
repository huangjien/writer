# Keyboard Shortcuts Implementation Guide

This document provides guidance on integrating keyboard shortcuts into the application.

## Overview

The keyboard shortcuts system has been implemented with the following components:

1. **`lib/shared/widgets/keyboard_shortcuts.dart`** - All Intent classes and shortcut mappings
2. **`lib/shared/widgets/keyboard_shortcuts_dialog.dart`** - Dialog and bottom sheet for showing shortcuts
3. **`lib/shared/widgets/global_shortcuts_wrapper.dart`** - Wrapper widgets for different screen types
4. **`lib/shared/widgets/tooltip_with_shortcut.dart`** - Helpers for adding shortcuts to tooltips

## Quick Start

### 1. Show Keyboard Shortcuts Dialog

To display the keyboard shortcuts help dialog:

```dart
import 'package:writer/shared/widgets/keyboard_shortcuts_dialog.dart';

// For desktop (modal dialog)
showKeyboardShortcutsDialog(context);

// For mobile (bottom sheet)
showKeyboardShortcutsSheet(context);
```

### 2. Add Shortcuts to a Screen

#### Option A: Using Pre-built Wrappers

The easiest way is to wrap your screen with one of the pre-built wrappers:

```dart
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';

// For library screen
LibraryShortcutsWrapper(
  onCreateNovel: () => _createNovel(),
  onFocusSearch: () => _focusSearch(),
  onDeleteNovel: () => _deleteNovel(),
  child: YourScreen(),
)

// For chapter list
ChapterListShortcutsWrapper(
  onCreateChapter: () => _createChapter(),
  onRefreshChapters: () => _refreshChapters(),
  onDuplicateChapter: () => _duplicateChapter(),
  onDeleteChapter: () => _deleteChapter(),
  child: YourScreen(),
)

// For settings
SettingsShortcutsWrapper(
  onFocusAppSettings: () => _focusAppSettings(),
  onFocusColorTheme: () => _focusColorTheme(),
  onFocusTypography: () => _focusTypography(),
  onFocusPerformance: () => _focusPerformance(),
  onFocusTTSSettings: () => _focusTTSSettings(),
  child: YourScreen(),
)

// For editor
EditorShortcutsWrapper(
  onSave: () => _save(),
  onSaveAndClose: () => _saveAndClose(),
  onCloseWithoutSaving: () => _closeWithoutSaving(),
  onToggleBold: () => _toggleBold(),
  onToggleItalic: () => _toggleItalic(),
  onToggleUnderline: () => _toggleUnderline(),
  onInsertLink: () => _insertLink(),
  onInsertCodeBlock: () => _insertCodeBlock(),
  onInsertHeading1: () => _insertHeading1(),
  onInsertHeading2: () => _insertHeading2(),
  onInsertHeading3: () => _insertHeading3(),
  onInsertParagraph: () => _insertParagraph(),
  child: YourScreen(),
)
```

#### Option B: Custom Shortcuts

For more control, create custom shortcuts using the Intent classes:

```dart
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';

Shortcuts(
  shortcuts: <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.keyS, meta: true): const SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyN, meta: true): const CreateIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  },
  child: Actions(
    actions: <Type, Action<Intent>>{
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (_) {
          // Handle save
          return null;
        },
      ),
      CreateIntent: CallbackAction<CreateIntent>(
        onInvoke: (_) {
          // Handle create
          return null;
        },
      ),
      CloseIntent: CallbackAction<CloseIntent>(
        onInvoke: (_) {
          // Handle close
          return null;
        },
      ),
    },
    child: YourScreen(),
  ),
)
```

### 3. Add Shortcut Hints to Tooltips

#### Using the Helper Class

```dart
import 'package:writer/shared/widgets/tooltip_with_shortcut.dart';

IconButton(
  icon: const Icon(Icons.save),
  tooltip: TooltipWithShortcut.appendShortcut(context, l10n.save, 'S'),
  onPressed: () => _save(),
)
```

#### Using the String Extension

```dart
import 'package:writer/shared/widgets/tooltip_with_shortcut.dart';

AppButtons.icon(
  iconData: Icons.save,
  tooltip: l10n.save.withShortcut('S'),
  onPressed: () => _save(),
)
```

#### Using ShortcutKey Widget

```dart
import 'package:writer/shared/widgets/keyboard_shortcuts_dialog.dart';

Row(
  children: [
    Text(l10n.save),
    SizedBox(width: 8),
    ShortcutKeys(keys: ['⌘', 'S']),
  ],
)
```

## Available Intents

### Global Intents
- `NavigateHomeIntent` - Navigate to home/library
- `NavigateSettingsIntent` - Open settings
- `ShowShortcutsHelpIntent` - Show keyboard shortcuts help
- `QuickSearchIntent` - Open quick search
- `CloseIntent` - Close dialog/screen
- `NavigateBackIntent` - Navigate back
- `NavigateForwardIntent` - Navigate forward
- `ForceRefreshIntent` - Force refresh

### Library Intents
- `CreateNovelIntent` - Create new novel
- `FocusSearchIntent` - Focus search box
- `DeleteNovelIntent` - Delete selected novel

### Chapter List Intents
- `CreateChapterIntent` - Create new chapter
- `RefreshChaptersIntent` - Refresh chapter list
- `DuplicateChapterIntent` - Duplicate selected chapter
- `DeleteChapterIntent` - Delete selected chapter

### Editor Intents
- `SaveIntent` - Save current work
- `SaveAndCloseIntent` - Save and close
- `CloseWithoutSavingIntent` - Close without saving
- `BoldIntent` - Toggle bold
- `ItalicIntent` - Toggle italic
- `UnderlineIntent` - Toggle underline
- `InsertLinkIntent` - Insert link
- `InsertCodeBlockIntent` - Insert code block
- `Heading1Intent` - Insert heading 1
- `Heading2Intent` - Insert heading 2
- `Heading3Intent` - Insert heading 3
- `ParagraphIntent` - Insert paragraph

### Reader Intents
- `ToggleTTSIntent` - Toggle TTS play/pause
- `PreviousChapterIntent` - Go to previous chapter
- `NextChapterIntent` - Go to next chapter
- `IncreaseSpeechRateIntent` - Increase TTS speech rate
- `DecreaseSpeechRateIntent` - Decrease TTS speech rate
- `ChangeVoiceIntent` - Change TTS voice
- `MuteUnmuteIntent` - Mute/unmute TTS
- `EnterFullscreenIntent` - Enter fullscreen

### Settings Intents
- `FocusAppSettingsIntent` - Focus app settings section
- `FocusColorThemeIntent` - Focus color theme section
- `FocusTypographyIntent` - Focus typography section
- `FocusPerformanceIntent` - Focus performance section
- `FocusTTSSettingsIntent` - Focus TTS settings section

### Sidebar Intents
- `ToggleSidebarIntent` - Toggle sidebar open/close
- `ToggleAiSidebarIntent` - Toggle AI sidebar open/close
- `NavigateToChaptersIntent` - Navigate to chapters
- `NavigateToCharactersIntent` - Navigate to characters
- `NavigateToScenesIntent` - Navigate to scenes
- `NavigateToSummariesIntent` - Navigate to summaries

### Sidebar Shortcut Contract
- `Ctrl/Cmd + B` - Toggle left sidebar
- `Ctrl/Cmd + I` - Toggle right sidebar (AI)
- `Ctrl/Cmd + 1` - Chapters
- `Ctrl/Cmd + 2` - Characters
- `Ctrl/Cmd + 3` - Scenes
- `Ctrl/Cmd + 4` - Summary

### Admin Intents
- `OpenUserManagementIntent` - Open user management
- `OpenAdminLogsIntent` - Open admin logs
- `ToggleAdminModeIntent` - Toggle admin mode

## Platform-Specific Behavior

The system automatically handles platform differences:

- **macOS**: Uses `⌘` (Command) key
- **Windows/Linux**: Uses `Ctrl` key
- **Web**: Uses `Ctrl` key

Use the helper functions to get platform-appropriate labels:

```dart
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';

// Get modifier key label
final modifier = modifierKeyLabel; // "⌘" on Mac, "Ctrl" on others

// Get formatted shortcut
final shortcut = getShortcutLabel('S'); // "⌘+S" on Mac, "Ctrl+S" on others

// Check if platform uses meta key
final isMac = usesMeta; // true on Mac, false on others
```

## Integration Examples

### Example 1: Library Screen with Shortcuts

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';
import 'package:writer/shared/widgets/tooltip_with_shortcut.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return LibraryShortcutsWrapper(
      onCreateNovel: () => context.push('/novels/new'),
      onFocusSearch: () => _focusSearch(context),
      onDeleteNovel: () => _showDeleteDialog(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTitle),
          actions: [
            AppButtons.icon(
              iconData: Icons.add,
              tooltip: l10n.newLabel.withShortcut('N'),
              onPressed: () => context.push('/novels/new'),
            ),
            AppButtons.icon(
              iconData: Icons.search,
              tooltip: l10n.searchLabel.withShortcut('K'),
              onPressed: () => _focusSearch(context),
            ),
          ],
        ),
        body: NovelList(),
      ),
    );
  }
}
```

### Example 2: Settings Screen with Shortcuts

```dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsShortcutsWrapper(
      onFocusAppSettings: () => _scrollToSection('app'),
      onFocusColorTheme: () => _scrollToSection('theme'),
      onFocusTypography: () => _scrollToSection('typography'),
      onFocusPerformance: () => _scrollToSection('performance'),
      onFocusTTSSettings: () => _scrollToSection('tts'),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          actions: [
            AppButtons.icon(
              iconData: Icons.help_outline,
              tooltip: l10n.shortcutsHelpShortcut.withShortcut('/'),
              onPressed: () => showKeyboardShortcutsDialog(context),
            ),
          ],
        ),
        body: ListView(
          children: [
            // Settings sections...
          ],
        ),
      ),
    );
  }
}
```

### Example 3: Sidebar with Shortcuts

```dart
SidebarShortcutsWrapper(
  onToggleSidebar: () => _toggleLeftSidebar(),
  onToggleAiSidebar: () => ref.read(aiChatUiProvider.notifier).toggleSidebar(),
  onNavigateToChapters: () => context.go('/novel/$novelId'),
  onNavigateToCharacters: () => context.go('/novel/$novelId/characters'),
  onNavigateToScenes: () => context.go('/novel/$novelId/scenes'),
  onNavigateToSummaries: () => context.go('/novel/$novelId/summary'),
  onNavigateToSettings: () => context.go('/settings'),
  child: Drawer(
    child: YourSidebarContent(),
  ),
)
```

## Best Practices

1. **Always provide tooltips** for icon buttons with keyboard shortcuts
2. **Use wrapper widgets** for standard screens to reduce code duplication
3. **Test on multiple platforms** to ensure shortcuts work correctly
4. **Document shortcuts** in your screen's help section
5. **Keep actions simple** - shortcut handlers should be fast and predictable
6. **Handle edge cases** - what if a shortcut can't be executed?
7. **Respect existing shortcuts** - don't override browser/system shortcuts

## Testing

Test keyboard shortcuts by:

1. Running on multiple platforms (macOS, Windows, Linux, Web)
2. Testing with physical keyboards (not just virtual keyboards)
3. Testing in different contexts (dialogs, nested widgets)
4. Verifying shortcuts don't conflict with browser/system shortcuts
5. Testing accessibility with screen readers

## Future Enhancements

Consider adding:

1. **Customizable shortcuts** - Allow users to remap shortcuts
2. **Conflict detection** - Warn when shortcuts conflict
3. **Visual indicators** - Show shortcut keys in UI (e.g., next to menu items)
4. **Context-aware shortcuts** - Different shortcuts based on current selection
5. **Chord shortcuts** - Multi-key sequences (e.g., "Ctrl+K, Ctrl+S")
6. **Mouse shortcuts** - Right-click context menu shortcuts
