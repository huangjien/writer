import 'package:flutter/material.dart';
import 'package:writer/models/writing_goal.dart';

class GoalCard extends StatelessWidget {
  final WritingGoal goal;
  final VoidCallback onAddProgress;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onAddProgress,
    required this.onDelete,
  });

  String _getGoalTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return 'Daily';
      case GoalType.weekly:
        return 'Weekly';
      case GoalType.monthly:
        return 'Monthly';
      case GoalType.total:
        return 'Total';
    }
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return Colors.blue;
      case GoalType.weekly:
        return Colors.green;
      case GoalType.monthly:
        return Colors.orange;
      case GoalType.total:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getGoalTypeColor(goal.type);
    final progressPercentage = goal.progressPercentage;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _getGoalTypeLabel(goal.type),
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (goal.isGoalAchieved)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete Goal',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${goal.currentProgress} / ${goal.targetWordCount} words',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 1.0 ? Colors.green : typeColor,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progressPercentage * 100).toStringAsFixed(1)}% complete',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '${goal.currentStreak} day streak',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${goal.dailyProgress.length} days tracked',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddProgress,
                icon: const Icon(Icons.add),
                label: const Text('Add Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
