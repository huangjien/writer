# Keyboard Shortcuts Integration - Remaining Tasks

## Current Status

### ✅ Completed Infrastructure
- All Intent classes created (40+ intents)
- Shortcut mappings defined for all scopes
- Platform-aware helpers (Mac ⌘ vs Windows/Linux Ctrl)
- Keyboard shortcuts dialog (desktop + mobile)
- Quick search modal implementation
- Wrapper widgets for all screen types
- Tooltip helpers for easy integration
- Localization strings added and generated
- Implementation documentation written

### ⏳ Tasks Remaining

1. **Integrate Wrapper Widgets into Existing Screens**

   The wrapper widgets have been created but not yet applied to actual screens:

   - **Settings Screen** (`lib/features/settings/settings_screen.dart`)
     - Add: `import '../../shared/widgets/global_shortcuts_wrapper.dart';`
     - Add: `import '../../shared/widgets/keyboard_shortcuts_dialog.dart';`
     - Add: `import '../../shared/widgets/tooltip_with_shortcut.dart';`
     - Wrap Scaffold with `SettingsShortcutsWrapper`:
       ```dart
       return SettingsShortcutsWrapper(
         onFocusAppSettings: () => _scrollToSection('app'),
         onFocusColorTheme: () => _scrollToSection('theme'),
         onFocusTypography: () => _scrollToSection('typography'),
         onFocusPerformance: () => _scrollToSection('performance'),
         onFocusTTSSettings: () => _scrollToSection('tts'),
         child: Scaffold(...),
       );
       ```
     - Update "Style Guide" to use `l10n.styleGuide` (already done!)
     - Add help button with shortcut to AppBar actions

   - **Chapter Editor** (`lib/features/editor/mobile_editor_screen.dart`)
     - Add imports for shortcuts
     - Wrap with `EditorShortcutsWrapper`
     - Connect save, formatting actions
     - Update tooltips to show shortcuts

   - **Chapter Reader** (`lib/features/reader/reader_screen.dart`)
     - Already has `ReaderShortcutsWrapper` - just verify it's complete ✅
     - Add help button with shortcut

   - **Sidebar** (`lib/widgets/side_bar.dart`)
     - Add toggle sidebar action
     - Connect to keyboard shortcuts

   - **Library Screen** (`lib/features/library/library_screen.dart`)
     - Simplify: Just add imports and use the existing callbacks
     - The callback parameters in wrapper should be connected to existing methods
     - Remove the complex scaffold wrapping approach that had parsing issues

   - **Admin Panel** (if exists)
     - Apply admin-specific shortcuts
     - Add admin menu items

2. **Quick Search Enhancement**

   Current implementation in `lib/shared/widgets/quick_search_modal.dart` is basic. Enhancements:

   - Add more search types beyond novels:
     - Settings options (app settings sections)
     - Menu items (accessible via quick search)
     - Characters, Scenes, Summaries (content types)
   
   - Add focus management:
     - Focus search bar when modal opens
     - Navigate between results with keyboard
   
   - Add better filtering:
     - Filter by content type (all, novels, settings, characters, etc.)
   
   - Improve accessibility:
     - ARIA labels
     - Screen reader announcements

3. **Documentation Updates**

   - Add screen-by-screen integration examples to implementation guide
   - Create migration checklist
   - Document best practices for adding shortcuts to existing screens

## Integration Order (Recommended)

1. Start with simpler screens:
   - Library Screen (just imports, no wrapper complexity)
   - Settings Screen (single callback connections)
   - Sidebar (add toggle action only)

2. Then move to more complex screens:
   - Chapter Editor (needs EditorShortcutsWrapper + callbacks)
   - Quick Search enhancement

## Notes

- **Library Screen Integration Issue**: The previous attempt to wrap the entire Scaffold caused structure problems. 
  Simpler approach: Just import shortcuts and connect to existing methods without wrapping.
- **Settings Screen**: The wrapper callbacks should map to existing `_scrollToSection()` method calls.
- **Editor Screen**: Will need to connect formatting toolbar buttons to shortcuts.

## Testing Checklist

After integration:
- [ ] Test shortcuts on macOS
- [ ] Test shortcuts on Windows/Linux
- [ ] Test shortcuts on Web
- [ ] Test shortcuts with different auth states (guest, logged in, admin)
- [ ] Verify no conflicts with browser/system shortcuts
- [ ] Test accessibility with screen reader
- [ ] Run `flutter analyze` - should have zero errors

## Questions

1. Should Quick Search search settings options?
2. Should Quick Search search menu items?
3. Should shortcuts be customizable (user settings to remap)?
4. Should we add chord shortcuts (multi-key sequences)?
5. Any other screens that need shortcut integration?
