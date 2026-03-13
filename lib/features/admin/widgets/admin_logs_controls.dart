import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/app_buttons.dart';

class AdminLogsControls extends StatelessWidget {
  const AdminLogsControls({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.availableFiles,
    required this.selectedFileIndex,
    required this.onFileChanged,
    required this.maxSizeKb,
    required this.onMaxSizeChanged,
    required this.onSearch,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final bool isLoading;
  final List<Map<String, dynamic>> availableFiles;
  final int selectedFileIndex;
  final ValueChanged<int> onFileChanged;
  final int maxSizeKb;
  final ValueChanged<int> onMaxSizeChanged;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search logs',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: isLoading ? null : onClearSearch,
                          )
                        : null,
                  ),
                  onSubmitted: (_) => onSearch(),
                ),
              ),
              const SizedBox(width: 16),
              AppButtons.primary(
                onPressed: isLoading ? () {} : onSearch,
                label: l10n.searchLabel,
                isLoading: isLoading,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: selectedFileIndex,
                  decoration: const InputDecoration(
                    labelText: 'Log File',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: availableFiles.map((file) {
                    final index = file['index'] as int;
                    final name = file['name'] as String;
                    final sizeKb = file['size_kb'] as double;
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text('$name (${sizeKb.toStringAsFixed(1)} KB)'),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          onFileChanged(value);
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: maxSizeKb,
                  decoration: const InputDecoration(
                    labelText: 'Max Size',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<int>(value: 10, child: Text('10 KB')),
                    DropdownMenuItem<int>(value: 50, child: Text('50 KB')),
                    DropdownMenuItem<int>(value: 100, child: Text('100 KB')),
                    DropdownMenuItem<int>(value: 500, child: Text('500 KB')),
                    DropdownMenuItem<int>(value: 1000, child: Text('1 MB')),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          onMaxSizeChanged(value);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
