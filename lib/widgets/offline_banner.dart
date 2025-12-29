import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/sync_service_provider.dart';
import '../state/network_monitor_provider.dart';

/// Warning banner displayed when offline with pending operations
/// Shows at the top of the screen or below the app bar
class OfflineBanner extends ConsumerWidget {
  final bool showPendingCount;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.showPendingCount = true,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final hasPending = ref.watch(hasPendingOperationsProvider);
    final pendingCountAsync = ref.watch(pendingOperationsCountProvider);

    // Only show when offline and has pending operations
    if (isOnline || !hasPending) {
      return const SizedBox.shrink();
    }

    final pendingCount = pendingCountAsync.value ?? 0;

    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You\'re offline',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (showPendingCount)
                    Text(
                      '$pendingCount change${pendingCount == 1 ? '' : 's'} will sync when you\'re back online',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: Colors.orange.shade800,
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
