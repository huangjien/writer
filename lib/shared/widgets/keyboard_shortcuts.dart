import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Central definition of all keyboard shortcuts for the application
/// This file contains Intent classes and shortcut mappings organized by scope

// ============================================================================
// Global Shortcuts
// ============================================================================

class NavigateHomeIntent extends Intent {
  const NavigateHomeIntent();
}

class NavigateSettingsIntent extends Intent {
  const NavigateSettingsIntent();
}

class ShowShortcutsHelpIntent extends Intent {
  const ShowShortcutsHelpIntent();
}

class QuickSearchIntent extends Intent {
  const QuickSearchIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}

class NavigateBackIntent extends Intent {
  const NavigateBackIntent();
}

class NavigateForwardIntent extends Intent {
  const NavigateForwardIntent();
}

class ForceRefreshIntent extends Intent {
  const ForceRefreshIntent();
}

// ============================================================================
// Library Shortcuts
// ============================================================================

class CreateNovelIntent extends Intent {
  const CreateNovelIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class OpenSelectedNovelIntent extends Intent {
  const OpenSelectedNovelIntent();
}

class DeleteNovelIntent extends Intent {
  const DeleteNovelIntent();
}

// ============================================================================
// Chapter List Shortcuts
// ============================================================================

class CreateChapterIntent extends Intent {
  const CreateChapterIntent();
}

class RefreshChaptersIntent extends Intent {
  const RefreshChaptersIntent();
}

class DuplicateChapterIntent extends Intent {
  const DuplicateChapterIntent();
}

class DeleteChapterIntent extends Intent {
  const DeleteChapterIntent();
}

// ============================================================================
// Editor Shortcuts
// ============================================================================

class SaveIntent extends Intent {
  const SaveIntent();
}

class SaveAndCloseIntent extends Intent {
  const SaveAndCloseIntent();
}

class CloseWithoutSavingIntent extends Intent {
  const CloseWithoutSavingIntent();
}

class BoldIntent extends Intent {
  const BoldIntent();
}

class ItalicIntent extends Intent {
  const ItalicIntent();
}

class UnderlineIntent extends Intent {
  const UnderlineIntent();
}

class InsertLinkIntent extends Intent {
  const InsertLinkIntent();
}

class InsertCodeBlockIntent extends Intent {
  const InsertCodeBlockIntent();
}

class Heading1Intent extends Intent {
  const Heading1Intent();
}

class Heading2Intent extends Intent {
  const Heading2Intent();
}

class Heading3Intent extends Intent {
  const Heading3Intent();
}

class ParagraphIntent extends Intent {
  const ParagraphIntent();
}

// ============================================================================
// Reader Shortcuts
// ============================================================================

class ToggleTTSIntent extends Intent {
  const ToggleTTSIntent();
}

class PreviousChapterIntent extends Intent {
  const PreviousChapterIntent();
}

class NextChapterIntent extends Intent {
  const NextChapterIntent();
}

class IncreaseSpeechRateIntent extends Intent {
  const IncreaseSpeechRateIntent();
}

class DecreaseSpeechRateIntent extends Intent {
  const DecreaseSpeechRateIntent();
}

class ChangeVoiceIntent extends Intent {
  const ChangeVoiceIntent();
}

class MuteUnmuteIntent extends Intent {
  const MuteUnmuteIntent();
}

class EnterFullscreenIntent extends Intent {
  const EnterFullscreenIntent();
}

// ============================================================================
// Settings Shortcuts
// ============================================================================

class FocusAppSettingsIntent extends Intent {
  const FocusAppSettingsIntent();
}

class FocusColorThemeIntent extends Intent {
  const FocusColorThemeIntent();
}

class FocusTypographyIntent extends Intent {
  const FocusTypographyIntent();
}

class FocusPerformanceIntent extends Intent {
  const FocusPerformanceIntent();
}

class FocusTTSSettingsIntent extends Intent {
  const FocusTTSSettingsIntent();
}

// ============================================================================
// Sidebar Shortcuts
// ============================================================================

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class NavigateToChaptersIntent extends Intent {
  const NavigateToChaptersIntent();
}

class NavigateToCharactersIntent extends Intent {
  const NavigateToCharactersIntent();
}

class NavigateToScenesIntent extends Intent {
  const NavigateToScenesIntent();
}

class NavigateToSummariesIntent extends Intent {
  const NavigateToSummariesIntent();
}

// ============================================================================
// Admin Shortcuts
// ============================================================================

class OpenUserManagementIntent extends Intent {
  const OpenUserManagementIntent();
}

class OpenAdminLogsIntent extends Intent {
  const OpenAdminLogsIntent();
}

class ToggleAdminModeIntent extends Intent {
  const ToggleAdminModeIntent();
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Returns the platform-specific modifier key label
String get modifierKeyLabel => kIsWeb
    ? 'Ctrl'
    : (defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl');

/// Returns a formatted shortcut string for display in tooltips
/// Example: getShortcutLabel('S') returns '⌘+S' on Mac, 'Ctrl+S' on Windows/Linux
String getShortcutLabel(String key, {bool useMeta = true}) {
  final modifier = useMeta ? modifierKeyLabel : '';
  return modifier.isEmpty ? key : '$modifier+$key';
}

/// Returns true if running on macOS or using Ctrl on other platforms
bool get usesMeta => defaultTargetPlatform == TargetPlatform.macOS;

/// Global shortcuts map - available throughout the app
Map<ShortcutActivator, Intent> getGlobalShortcuts() {
  return <ShortcutActivator, Intent>{
    // Home navigation
    SingleActivator(LogicalKeyboardKey.keyH, meta: usesMeta):
        const NavigateHomeIntent(),
    SingleActivator(LogicalKeyboardKey.keyH, control: !usesMeta):
        const NavigateHomeIntent(),

    // Settings
    SingleActivator(LogicalKeyboardKey.comma, meta: usesMeta):
        const NavigateSettingsIntent(),
    SingleActivator(LogicalKeyboardKey.comma, control: !usesMeta):
        const NavigateSettingsIntent(),

    // Help
    SingleActivator(LogicalKeyboardKey.slash, meta: usesMeta):
        const ShowShortcutsHelpIntent(),
    SingleActivator(LogicalKeyboardKey.slash, control: !usesMeta):
        const ShowShortcutsHelpIntent(),

    // Quick search
    SingleActivator(LogicalKeyboardKey.keyK, meta: usesMeta):
        const QuickSearchIntent(),
    SingleActivator(LogicalKeyboardKey.keyK, control: !usesMeta):
        const QuickSearchIntent(),

    // Close
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),

    // Navigation
    SingleActivator(LogicalKeyboardKey.bracketLeft, meta: usesMeta):
        const NavigateBackIntent(),
    SingleActivator(LogicalKeyboardKey.bracketLeft, control: !usesMeta):
        const NavigateBackIntent(),
    SingleActivator(LogicalKeyboardKey.bracketRight, meta: usesMeta):
        const NavigateForwardIntent(),
    SingleActivator(LogicalKeyboardKey.bracketRight, control: !usesMeta):
        const NavigateForwardIntent(),

    // Force refresh
    SingleActivator(LogicalKeyboardKey.keyR, shift: true, meta: usesMeta):
        const ForceRefreshIntent(),
    SingleActivator(LogicalKeyboardKey.keyR, shift: true, control: !usesMeta):
        const ForceRefreshIntent(),
  };
}

/// Library-specific shortcuts
Map<ShortcutActivator, Intent> getLibraryShortcuts() {
  return <ShortcutActivator, Intent>{
    // Create new novel
    SingleActivator(LogicalKeyboardKey.keyN, meta: usesMeta):
        const CreateNovelIntent(),
    SingleActivator(LogicalKeyboardKey.keyN, control: !usesMeta):
        const CreateNovelIntent(),

    // Search
    SingleActivator(LogicalKeyboardKey.keyF, meta: usesMeta):
        const FocusSearchIntent(),
    SingleActivator(LogicalKeyboardKey.keyF, control: !usesMeta):
        const FocusSearchIntent(),

    // Open selected (Enter is handled by framework)
    // Delete (handled by framework)
  };
}

/// Chapter list shortcuts
Map<ShortcutActivator, Intent> getChapterListShortcuts() {
  return <ShortcutActivator, Intent>{
    // Create new chapter
    SingleActivator(LogicalKeyboardKey.keyN, meta: usesMeta):
        const CreateChapterIntent(),
    SingleActivator(LogicalKeyboardKey.keyN, control: !usesMeta):
        const CreateChapterIntent(),

    // Refresh
    SingleActivator(LogicalKeyboardKey.keyR, meta: usesMeta):
        const RefreshChaptersIntent(),
    SingleActivator(LogicalKeyboardKey.keyR, control: !usesMeta):
        const RefreshChaptersIntent(),

    // Duplicate
    SingleActivator(LogicalKeyboardKey.keyD, meta: usesMeta):
        const DuplicateChapterIntent(),
    SingleActivator(LogicalKeyboardKey.keyD, control: !usesMeta):
        const DuplicateChapterIntent(),
  };
}

/// Editor shortcuts
Map<ShortcutActivator, Intent> getEditorShortcuts() {
  return <ShortcutActivator, Intent>{
    // Save
    SingleActivator(LogicalKeyboardKey.keyS, meta: usesMeta):
        const SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyS, control: !usesMeta):
        const SaveIntent(),

    // Save and close
    SingleActivator(LogicalKeyboardKey.enter, meta: usesMeta):
        const SaveAndCloseIntent(),
    SingleActivator(LogicalKeyboardKey.enter, control: !usesMeta):
        const SaveAndCloseIntent(),

    // Close without saving
    SingleActivator(LogicalKeyboardKey.keyW, meta: usesMeta):
        const CloseWithoutSavingIntent(),
    SingleActivator(LogicalKeyboardKey.keyW, control: !usesMeta):
        const CloseWithoutSavingIntent(),

    // Formatting
    SingleActivator(LogicalKeyboardKey.keyB, meta: usesMeta):
        const BoldIntent(),
    SingleActivator(LogicalKeyboardKey.keyB, control: !usesMeta):
        const BoldIntent(),

    SingleActivator(LogicalKeyboardKey.keyI, meta: usesMeta):
        const ItalicIntent(),
    SingleActivator(LogicalKeyboardKey.keyI, control: !usesMeta):
        const ItalicIntent(),

    SingleActivator(LogicalKeyboardKey.keyU, meta: usesMeta):
        const UnderlineIntent(),
    SingleActivator(LogicalKeyboardKey.keyU, control: !usesMeta):
        const UnderlineIntent(),

    // Link
    SingleActivator(LogicalKeyboardKey.keyK, meta: usesMeta):
        const InsertLinkIntent(),
    SingleActivator(LogicalKeyboardKey.keyK, control: !usesMeta):
        const InsertLinkIntent(),

    // Code block
    SingleActivator(LogicalKeyboardKey.keyK, shift: true, meta: usesMeta):
        const InsertCodeBlockIntent(),
    SingleActivator(LogicalKeyboardKey.keyK, shift: true, control: !usesMeta):
        const InsertCodeBlockIntent(),

    // Headings
    SingleActivator(LogicalKeyboardKey.digit1, meta: usesMeta):
        const Heading1Intent(),
    SingleActivator(LogicalKeyboardKey.digit1, control: !usesMeta):
        const Heading1Intent(),

    SingleActivator(LogicalKeyboardKey.digit2, meta: usesMeta):
        const Heading2Intent(),
    SingleActivator(LogicalKeyboardKey.digit2, control: !usesMeta):
        const Heading2Intent(),

    SingleActivator(LogicalKeyboardKey.digit3, meta: usesMeta):
        const Heading3Intent(),
    SingleActivator(LogicalKeyboardKey.digit3, control: !usesMeta):
        const Heading3Intent(),

    // Paragraph
    SingleActivator(LogicalKeyboardKey.digit0, meta: usesMeta):
        const ParagraphIntent(),
    SingleActivator(LogicalKeyboardKey.digit0, control: !usesMeta):
        const ParagraphIntent(),

    // Escape
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  };
}

/// Reader shortcuts
Map<ShortcutActivator, Intent> getReaderShortcuts() {
  return <ShortcutActivator, Intent>{
    // TTS toggle
    const SingleActivator(LogicalKeyboardKey.space): const ToggleTTSIntent(),

    // Navigation
    SingleActivator(LogicalKeyboardKey.arrowLeft, meta: usesMeta):
        const PreviousChapterIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, control: !usesMeta):
        const PreviousChapterIntent(),

    SingleActivator(LogicalKeyboardKey.arrowRight, meta: usesMeta):
        const NextChapterIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, control: !usesMeta):
        const NextChapterIntent(),

