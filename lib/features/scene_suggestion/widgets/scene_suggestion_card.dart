import 'package:flutter/material.dart';
import 'package:writer/models/scene_suggestion.dart';

class SceneSuggestionCard extends StatelessWidget {
  final SceneSuggestion suggestion;
  final int index;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onModify;
  final bool isLoading;

  const SceneSuggestionCard({
    super.key,
    required this.suggestion,
    required this.index,
    required this.onAccept,
    required this.onReject,
    required this.onModify,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Scene suggestion ${index + 1}',
      value: suggestion.suggestedText,
      hint: 'Relevance score: ${(suggestion.relevanceScore * 100).toInt()}%',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Suggestion ${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: suggestion.relevanceScore,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(suggestion.relevanceScore, theme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(suggestion.relevanceScore * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(suggestion.suggestedText, style: theme.textTheme.bodyLarge),
              if (suggestion.rationale.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  suggestion.rationale,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (suggestion.alternativeApproaches.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: suggestion.alternativeApproaches.map((alternative) {
                    return Chip(
                      label: Text(
                        alternative,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: isLoading ? null : onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onModify,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modify'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isLoading ? null : onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score, ThemeData theme) {
    if (score >= 0.8) {
      return theme.colorScheme.primary;
    } else if (score >= 0.6) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.tertiary;
    }
  }
}
