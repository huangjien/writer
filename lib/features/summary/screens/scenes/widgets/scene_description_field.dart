import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/l10n/app_localizations.dart';

class SceneDescriptionField extends StatelessWidget {
  const SceneDescriptionField({
    super.key,
    required this.l10n,
    required this.controller,
    required this.showPreview,
    required this.onTogglePreview,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final bool showPreview;
  final VoidCallback onTogglePreview;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.descriptionLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTogglePreview,
                  child: Text(
                    showPreview ? l10n.edit : l10n.preview,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showPreview)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            constraints: const BoxConstraints(minHeight: 100),
            child: MarkdownBody(data: controller.text),
          )
        else
          TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.descriptionLabel),
            maxLines: 5,
            onChanged: onChanged,
          ),
      ],
    );
  }
}