    // TTS controls
    SingleActivator(LogicalKeyboardKey.keyR, meta: usesMeta):
        const IncreaseSpeechRateIntent(),
    SingleActivator(LogicalKeyboardKey.keyR, control: !usesMeta):
        const IncreaseSpeechRateIntent(),

    SingleActivator(LogicalKeyboardKey.keyR, shift: true, meta: usesMeta):
        const DecreaseSpeechRateIntent(),
    SingleActivator(LogicalKeyboardKey.keyR, shift: true, control: !usesMeta):
        const DecreaseSpeechRateIntent(),

    SingleActivator(LogicalKeyboardKey.keyV, meta: usesMeta):
        const ChangeVoiceIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, control: !usesMeta):
        const ChangeVoiceIntent(),

    SingleActivator(LogicalKeyboardKey.keyM, meta: usesMeta):
        const MuteUnmuteIntent(),
    SingleActivator(LogicalKeyboardKey.keyM, control: !usesMeta):
        const MuteUnmuteIntent(),

    // Fullscreen
    const SingleActivator(LogicalKeyboardKey.f1): const EnterFullscreenIntent(),

    // Escape
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  };
}

/// Settings shortcuts
Map<ShortcutActivator, Intent> getSettingsShortcuts() {
  return <ShortcutActivator, Intent>{
    // Quick access to sections
    SingleActivator(LogicalKeyboardKey.digit1, meta: usesMeta):
        const FocusAppSettingsIntent(),
    SingleActivator(LogicalKeyboardKey.digit1, control: !usesMeta):
        const FocusAppSettingsIntent(),

    SingleActivator(LogicalKeyboardKey.digit2, meta: usesMeta):
        const FocusColorThemeIntent(),
    SingleActivator(LogicalKeyboardKey.digit2, control: !usesMeta):
        const FocusColorThemeIntent(),

    SingleActivator(LogicalKeyboardKey.digit3, meta: usesMeta):
        const FocusTypographyIntent(),
    SingleActivator(LogicalKeyboardKey.digit3, control: !usesMeta):
        const FocusTypographyIntent(),

    SingleActivator(LogicalKeyboardKey.digit4, meta: usesMeta):
        const FocusPerformanceIntent(),
    SingleActivator(LogicalKeyboardKey.digit4, control: !usesMeta):
        const FocusPerformanceIntent(),

    SingleActivator(LogicalKeyboardKey.digit5, meta: usesMeta):
        const FocusTTSSettingsIntent(),
    SingleActivator(LogicalKeyboardKey.digit5, control: !usesMeta):
        const FocusTTSSettingsIntent(),

    // Escape
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  };
}

