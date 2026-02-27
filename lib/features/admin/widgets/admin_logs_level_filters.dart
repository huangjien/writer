import 'package:flutter/material.dart';
import 'package:writer/features/admin/admin_logs_utils.dart';

class AdminLogsLevelFilters extends StatelessWidget {
  const AdminLogsLevelFilters({
    super.key,
    required this.logLevels,
    required this.selectedLevel,
    required this.onSelectedLevelChanged,
  });

  final List<String> logLevels;
  final String? selectedLevel;
  final ValueChanged<String?> onSelectedLevelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surface,
      child: Wrap(
        spacing: 8.0,
        children: [
          FilterChip(
            label: const Text('ALL'),
            selected: selectedLevel == null,
            onSelected: (selected) {
              onSelectedLevelChanged(selected ? null : 'INFO');
            },
          ),
          ...logLevels.map((level) {
            final isSelected = selectedLevel == level;
            return FilterChip(
              label: Text(level),
              selected: isSelected,
              selectedColor: getAdminLogLevelColor(context, level),
              onSelected: (selected) {
                onSelectedLevelChanged(selected ? level : null);
              },
            );
          }),
        ],
      ),
    );
  }
}
