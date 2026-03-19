import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/models/sync_state.dart';

/// Visual indicator showing the current sync state
/// Displays in the app bar or as a standalone widget
class SyncStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = false,
    this.iconSize = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateValueProvider);
    final hasPending = ref.watch(hasPendingOperationsProvider);
    final label = _labelText(context, syncState, hasPending);

    return Padding(
      padding: padding,
      child: Semantics(
        label: label,
        liveRegion: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(syncState),
            if (showLabel) ...[
              const SizedBox(width: 8),
              _buildLabel(context, syncState, hasPending),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SyncState syncState) {
    final hasConflict =
        syncState.status == SyncStatus.error &&
        (syncState.errorMessage ?? '').toLowerCase().contains('conflict');
    if (hasConflict) {
      return Icon(
        Icons.warning_amber_rounded,
        size: iconSize,
        color: Colors.orange,
      );
    }
    switch (syncState.status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return Icon(Icons.cloud_done, size: iconSize, color: Colors.green);
      case SyncStatus.offline:
        return Icon(Icons.cloud_off, size: iconSize, color: Colors.grey);
      case SyncStatus.error:
        return Icon(Icons.error_outline, size: iconSize, color: Colors.red);
    }
  }

  Widget _buildLabel(
    BuildContext context,
    SyncState syncState,
    bool hasPending,
  ) {
    final label = _labelText(context, syncState, hasPending);
    final color = _labelColor(syncState, hasPending);
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }

  String _labelText(
    BuildContext context,
    SyncState syncState,
    bool hasPending,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final hasConflict =
        syncState.status == SyncStatus.error &&
        (syncState.errorMessage ?? '').toLowerCase().contains('conflict');
    if (hasConflict) {
      return l10n.error;
    }

    switch (syncState.status) {
      case SyncStatus.syncing:
        return l10n.loadingProgress;
      case SyncStatus.synced:
        return hasPending ? l10n.changesWillSync : l10n.saved;
      case SyncStatus.offline:
        return l10n.youreOfflineLabel;
      case SyncStatus.error:
        return l10n.saveFailed;
    }
  }

  Color? _labelColor(SyncState syncState, bool hasPending) {
    final hasConflict =
        syncState.status == SyncStatus.error &&
        (syncState.errorMessage ?? '').toLowerCase().contains('conflict');
    if (hasConflict) return Colors.orange;
    switch (syncState.status) {
      case SyncStatus.syncing:
        return null;
      case SyncStatus.synced:
        return hasPending ? Colors.orange : Colors.green;
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}
