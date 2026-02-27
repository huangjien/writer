import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(syncState.status),
          if (showLabel) ...[
            const SizedBox(width: 8),
            _buildLabel(context, syncState.status, hasPending),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
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

  Widget _buildLabel(BuildContext context, SyncStatus status, bool hasPending) {
    String label;
    Color? color;

    switch (status) {
      case SyncStatus.syncing:
        label = 'Syncing...';
        color = null;
        break;
      case SyncStatus.synced:
        label = hasPending ? 'Pending sync' : 'Synced';
        color = hasPending ? Colors.orange : Colors.green;
        break;
      case SyncStatus.offline:
        label = 'Offline';
        color = Colors.grey;
        break;
      case SyncStatus.error:
        label = 'Sync failed';
        color = Colors.red;
        break;
    }

    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
