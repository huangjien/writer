import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/particles/sparkle_effect.dart';

class SnowflakeCoachTopBar extends StatelessWidget {
  const SnowflakeCoachTopBar({
    super.key,
    required this.title,
    required this.sparkleController,
    required this.showSparkleIcon,
    required this.rightButton,
  });

  final String title;
  final SparkleController sparkleController;
  final bool showSparkleIcon;
  final Widget? rightButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (showSparkleIcon)
            SparkleEffect(
              controller: sparkleController,
              child: Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            )
          else
            Icon(
              Icons.chat,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (rightButton != null) rightButton!,
        ],
      ),
    );
  }
}

class SnowflakeCoachChatBubble extends StatelessWidget {
  const SnowflakeCoachChatBubble({
    super.key,
    required this.role,
    required this.content,
  });

  final dynamic role;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUser
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.auto_awesome,
                  color: isUser
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUser
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    if (content.isEmpty) return;
                    await Clipboard.setData(ClipboardData(text: content));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: isUser
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SnowflakeCoachCompletionBubble extends StatelessWidget {
  const SnowflakeCoachCompletionBubble({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SnowflakeCoachTimestamp extends StatelessWidget {
  const SnowflakeCoachTimestamp({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SnowflakeCoachInputArea extends StatelessWidget {
  const SnowflakeCoachInputArea({
    super.key,
    required this.l10n,
    required this.inputController,
    required this.loading,
    required this.isDone,
    required this.onSend,
  });

  final AppLocalizations l10n;
  final TextEditingController inputController;
  final bool loading;
  final bool isDone;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDone)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Chat completed - Start a new analysis or ask questions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                hintText: isDone
                    ? 'Ask a follow-up question or start new analysis...'
                    : l10n.reviewSuggestionsHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: loading
                        ? null
                        : () {
                            final val = inputController.text.trim();
                            if (val.isEmpty) return;
                            onSend(val);
                            inputController.clear();
                          },
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ),
              ),
              minLines: 1,
              maxLines: 3,
              textAlignVertical: TextAlignVertical.top,
              onSubmitted: (val) {
                final trimmed = val.trim();
                if (trimmed.isEmpty) return;
                onSend(trimmed);
                inputController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SnowflakeCoachAnalyzeButton extends StatelessWidget {
  const SnowflakeCoachAnalyzeButton({
    super.key,
    required this.loading,
    required this.onAnalyze,
    required this.label,
  });

  final bool loading;
  final VoidCallback onAnalyze;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppButtons.primary(
      onPressed: loading ? () {} : onAnalyze,
      icon: Icons.analytics,
      label: label,
      enabled: !loading,
    );
  }
}
