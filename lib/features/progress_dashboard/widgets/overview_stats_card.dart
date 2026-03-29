import 'package:flutter/material.dart';
import 'package:writer/models/writing_progress.dart';

class OverviewStatsCard extends StatelessWidget {
  final WritingStats stats;

  const OverviewStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.edit,
                  title: 'Total Words',
                  value: stats.totalWords.toString(),
                  subtitle: 'words written',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.timer,
                  title: 'Total Time',
                  value: (stats.totalTimeMinutes / 60).toStringAsFixed(1),
                  subtitle: 'hours writing',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.whatshot,
                  title: 'Current Streak',
                  value: stats.currentStreak.toString(),
                  subtitle: 'days in a row',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.emoji_events,
                  title: 'Longest Streak',
                  value: stats.longestStreak.toString(),
                  subtitle: 'days',
                  color: Colors.purple,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Productive Days',
                  value: stats.productiveDays.toString(),
                  subtitle: 'days written',
                  color: Colors.teal,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.speed,
                  title: 'Avg/Day',
                  value: stats.averageWordsPerDay.toStringAsFixed(0),
                  subtitle: 'words daily',
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAdditionalStats(context),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Insights',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInsightChip(
              context,
              icon: Icons.show_chart,
              label: 'Best Day: ${stats.mostProductiveDayWordCount ?? 0} words',
              color: Colors.green,
            ),
            _buildInsightChip(
              context,
              icon: Icons.bar_chart,
              label:
                  'Avg/Session: ${stats.averageWordsPerSession.toStringAsFixed(0)} words',
              color: Colors.blue,
            ),
            _buildInsightChip(
              context,
              icon: Icons.schedule,
              label:
                  'Avg Speed: ${stats.averageWordsPerMinute.toStringAsFixed(1)} words/min',
              color: Colors.orange,
            ),
            _buildInsightChip(
              context,
              icon: Icons.trending_up,
              label:
                  'Productivity Rate: ${(stats.productivityRate * 100).toStringAsFixed(0)}%',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
