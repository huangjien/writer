import 'package:flutter/material.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';

/// Helper class for adding keyboard shortcuts to button tooltips
class TooltipWithShortcut {
  /// Returns a tooltip text with shortcut appended
  /// Example: appendShortcut(context, l10n.save, 'S') returns "Save (⌘+S)"
  static String appendShortcut(
    BuildContext context,
    String label,
    String shortcutKey,
  ) {
    final modifier = modifierKeyLabel;
    return '$label ($modifier+$shortcutKey)';
  }

  /// Returns a tooltip text with shortcut key(s) appended
  /// Example: appendShortcutKeys(context, l10n.save, ['⌘', 'S']) returns "Save (⌘+S)"
  static String appendShortcutKeys(
    BuildContext context,
    String label,
    List<String> keys,
  ) {
    return '$label (${keys.join('+')})';
  }

  /// Returns a tooltip text with multi-key combination
  /// Example: appendShortcutCombination(context, l10n.refresh, 'R', shift: true, meta: true)
  /// returns "Refresh (⌘+Shift+R)"
  static String appendShortcutCombination(
    BuildContext context,
    String label,
    String key, {
    bool shift = false,
    bool control = false,
    bool meta = false,
    bool alt = false,
  }) {
    final parts = <String>[];

    if (shift) parts.add('Shift');
    if (control && !usesMeta) parts.add('Ctrl');
    if (alt) parts.add('Alt');
    if (meta && usesMeta) parts.add('⌘');
    parts.add(key);

    return '$label (${parts.join('+')})';
  }

  /// Returns a formatted shortcut for display purposes only (not in tooltip)
  static String formatShortcut(
    String key, {
    bool shift = false,
    bool control = false,
    bool meta = false,
    bool alt = false,
  }) {
    final parts = <String>[];

    if (shift) parts.add('Shift');
    if (control && !usesMeta) parts.add('Ctrl');
    if (alt) parts.add('Alt');
    if (meta && usesMeta) parts.add('⌘');
    parts.add(key);

    return parts.join('+');
  }
}

/// Extension to easily add shortcuts to tooltips
extension TooltipWithShortcutExtension on String {
  /// Append a single key shortcut to this string
  String withShortcut(String key) {
    return '$this ($modifierKeyLabel+$key)';
  }

  /// Append a multi-key combination to this string
  String withShortcutCombination(
    String key, {
    bool shift = false,
    bool control = false,
    bool meta = false,
    bool alt = false,
  }) {
    final parts = <String>[];

    if (shift) parts.add('Shift');
    if (control && !usesMeta) parts.add('Ctrl');
    if (alt) parts.add('Alt');
    if (meta && usesMeta) parts.add('⌘');
    parts.add(key);

    return '$this (${parts.join('+')})';
  }
}
