import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem(
                  context,
                  'Total Words',
                  '${statistics['total_words_written'] ?? 0}',
                  Icons.edit,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Writing Time',
                  '${statistics['total_writing_time_minutes'] ?? 0} min',
                  Icons.access_time,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Avg Speed',
                  '${(statistics['average_words_per_minute'] as num?)?.toStringAsFixed(1) ?? '0.0'} wpm',
                  Icons.speed,
                  Colors.purple,
                ),
                _buildStatItem(
                  context,
                  'Current Streak',
                  '${statistics['current_streak'] ?? 0} days',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                _buildStatItem(
                  context,
                  'Longest Streak',
                  '${statistics['longest_streak'] ?? 0} days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
                _buildStatItem(
                  context,
                  'Achieved Goals',
                  '${statistics['achieved_goals'] ?? 0}/${statistics['total_goals'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
