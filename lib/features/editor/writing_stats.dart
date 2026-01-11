import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class WritingStats extends StatelessWidget {
  const WritingStats({super.key, required this.controller, this.streakDays});

  final TextEditingController controller;
  final int? streakDays;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        final wordCount = _countWords(text);
        final charCount = text.characters.length;
        final readingTimeLabel = _readingTimeLabel(wordCount);

        final theme = Theme.of(context);
        final chips = <Widget>[
          _StatChip(label: 'Words', value: '$wordCount'),
          _StatChip(label: 'Chars', value: '$charCount'),
          _StatChip(label: 'Read', value: readingTimeLabel),
          if (streakDays != null && streakDays! > 0)
            _StatChip(label: 'Streak', value: '${streakDays!}d'),
        ];

        return Semantics(
          container: true,
          label: _semanticsLabel(
            wordCount: wordCount,
            charCount: charCount,
            readingTimeLabel: readingTimeLabel,
            streakDays: streakDays,
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

  static int _countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
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
