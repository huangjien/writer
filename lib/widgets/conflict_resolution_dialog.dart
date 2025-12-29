// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merge_result.dart';

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

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            hasConflicts ? Icons.warning_amber_rounded : Icons.info_outline,
            color: hasConflicts ? Colors.orange.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Sync Conflict', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasConflicts
                  ? 'Changes in "${widget.chapterTitle}" conflict with server version.'
                  : 'Changes in "${widget.chapterTitle}" can be automatically merged.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (hasConflicts && widget.conflict.conflicts.isNotEmpty)
              _buildConflictList(context),
            if (canAutoMerge) _buildAutoMergePreview(context),
            const SizedBox(height: 16),
            _buildResolutionOptions(context, canAutoMerge),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedResolution),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildConflictList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
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
                      Colors.blue,
                      conflict.localContent,
                    ),
                    const SizedBox(height: 8),
                    _buildVersionHeader(
                      'Server version (Remote)',
                      Colors.orange,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Auto-merge successful',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Preview:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
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
