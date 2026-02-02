import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';

void main() {
  group('KeyboardShortcuts', () {
    group('Intent Classes', () {
      test('NavigateHomeIntent can be created', () {
        final intent = const NavigateHomeIntent();
        expect(intent, isNotNull);
      });

      test('NavigateSettingsIntent can be created', () {
        final intent = const NavigateSettingsIntent();
        expect(intent, isNotNull);
      });

      test('ShowShortcutsHelpIntent can be created', () {
        final intent = const ShowShortcutsHelpIntent();
        expect(intent, isNotNull);
      });

      test('QuickSearchIntent can be created', () {
        final intent = const QuickSearchIntent();
        expect(intent, isNotNull);
      });

      test('CloseIntent can be created', () {
        final intent = const CloseIntent();
        expect(intent, isNotNull);
      });

      test('NavigateBackIntent can be created', () {
        final intent = const NavigateBackIntent();
        expect(intent, isNotNull);
      });

      test('NavigateForwardIntent can be created', () {
        final intent = const NavigateForwardIntent();
        expect(intent, isNotNull);
      });

      test('ForceRefreshIntent can be created', () {
        final intent = const ForceRefreshIntent();
        expect(intent, isNotNull);
      });

      test('CreateNovelIntent can be created', () {
        final intent = const CreateNovelIntent();
        expect(intent, isNotNull);
      });

      test('FocusSearchIntent can be created', () {
        final intent = const FocusSearchIntent();
        expect(intent, isNotNull);
      });

      test('OpenSelectedNovelIntent can be created', () {
        final intent = const OpenSelectedNovelIntent();
        expect(intent, isNotNull);
      });

      test('DeleteNovelIntent can be created', () {
        final intent = const DeleteNovelIntent();
        expect(intent, isNotNull);
      });

      test('CreateChapterIntent can be created', () {
        final intent = const CreateChapterIntent();
        expect(intent, isNotNull);
      });

      test('RefreshChaptersIntent can be created', () {
        final intent = const RefreshChaptersIntent();
        expect(intent, isNotNull);
      });

      test('DuplicateChapterIntent can be created', () {
        final intent = const DuplicateChapterIntent();
        expect(intent, isNotNull);
      });

      test('DeleteChapterIntent can be created', () {
        final intent = const DeleteChapterIntent();
        expect(intent, isNotNull);
      });

      test('SaveIntent can be created', () {
        final intent = const SaveIntent();
        expect(intent, isNotNull);
      });

      test('SaveAndCloseIntent can be created', () {
        final intent = const SaveAndCloseIntent();
        expect(intent, isNotNull);
      });

      test('CloseWithoutSavingIntent can be created', () {
        final intent = const CloseWithoutSavingIntent();
        expect(intent, isNotNull);
      });

      test('BoldIntent can be created', () {
        final intent = const BoldIntent();
        expect(intent, isNotNull);
      });

      test('ItalicIntent can be created', () {
        final intent = const ItalicIntent();
        expect(intent, isNotNull);
      });

      test('UnderlineIntent can be created', () {
        final intent = const UnderlineIntent();
        expect(intent, isNotNull);
      });

      test('InsertLinkIntent can be created', () {
        final intent = const InsertLinkIntent();
        expect(intent, isNotNull);
      });

      test('InsertCodeBlockIntent can be created', () {
        final intent = const InsertCodeBlockIntent();
        expect(intent, isNotNull);
      });

      test('Heading1Intent can be created', () {
        final intent = const Heading1Intent();
        expect(intent, isNotNull);
      });

      test('Heading2Intent can be created', () {
        final intent = const Heading2Intent();
        expect(intent, isNotNull);
      });

      test('Heading3Intent can be created', () {
        final intent = const Heading3Intent();
        expect(intent, isNotNull);
      });

      test('ParagraphIntent can be created', () {
        final intent = const ParagraphIntent();
        expect(intent, isNotNull);
      });

      test('ToggleTTSIntent can be created', () {
        final intent = const ToggleTTSIntent();
        expect(intent, isNotNull);
      });

      test('PreviousChapterIntent can be created', () {
        final intent = const PreviousChapterIntent();
        expect(intent, isNotNull);
      });

      test('NextChapterIntent can be created', () {
        final intent = const NextChapterIntent();
        expect(intent, isNotNull);
      });

      test('IncreaseSpeechRateIntent can be created', () {
        final intent = const IncreaseSpeechRateIntent();
        expect(intent, isNotNull);
      });

      test('DecreaseSpeechRateIntent can be created', () {
        final intent = const DecreaseSpeechRateIntent();
        expect(intent, isNotNull);
      });

      test('ChangeVoiceIntent can be created', () {
        final intent = const ChangeVoiceIntent();
        expect(intent, isNotNull);
      });

      test('MuteUnmuteIntent can be created', () {
        final intent = const MuteUnmuteIntent();
        expect(intent, isNotNull);
      });

      test('EnterFullscreenIntent can be created', () {
        final intent = const EnterFullscreenIntent();
        expect(intent, isNotNull);
      });

      test('FocusAppSettingsIntent can be created', () {
        final intent = const FocusAppSettingsIntent();
        expect(intent, isNotNull);
      });

      test('FocusColorThemeIntent can be created', () {
        final intent = const FocusColorThemeIntent();
        expect(intent, isNotNull);
      });

      test('FocusTypographyIntent can be created', () {
        final intent = const FocusTypographyIntent();
        expect(intent, isNotNull);
      });

      test('FocusPerformanceIntent can be created', () {
        final intent = const FocusPerformanceIntent();
        expect(intent, isNotNull);
      });

      test('FocusTTSSettingsIntent can be created', () {
        final intent = const FocusTTSSettingsIntent();
        expect(intent, isNotNull);
      });

      test('ToggleSidebarIntent can be created', () {
        final intent = const ToggleSidebarIntent();
        expect(intent, isNotNull);
      });

      test('NavigateToChaptersIntent can be created', () {
        final intent = const NavigateToChaptersIntent();
        expect(intent, isNotNull);
      });

      test('NavigateToCharactersIntent can be created', () {
        final intent = const NavigateToCharactersIntent();
        expect(intent, isNotNull);
      });

      test('NavigateToScenesIntent can be created', () {
        final intent = const NavigateToScenesIntent();
        expect(intent, isNotNull);
      });

      test('NavigateToSummariesIntent can be created', () {
        final intent = const NavigateToSummariesIntent();
        expect(intent, isNotNull);
      });

      test('OpenUserManagementIntent can be created', () {
        final intent = const OpenUserManagementIntent();
        expect(intent, isNotNull);
      });

      test('OpenAdminLogsIntent can be created', () {
        final intent = const OpenAdminLogsIntent();
        expect(intent, isNotNull);
      });

      test('ToggleAdminModeIntent can be created', () {
        final intent = const ToggleAdminModeIntent();
        expect(intent, isNotNull);
      });
    });

    group('Helper Functions', () {
      test('modifierKeyLabel returns Ctrl for web', () {
        final value = kIsWeb;
        if (value) {
          expect(modifierKeyLabel, 'Ctrl');
        }
      });

      test('modifierKeyLabel returns value for platforms', () {
        final label = modifierKeyLabel;
        expect(label, isA<String>());
        expect(label, isNotEmpty);
      });

      test('getShortcutLabel formats correctly', () {
        final result = getShortcutLabel('S');
        expect(result, isNotEmpty);
        expect(result, contains('S'));
      });

      test('getShortcutLabel with useMeta false', () {
        final result = getShortcutLabel('S', useMeta: false);
        expect(result, 'S');
      });

      test('getShortcutLabel with useMeta true', () {
        final result = getShortcutLabel('S', useMeta: true);
        expect(result, contains('+'));
        expect(result, contains('S'));
      });

      test('usesMeta returns bool', () {
        final result = usesMeta;
        expect(result, isA<bool>());
      });
    });

    group('Shortcut Maps', () {
      test('getGlobalShortcuts returns map', () {
        final shortcuts = getGlobalShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getGlobalShortcuts contains NavigateHomeIntent', () {
        final shortcuts = getGlobalShortcuts();
        final hasHomeShortcut = shortcuts.values.any(
          (intent) => intent is NavigateHomeIntent,
        );
        expect(hasHomeShortcut, isTrue);
      });

      test('getLibraryShortcuts returns map', () {
        final shortcuts = getLibraryShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getLibraryShortcuts contains CreateNovelIntent', () {
        final shortcuts = getLibraryShortcuts();
        final hasCreateShortcut = shortcuts.values.any(
          (intent) => intent is CreateNovelIntent,
        );
        expect(hasCreateShortcut, isTrue);
      });

      test('getChapterListShortcuts returns map', () {
        final shortcuts = getChapterListShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getChapterListShortcuts contains CreateChapterIntent', () {
        final shortcuts = getChapterListShortcuts();
        final hasCreateShortcut = shortcuts.values.any(
          (intent) => intent is CreateChapterIntent,
        );
        expect(hasCreateShortcut, isTrue);
      });

      test('getEditorShortcuts returns map', () {
        final shortcuts = getEditorShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getEditorShortcuts contains SaveIntent', () {
        final shortcuts = getEditorShortcuts();
        final hasSaveShortcut = shortcuts.values.any(
          (intent) => intent is SaveIntent,
        );
        expect(hasSaveShortcut, isTrue);
      });

      test('getEditorShortcuts contains formatting intents', () {
        final shortcuts = getEditorShortcuts();
        final hasBoldShortcut = shortcuts.values.any(
          (intent) => intent is BoldIntent,
        );
        final hasItalicShortcut = shortcuts.values.any(
          (intent) => intent is ItalicIntent,
        );
        expect(hasBoldShortcut, isTrue);
        expect(hasItalicShortcut, isTrue);
      });

      test('getReaderShortcuts returns map', () {
        final shortcuts = getReaderShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getReaderShortcuts contains ToggleTTSIntent', () {
        final shortcuts = getReaderShortcuts();
        final hasToggleShortcut = shortcuts.values.any(
          (intent) => intent is ToggleTTSIntent,
        );
        expect(hasToggleShortcut, isTrue);
      });

      test('getSettingsShortcuts returns map', () {
        final shortcuts = getSettingsShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getSettingsShortcuts contains FocusAppSettingsIntent', () {
        final shortcuts = getSettingsShortcuts();
        final hasFocusShortcut = shortcuts.values.any(
          (intent) => intent is FocusAppSettingsIntent,
        );
        expect(hasFocusShortcut, isTrue);
      });

      test('getSidebarShortcuts returns map', () {
        final shortcuts = getSidebarShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getSidebarShortcuts contains ToggleSidebarIntent', () {
        final shortcuts = getSidebarShortcuts();
        final hasToggleShortcut = shortcuts.values.any(
          (intent) => intent is ToggleSidebarIntent,
        );
        expect(hasToggleShortcut, isTrue);
      });

      test('getAdminShortcuts returns map', () {
        final shortcuts = getAdminShortcuts();
        expect(shortcuts, isA<Map>());
        expect(shortcuts, isNotEmpty);
      });

      test('getAdminShortcuts contains OpenUserManagementIntent', () {
        final shortcuts = getAdminShortcuts();
        final hasUserShortcut = shortcuts.values.any(
          (intent) => intent is OpenUserManagementIntent,
        );
        expect(hasUserShortcut, isTrue);
      });
    });
  });
}
