import 'package:flutter/material.dart';

class SummaryPreviewEditTab extends StatelessWidget {
  const SummaryPreviewEditTab({
    super.key,
    required this.tabController,
    required this.previewLabel,
    required this.editLabel,
    required this.text,
    required this.emptyText,
    this.fieldKey,
    required this.editController,
    required this.decoration,
    required this.onChanged,
  });

  final TabController tabController;
  final String previewLabel;
  final String editLabel;
  final String text;
  final String emptyText;
  final Key? fieldKey;
  final TextEditingController editController;
  final InputDecoration decoration;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            Tab(text: previewLabel),
            Tab(text: editLabel),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _SummaryPreviewPanel(text: text, emptyText: emptyText),
              _SummaryEditField(
                fieldKey: fieldKey,
                controller: editController,
                decoration: decoration,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryPreviewPanel extends StatelessWidget {
  const _SummaryPreviewPanel({required this.text, required this.emptyText});

  final String text;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        text.isEmpty ? emptyText : text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _SummaryEditField extends StatelessWidget {
  const _SummaryEditField({
    this.fieldKey,
    required this.controller,
    required this.decoration,
    required this.onChanged,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final InputDecoration decoration;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        decoration: decoration,
        expands: true,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