/// Sidebar shortcuts
Map<ShortcutActivator, Intent> getSidebarShortcuts() {
  return <ShortcutActivator, Intent>{
    // Toggle sidebar
    SingleActivator(LogicalKeyboardKey.keyD, meta: usesMeta):
        const ToggleSidebarIntent(),
    SingleActivator(LogicalKeyboardKey.keyD, control: !usesMeta):
        const ToggleSidebarIntent(),

    // Quick navigation
    SingleActivator(LogicalKeyboardKey.digit1, meta: usesMeta):
        const NavigateToChaptersIntent(),
    SingleActivator(LogicalKeyboardKey.digit1, control: !usesMeta):
        const NavigateToChaptersIntent(),

    SingleActivator(LogicalKeyboardKey.digit2, meta: usesMeta):
        const NavigateToCharactersIntent(),
    SingleActivator(LogicalKeyboardKey.digit2, control: !usesMeta):
        const NavigateToCharactersIntent(),

    SingleActivator(LogicalKeyboardKey.digit3, meta: usesMeta):
        const NavigateToScenesIntent(),
    SingleActivator(LogicalKeyboardKey.digit3, control: !usesMeta):
        const NavigateToScenesIntent(),

    SingleActivator(LogicalKeyboardKey.digit4, meta: usesMeta):
        const NavigateToSummariesIntent(),
    SingleActivator(LogicalKeyboardKey.digit4, control: !usesMeta):
        const NavigateToSummariesIntent(),

    // Settings
    SingleActivator(LogicalKeyboardKey.comma, meta: usesMeta):
        const NavigateSettingsIntent(),
    SingleActivator(LogicalKeyboardKey.comma, control: !usesMeta):
        const NavigateSettingsIntent(),

    // Escape
    const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  };
}

/// Admin shortcuts
Map<ShortcutActivator, Intent> getAdminShortcuts() {
  return <ShortcutActivator, Intent>{
    // User management
    SingleActivator(LogicalKeyboardKey.keyU, shift: true, meta: usesMeta):
        const OpenUserManagementIntent(),
    SingleActivator(LogicalKeyboardKey.keyU, shift: true, control: !usesMeta):
        const OpenUserManagementIntent(),

    // Admin logs
    SingleActivator(LogicalKeyboardKey.keyL, shift: true, meta: usesMeta):
        const OpenAdminLogsIntent(),
    SingleActivator(LogicalKeyboardKey.keyL, shift: true, control: !usesMeta):
        const OpenAdminLogsIntent(),

    // Toggle admin mode
    SingleActivator(LogicalKeyboardKey.keyA, shift: true, meta: usesMeta):
        const ToggleAdminModeIntent(),
    SingleActivator(LogicalKeyboardKey.keyA, shift: true, control: !usesMeta):
        const ToggleAdminModeIntent(),
  };
}
