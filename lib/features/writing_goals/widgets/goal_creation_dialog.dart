import 'package:flutter/material.dart';
import 'package:writer/models/writing_goal.dart';

class GoalCreationDialog extends StatefulWidget {
  final Function(GoalType type, int targetWordCount, DateTime? endDate)
  onGoalCreated;

  const GoalCreationDialog({super.key, required this.onGoalCreated});

  @override
  State<GoalCreationDialog> createState() => _GoalCreationDialogState();
}

class _GoalCreationDialogState extends State<GoalCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetWordsController = TextEditingController();
  GoalType _selectedType = GoalType.daily;
  DateTime? _endDate;
  bool _hasEndDate = false;

  @override
  void dispose() {
    _targetWordsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final targetWordCount = int.parse(_targetWordsController.text);
      widget.onGoalCreated(_selectedType, targetWordCount, _endDate);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Writing Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Goal Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<GoalType>(
                segments: const [
                  ButtonSegment(value: GoalType.daily, label: Text('Daily')),
                  ButtonSegment(value: GoalType.weekly, label: Text('Weekly')),
                  ButtonSegment(
                    value: GoalType.monthly,
                    label: Text('Monthly'),
                  ),
                  ButtonSegment(value: GoalType.total, label: Text('Total')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<GoalType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetWordsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Word Count',
                  hintText: 'e.g., 1000',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target word count';
                  }
                  final words = int.tryParse(value);
                  if (words == null || words <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _hasEndDate,
                    onChanged: (value) {
                      setState(() {
                        _hasEndDate = value ?? false;
                        if (!_hasEndDate) {
                          _endDate = null;
                        }
                      });
                    },
                  ),
                  const Text('Set end date'),
                ],
              ),
              if (_hasEndDate) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _endDate != null
                          ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                          : 'Select date',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Create Goal')),
      ],
    );
  }
}
