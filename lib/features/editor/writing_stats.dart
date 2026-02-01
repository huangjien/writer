import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../shared/strings.dart';
import '../../l10n/app_localizations.dart';

class WritingStats extends StatelessWidget {
  const WritingStats({
    super.key,
    required this.controller,
    this.streakDays,
    this.showCounts = true,
    this.showStreak = true,
  });

  final TextEditingController controller;
  final int? streakDays;
  final bool showCounts;
  final bool showStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        final wordCount = countWords(text);
        final charCount = text.characters.length;
        final readingTimeLabel = _readingTimeLabel(wordCount);

        final theme = Theme.of(context);
        final chips = <Widget>[
          if (showCounts) ...[
            _StatChip(label: l10n.wordsLabel, value: '$wordCount'),
            _StatChip(label: l10n.charsLabel, value: '$charCount'),
            _StatChip(label: l10n.readLabel, value: readingTimeLabel),
          ],
          if (showStreak && streakDays != null && streakDays! > 0)
            _StatChip(label: l10n.streakLabel, value: '${streakDays!}d'),
        ];

        if (chips.isEmpty) {
          return const SizedBox.shrink();
        }

        return Semantics(
          container: true,
          label: _semanticsLabel(
            wordCount: wordCount,
            charCount: charCount,
            readingTimeLabel: readingTimeLabel,
            streakDays: showStreak ? streakDays : null,
          ),
          child: ExcludeSemantics(
            child: Wrap(
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: chips
                  .map(
                    (w) => IconTheme(
                      data: IconThemeData(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  static String _readingTimeLabel(int words) {
    if (words <= 0) return '<1m';
    final minutes = (words / 200.0).ceil();
    return minutes <= 1 ? '<1m' : '${minutes}m';
  }

  static String _semanticsLabel({
    required int wordCount,
    required int charCount,
    required String readingTimeLabel,
    required int? streakDays,
  }) {
    final parts = <String>[
      '$wordCount words',
      '$charCount characters',
      'estimated reading time $readingTimeLabel',
    ];
    if (streakDays != null && streakDays > 0) {
      parts.add('writing streak $streakDays days');
    }
    return parts.join(', ');
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Radii.l),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: Spacing.s),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
