import 'dart:convert';

import 'package:flutter/material.dart';

List<Map<String, dynamic>> parseAdminLogs(String logsString) {
  final lines = logsString.split('\n');
  final parsedLogs = <Map<String, dynamic>>[];

  for (final line in lines) {
    if (line.trim().isEmpty) continue;

    try {
      final json = jsonDecode(line) as Map<String, dynamic>;
      parsedLogs.add(json);
    } catch (_) {
      parsedLogs.add({'raw': line, 'level': 'INFO', 'message': line});
    }
  }

  return parsedLogs;
}

Color getAdminLogLevelColor(BuildContext context, String level) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  switch (level.toUpperCase()) {
    case 'ERROR':
    case 'CRITICAL':
      return isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error;
    case 'WARNING':
      return isDark ? const Color(0xFFFFD8A8) : const Color(0xFF9A5200);
    case 'INFO':
      return isDark ? const Color(0xFF9CB9FF) : theme.colorScheme.primary;
    case 'DEBUG':
      return isDark
          ? const Color(0xFFCAC4D0)
          : theme.colorScheme.onSurfaceVariant;
    default:
      return theme.colorScheme.onSurface;
  }
}

Color getAdminLogLevelBackgroundColor(BuildContext context, String level) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  switch (level.toUpperCase()) {
    case 'ERROR':
    case 'CRITICAL':
      return isDark
          ? const Color(0xFF5C1D1D).withValues(alpha: 0.3)
          : theme.colorScheme.errorContainer;
    case 'WARNING':
      return isDark
          ? const Color(0xFF5C3800).withValues(alpha: 0.3)
          : const Color(0xFFFFE8CC);
    case 'INFO':
      return isDark
          ? const Color(0xFF1A2F5C).withValues(alpha: 0.3)
          : theme.colorScheme.primaryContainer;
    case 'DEBUG':
      return isDark
          ? const Color(0xFF3F3F46).withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest;
    default:
      return theme.colorScheme.surface;
  }
}
