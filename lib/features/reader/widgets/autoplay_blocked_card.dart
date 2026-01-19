import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/theme_aware_card.dart';

class AutoplayBlockedCard extends StatelessWidget {
  const AutoplayBlockedCard({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ThemeAwareCard(
      padding: const EdgeInsets.all(Spacing.m),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: Spacing.s),
          Expanded(child: Text(l10n.autoplayBlockedInline)),
          const SizedBox(width: Spacing.s),
          AppButtons.icon(
            iconData: Icons.play_arrow,
            tooltip: l10n.continueLabel,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
