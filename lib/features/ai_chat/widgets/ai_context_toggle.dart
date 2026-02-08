import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import '../state/ai_chat_providers.dart';
import '../utils/context_utils.dart';

class AiContextToggle extends ConsumerWidget {
  const AiContextToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiContextProvider);
    final notifier = ref.read(aiContextProvider.notifier);

    // Only show if a delegate is set or if enabled (to allow disabling)
    if (state.currentType == null && !state.isEnabled) {
      return const SizedBox.shrink();
    }

    final isTooLong = state.tokenCount > ContextUtils.maxContextTokens;
    final l10n = AppLocalizations.of(context)!;
    final tokenText = state.tokenCount > 0
        ? l10n.aiTokenCount(state.tokenCount)
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: state.isEnabled
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTooLong
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.outlineVariant,
          width: isTooLong ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: Switch(
              value: state.isEnabled,
              onChanged: (v) => notifier.toggle(v),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.aiChatContextLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: state.isEnabled
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
          if (state.isEnabled && state.currentType != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                state.currentType!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 9,
                ),
              ),
            ),
          ],
          if (tokenText.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              tokenText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isTooLong
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (isTooLong) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.compress,
              size: 14,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
          if (state.isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
