import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/l10n/app_localizations.dart';

import 'admin_log_level_badge.dart';

void showAdminLogDetailDialog(
  BuildContext context, {
  required Map<String, dynamic> log,
  required String level,
  required String timestamp,
  required String logger,
  required String? requestId,
  required String message,
}) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          AdminLogLevelBadge(level: level),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context)!.adminLogsEntry),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timestamp.isNotEmpty)
                  _AdminLogDetailRow(label: 'Timestamp', value: timestamp),
                if (logger.isNotEmpty)
                  _AdminLogDetailRow(label: 'Logger', value: logger),
                if (requestId != null)
                  _AdminLogDetailRow(label: 'Request ID', value: requestId),
                const SizedBox(height: 16),
                Text(
                  'Message:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    message,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Full Data:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    const JsonEncoder.withIndent('  ').convert(log),
                    style:
                        const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ).copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: jsonEncode(log)));
            final l10n = AppLocalizations.of(dialogContext)!;
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(l10n.adminLogsCopiedToClipboard),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: Text(AppLocalizations.of(dialogContext)!.adminLogsCopy),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppLocalizations.of(dialogContext)!.adminLogsClose),
        ),
      ],
    ),
  );
}

class _AdminLogDetailRow extends StatelessWidget {
  const _AdminLogDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
