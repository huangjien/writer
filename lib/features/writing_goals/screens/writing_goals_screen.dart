import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/writing_goals/services/writing_goals_service.dart';
import 'package:writer/models/writing_goal.dart';
import 'package:writer/features/writing_goals/widgets/goal_creation_dialog.dart';
import 'package:writer/features/writing_goals/widgets/goal_card.dart';
import 'package:writer/features/writing_goals/widgets/statistics_card.dart';

final writingGoalsServiceProvider = Provider<WritingGoalsService>((ref) {
  return WritingGoalsService();
});

final goalsProvider = FutureProvider.autoDispose<List<WritingGoal>>((
  ref,
) async {
  final service = ref.watch(writingGoalsServiceProvider);
  return service.getGoals();
});

final statisticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(writingGoalsServiceProvider);
  return service.getStatistics();
});

class WritingGoalsScreen extends ConsumerStatefulWidget {
  const WritingGoalsScreen({super.key});

  @override
  ConsumerState<WritingGoalsScreen> createState() => _WritingGoalsScreenState();
}

class _WritingGoalsScreenState extends ConsumerState<WritingGoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(goalsProvider);
      ref.invalidate(statisticsProvider);
    });
  }

  Future<void> _refreshGoals() async {
    ref.invalidate(goalsProvider);
    ref.invalidate(statisticsProvider);
  }

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => GoalCreationDialog(
        onGoalCreated: (type, targetWordCount, endDate) async {
          final service = ref.read(writingGoalsServiceProvider);
          await service.createGoal(
            type: type,
            targetWordCount: targetWordCount,
            endDate: endDate,
          );
          if (mounted) {
            Navigator.of(dialogContext).pop();
            _refreshGoals();
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(
                content: Text('Goal created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showAddProgressDialog(WritingGoal goal) {
    final wordsController = TextEditingController();
    final minutesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Words Written',
                hintText: 'Enter number of words',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Writing Time (minutes)',
                hintText: 'Enter time spent writing',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final words = int.tryParse(wordsController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;

              if (words <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid word count'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final service = ref.read(writingGoalsServiceProvider);
              try {
                await service.addDailyProgress(
                  goalId: goal.id,
                  wordsWritten: words,
                  writingTimeMinutes: minutes,
                );
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                  _refreshGoals();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Progress added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error adding progress: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Progress'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(WritingGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(writingGoalsServiceProvider);
      await service.deleteGoal(goal.id);
      if (mounted) {
        _refreshGoals();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGoals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGoals,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final statsAsync = ref.watch(statisticsProvider);
                  return statsAsync.when(
                    data: (stats) => StatisticsCard(statistics: stats),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading statistics: $error'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateGoalDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('New Goal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final goalsAsync = ref.watch(goalsProvider);
                  return goalsAsync.when(
                    data: (goals) {
                      if (goals.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.flag_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No goals yet',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first writing goal to start tracking your progress',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showCreateGoalDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Goal'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: goals
                            .map(
                              (goal) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GoalCard(
                                  goal: goal,
                                  onAddProgress: () =>
                                      _showAddProgressDialog(goal),
                                  onDelete: () => _deleteGoal(goal),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('Error loading goals: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshGoals,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
