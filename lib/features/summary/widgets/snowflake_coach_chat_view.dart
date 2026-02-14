import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/shared/widgets/particles/confetti_effect.dart';
import 'package:writer/shared/widgets/particles/sparkle_effect.dart';
import 'snowflake_coach_chat_widgets.dart';

class SnowflakeCoachChatView extends StatelessWidget {
  const SnowflakeCoachChatView({
    super.key,
    required this.l10n,
    required this.sparkleController,
    required this.confettiController,
    required this.inputController,
    required this.loading,
    required this.autoAnalyze,
    required this.coachTitle,
    required this.output,
    required this.messages,
    required this.isDone,
    required this.timestampText,
    required this.onAnalyze,
    required this.onSendUserResponse,
    required this.onSuggestionSelected,
  });

  final AppLocalizations l10n;
  final SparkleController sparkleController;
  final ConfettiController confettiController;
  final TextEditingController inputController;
  final bool loading;
  final bool autoAnalyze;
  final String coachTitle;
  final SnowflakeRefinementOutput? output;
  final List<Map<String, dynamic>> messages;
  final bool isDone;
  final String timestampText;
  final VoidCallback onAnalyze;
  final ValueChanged<String> onSendUserResponse;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    if (output == null) {
      return ConfettiEffect(
        controller: confettiController,
        child: Column(
          children: [
            SnowflakeCoachTopBar(
              title: coachTitle,
              sparkleController: sparkleController,
              showSparkleIcon: false,
              rightButton: SnowflakeCoachAnalyzeButton(
                loading: loading,
                onAnalyze: onAnalyze,
                label: 'Analyze',
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chat history yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Analyze" to start improving your summary',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final suggestions = output?.suggestions ?? const <String>[];

    return ConfettiEffect(
      controller: confettiController,
      child: Column(
        children: [
          SnowflakeCoachTopBar(
            title: isDone ? l10n.refinementComplete : l10n.coachQuestion,
            sparkleController: sparkleController,
            showSparkleIcon: true,
            rightButton: !autoAnalyze
                ? SnowflakeCoachAnalyzeButton(
                    loading: loading,
                    onAnalyze: onAnalyze,
                    label: 'Analyze',
                  )
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isDone
                          ? (output?.critique ?? l10n.summaryLooksGood)
                          : (output?.aiQuestion ?? l10n.howToImprove),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (messages.isNotEmpty) ...[
                    for (final msg in messages) ...[
                      const SizedBox(height: 8),
                      SnowflakeCoachChatBubble(
                        role: msg['role'],
                        content: msg['content'] ?? '',
                      ),
                    ],
                    if (isDone && (output?.critique?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 8),
                      SnowflakeCoachCompletionBubble(
                        content: output!.critique!,
                      ),
                    ],
                  ],
                  if (timestampText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SnowflakeCoachTimestamp(text: timestampText),
                  ],
                  if (!isDone && suggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.suggestionsLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((s) {
                        return GestureDetector(
                          onTap: loading ? null : () => onSuggestionSelected(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: loading
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: loading
                                    ? Theme.of(context).colorScheme.outline
                                          .withValues(alpha: 0.2)
                                    : Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.3),
                              ),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 100,
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: loading
                                      ? Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.5)
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                                maxLines: null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SnowflakeCoachInputArea(
            l10n: l10n,
            inputController: inputController,
            loading: loading,
            isDone: isDone,
            onSend: onSendUserResponse,
          ),
        ],
      ),
    );
  }
}
