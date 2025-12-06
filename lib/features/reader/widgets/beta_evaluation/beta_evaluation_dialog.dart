import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../l10n/app_localizations.dart';

class BetaEvaluationDialog extends StatelessWidget {
  const BetaEvaluationDialog({super.key, required this.evaluation});

  final Map<String, dynamic> evaluation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final markdown = evaluation['markdown'] as String? ?? '';

    return AlertDialog(
      title: Text(l10n.betaEvaluate),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(child: MarkdownBody(data: markdown)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
