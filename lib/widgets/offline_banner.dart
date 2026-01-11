import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/sync_service_provider.dart';
import '../state/network_monitor_provider.dart';
import '../shared/widgets/glass_card.dart';
import '../theme/design_tokens.dart';

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
    final theme = Theme.of(context);

    // Only show when offline and has pending operations
    final showBanner = !isOnline && hasPending;
    final pendingCount = pendingCountAsync.value;
    final message = (showPendingCount && pendingCount != null)
        ? '$pendingCount change${pendingCount == 1 ? '' : 's'} will sync when you\'re back online'
        : 'Changes will sync when you\'re back online';

    return AnimatedSwitcher(
      duration: Motion.medium,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: !showBanner
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.s,
              ),
              child: SafeArea(
                bottom: false,
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: 'You\'re offline. $message',
                  child: ExcludeSemantics(
                    child: GlassCard(
                      borderRadius: BorderRadius.circular(Radii.m),
                      color: theme.colorScheme.tertiaryContainer.withValues(
                        alpha: 0.85,
                      ),
                      borderColor: Colors.transparent,
                      blur: GlassTokens.blur,
                      shadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.l,
                          vertical: Spacing.m,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              color: theme.colorScheme.onTertiaryContainer,
                              size: 20,
                            ),
                            const SizedBox(width: Spacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'You\'re offline',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (showPendingCount && pendingCount != null)
                                    Text(
                                      message,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onTertiaryContainer
                                                .withValues(alpha: 0.85),
                                          ),
                                    ),
                                  if (showPendingCount && pendingCount == null)
                                    Text(
                                      message,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onTertiaryContainer
                                                .withValues(alpha: 0.85),
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
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            if (onDismiss != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                color: theme.colorScheme.onTertiaryContainer,
                                onPressed: onDismiss,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
