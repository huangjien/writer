import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../shared/widgets/app_buttons.dart';

class WritingPromptsSheet extends StatelessWidget {
  const WritingPromptsSheet({super.key, required this.onInsert});

  final ValueChanged<String> onInsert;

  static const List<String> _prompts = <String>[
    'Write a scene where a small mistake changes everything.',
    'Describe a room using only sounds and textures.',
    'Your character receives a letter they were never meant to read.',
    'Write dialogue where the truth is never said directly.',
    'Start with: “I didn’t expect to see you here.”',
    'A promise made long ago comes due today.',
    'Write a calm moment right before chaos.',
    'A character must choose between two good options.',
    'Show a power imbalance without mentioning it.',
    'Write a scene that ends with a choice.',
    'Reveal a secret using an everyday object.',
    'Write a paragraph with no adjectives.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a prompt to insert',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.m),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _prompts.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.s),
              itemBuilder: (context, index) {
                final p = _prompts[index];
                return AppButtons.secondary(
                  label: p,
                  onPressed: () => onInsert(p),
                  fullWidth: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
