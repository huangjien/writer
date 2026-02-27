import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

class BetaEvaluationDialog extends StatelessWidget {
  const BetaEvaluationDialog({super.key, required this.evaluation});

  final Map<String, dynamic> evaluation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final markdown = evaluation['markdown'] as String? ?? '';

    return AppDialog(
      title: l10n.betaEvaluate,
      maxWidth: 700,
      content: MarkdownBody(data: markdown),
      actions: [
        AppButtons.text(
          onPressed: () => Navigator.of(context).pop(),
          label: l10n.cancel,
        ),
      ],
    );
  }
}
