import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/scene_template_row.dart';
import 'scenes_support_widgets.dart';

class SceneTemplatePicker extends StatelessWidget {
  const SceneTemplatePicker({
    super.key,
    required this.l10n,
    required this.languageCode,
    required this.templatesForLanguage,
    required this.templateQuery,
    required this.templateSearchResults,
    required this.templateSearchLoading,
    required this.selectedTemplate,
    required this.onSelectedTemplate,
    required this.onQueryChanged,
    required this.onTemplateControllerAvailable,
    required this.isConverting,
    required this.onConvertPressed,
    required this.canConvert,
  });

  final AppLocalizations l10n;
  final String languageCode;
  final Iterable<SceneTemplateRow> templatesForLanguage;
  final String templateQuery;
  final List<SceneTemplateRow> templateSearchResults;
  final bool templateSearchLoading;
  final SceneTemplateRow? selectedTemplate;
  final ValueChanged<SceneTemplateRow?> onSelectedTemplate;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<TextEditingController> onTemplateControllerAvailable;
  final bool isConverting;
  final Future<void> Function()? onConvertPressed;
  final bool canConvert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<SceneTemplateRow>(
            displayStringForOption: (option) => option.title ?? '',
            optionsBuilder: (textEditingValue) {
              final q = textEditingValue.text.trim();
              if (q.isEmpty) return templatesForLanguage;
              if (templateQuery == q && templateSearchResults.isNotEmpty) {
                return templateSearchResults;
              }
              return templatesForLanguage.where(
                (t) => (t.title ?? '').toLowerCase().contains(q.toLowerCase()),
              );
            },
            onSelected: (selection) => onSelectedTemplate(selection),
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
                  onTemplateControllerAvailable(textEditingController);

                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: l10n.templateLabel,
                      border: const OutlineInputBorder(),
                      suffixIcon: templateSearchLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      if (selectedTemplate != null) onSelectedTemplate(null);
                      onQueryChanged(v);
                    },
                    onFieldSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
          ),
        ),
        const SizedBox(width: 8),
        SceneTemplateInfoButton(template: selectedTemplate),
        const SizedBox(width: 8),
        SceneConvertButton(
          l10n: l10n,
          isConverting: isConverting,
          onPressed: canConvert ? onConvertPressed : null,
        ),
      ],
    );
  }
}
