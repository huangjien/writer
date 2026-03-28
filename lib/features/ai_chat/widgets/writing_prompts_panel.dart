import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/models/writing_prompt.dart';
import 'package:writer/features/ai_chat/services/writing_prompts_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';

class WritingPromptsPanel extends ConsumerStatefulWidget {
  const WritingPromptsPanel({
    super.key,
    required this.onPromptSelected,
    this.onAddCustomPrompt,
  });

  final ValueChanged<WritingPrompt> onPromptSelected;
  final VoidCallback? onAddCustomPrompt;

  @override
  ConsumerState<WritingPromptsPanel> createState() =>
      _WritingPromptsPanelState();
}

class _WritingPromptsPanelState extends ConsumerState<WritingPromptsPanel> {
  WritingPromptCategory? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final service = ref.watch(writingPromptsServiceProvider);
    final prompts = _searchQuery.isNotEmpty
        ? service.searchPrompts(_searchQuery)
        : (_selectedCategory != null
              ? service.getPromptsByCategory(_selectedCategory!)
              : service.getAllPrompts());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Writing Prompts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.s),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search prompts...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.m,
                    vertical: Spacing.s,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
            itemCount: WritingPromptCategory.values.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: Spacing.xs),
            itemBuilder: (context, index) {
              final category = WritingPromptCategory.values[index];
              final isSelected = _selectedCategory == category;
              return FilterChip(
                selected: isSelected,
                label: Text(category.label),
                avatar: Icon(category.icon, size: 16),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.m),
        Expanded(
          child: prompts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: Spacing.s),
                      Text(
                        'No prompts found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                  itemCount: prompts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: Spacing.xs),
                  itemBuilder: (context, index) {
                    final prompt = prompts[index];
                    return _PromptCard(
                      prompt: prompt,
                      onTap: () => widget.onPromptSelected(prompt),
                    );
                  },
                ),
        ),
        if (widget.onAddCustomPrompt != null)
          Padding(
            padding: const EdgeInsets.all(Spacing.m),
            child: OutlinedButton.icon(
              onPressed: widget.onAddCustomPrompt,
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Prompt'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt, required this.onTap});

  final WritingPrompt prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    prompt.category.icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      prompt.category.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (prompt.isCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Custom',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                prompt.text,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (prompt.aiContext != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  prompt.aiContext!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddCustomPromptDialog extends ConsumerStatefulWidget {
  const AddCustomPromptDialog({super.key});

  @override
  ConsumerState<AddCustomPromptDialog> createState() =>
      _AddCustomPromptDialogState();
}

class _AddCustomPromptDialogState extends ConsumerState<AddCustomPromptDialog> {
  final _textController = TextEditingController();
  final _contextController = TextEditingController();
  WritingPromptCategory _selectedCategory = WritingPromptCategory.custom;

  @override
  void dispose() {
    _textController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Custom Prompt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Prompt Text *',
                hintText: 'Enter your writing prompt...',
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: Spacing.m),
            DropdownButtonFormField<WritingPromptCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: WritingPromptCategory.values
                  .where((c) => c != WritingPromptCategory.custom)
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 18),
                          const SizedBox(width: Spacing.xs),
                          Text(category.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: Spacing.m),
            TextField(
              controller: _contextController,
              decoration: InputDecoration(
                labelText: 'AI Context (optional)',
                hintText: 'What should the AI focus on?',
                helperText: 'Helps the AI understand how to respond',
                helperStyle: theme.textTheme.bodySmall,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _textController.text.trim().isEmpty
              ? null
              : () async {
                  final service = ref.read(writingPromptsServiceProvider);
                  await service.addCustomPrompt(
                    WritingPrompt(
                      id: '',
                      text: _textController.text.trim(),
                      category: _selectedCategory,
                      isCustom: true,
                      aiContext: _contextController.text.trim().isNotEmpty
                          ? _contextController.text.trim()
                          : null,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
