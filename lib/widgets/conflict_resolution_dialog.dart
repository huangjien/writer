// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merge_result.dart';
import '../shared/widgets/app_buttons.dart';
import '../shared/widgets/app_dialog.dart';
import '../theme/design_tokens.dart';

/// Dialog for resolving merge conflicts when sync detects conflicting changes
/// Allows user to choose between local, remote, or merged versions
class ConflictResolutionDialog extends ConsumerStatefulWidget {
  final MergeResult conflict;
  final String chapterTitle;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    required this.chapterTitle,
  });

  @override
  ConsumerState<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();

  /// Show the dialog and return the selected resolution
  static Future<ConflictResolution?> show(
    BuildContext context, {
    required MergeResult conflict,
    required String chapterTitle,
  }) {
    return showDialog<ConflictResolution>(
      context: context,
      builder: (context) => ConflictResolutionDialog(
        conflict: conflict,
        chapterTitle: chapterTitle,
      ),
    );
  }
}

class _ConflictResolutionDialogState
    extends ConsumerState<ConflictResolutionDialog> {
  ConflictResolution _selectedResolution = ConflictResolution.keepLocal;

  @override
  Widget build(BuildContext context) {
    final hasConflicts = widget.conflict.hasConflicts;
    final canAutoMerge = widget.conflict.success && !hasConflicts;
    final theme = Theme.of(context);
    final statusColor = hasConflicts
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return AppDialog(
      title: 'Sync Conflict',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasConflicts ? Icons.warning_amber_rounded : Icons.info_outline,
                color: statusColor,
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Text(
                  hasConflicts
                      ? 'Changes in "${widget.chapterTitle}" conflict with server version.'
                      : 'Changes in "${widget.chapterTitle}" can be automatically merged.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),
          if (hasConflicts && widget.conflict.conflicts.isNotEmpty)
            _buildConflictList(context),
          if (canAutoMerge) _buildAutoMergePreview(context),
          const SizedBox(height: Spacing.m),
          _buildResolutionOptions(context, canAutoMerge),
        ],
      ),
      actions: [
        AppButtons.text(
          onPressed: () => Navigator.pop(context, null),
          label: 'Cancel',
        ),
        AppButtons.primary(
          onPressed: () => Navigator.pop(context, _selectedResolution),
          label: 'Apply',
        ),
      ],
    );
  }

  Widget _buildConflictList(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.conflict.conflicts.length,
        itemBuilder: (context, index) {
          final conflict = widget.conflict.conflicts[index];
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            title: Text(
              'Conflict at lines ${conflict.startLine}-${conflict.endLine}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVersionHeader(
                      'Your version (Local)',
                      theme.colorScheme.primary,
                      conflict.localContent,
                    ),
                    const SizedBox(height: 8),
                    _buildVersionHeader(
                      'Server version (Remote)',
                      theme.colorScheme.tertiary,
                      conflict.remoteContent,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAutoMergePreview(BuildContext context) {
    final theme = Theme.of(context);
    final okColor = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: okColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.s),
        border: Border.all(color: okColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: okColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Auto-merge successful',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.s),
            ),
            child: Text(
              widget.conflict.mergedContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionHeader(String title, Color color, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            content ?? '(empty)',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionOptions(BuildContext context, bool canAutoMerge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you like to resolve this?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        RadioListTile<ConflictResolution>(
          title: const Text('Keep my version'),
          subtitle: const Text('Discard server changes'),
          value: ConflictResolution.keepLocal,
          groupValue: _selectedResolution,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedResolution = value);
            }
          },
        ),
        RadioListTile<ConflictResolution>(
          title: const Text('Use server version'),
          subtitle: const Text('Discard my changes'),
          value: ConflictResolution.keepRemote,
          groupValue: _selectedResolution,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedResolution = value);
            }
          },
        ),
        if (canAutoMerge)
          RadioListTile<ConflictResolution>(
            title: const Text('Use merged version'),
            subtitle: const Text('Combine changes intelligently'),
            value: ConflictResolution.merge,
            groupValue: _selectedResolution,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedResolution = value);
              }
            },
          ),
      ],
    );
  }
}

/// Resolution options for merge conflicts
enum ConflictResolution { keepLocal, keepRemote, merge }
