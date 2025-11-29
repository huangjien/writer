import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class AutoplayBlockedCard extends StatelessWidget {
  const AutoplayBlockedCard({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(AppLocalizations.of(context)!.autoplayBlockedInline),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!.continueLabel,
              child: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
