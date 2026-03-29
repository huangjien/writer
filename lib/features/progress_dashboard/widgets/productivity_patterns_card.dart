import 'package:flutter/material.dart';

class ProductivityPatternsCard extends StatelessWidget {
  final Map<String, dynamic> patterns;

  const ProductivityPatternsCard({super.key, required this.patterns});

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.schedule, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No productivity patterns yet'),
                Text(
                  'Keep writing to discover your patterns',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bestDayOfWeek = patterns['best_day_of_week'] as String?;
    final bestHour = patterns['best_hour'] as int?;
    final dayDistribution = patterns['day_distribution'] as Map<String, int>?;
    final hourDistribution = patterns['hour_distribution'] as Map<int, int>?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Patterns',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (bestDayOfWeek != null)
              _buildBestDayCard(context, bestDayOfWeek),
            if (bestHour != null) ...[
              const SizedBox(height: 16),
              _buildBestHourCard(context, bestHour),
            ],
            if (dayDistribution != null && dayDistribution.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Day Distribution',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDayDistributionChart(context, dayDistribution),
            ],
            if (hourDistribution != null && hourDistribution.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Hour Distribution',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildHourDistributionChart(context, hourDistribution),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBestDayCard(BuildContext context, String bestDayOfWeek) {
    final dayName = _formatDayOfWeek(bestDayOfWeek);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.2),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Day of the Week',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestHourCard(BuildContext context, int bestHour) {
    final hourText = _formatHour(bestHour);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Productive Hour',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  hourText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDistributionChart(
    BuildContext context,
    Map<String, int> distribution,
  ) {
    final maxValue = distribution.values.reduce((a, b) => a > b ? a : b);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final value = distribution[day.toLowerCase()] ?? 0;
          final height = maxValue > 0 ? (value / maxValue) * 120 : 0.0;
          final isBestDay = distribution[bestDayKey(day)] == maxValue;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: height,
                decoration: BoxDecoration(
                  color: isBestDay
                      ? Colors.green
                      : Colors.blue.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isBestDay ? FontWeight.bold : FontWeight.normal,
                  color: isBestDay ? Colors.green : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHourDistributionChart(
    BuildContext context,
    Map<int, int> distribution,
  ) {
    final maxValue = distribution.values.reduce((a, b) => a > b ? a : b);
    final hours = distribution.keys.toList()..sort();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        itemBuilder: (context, index) {
          final hour = hours[index];
          final value = distribution[hour] ?? 0;
          final height = maxValue > 0 ? (value / maxValue) * 80 : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatHour(hour),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDayOfWeek(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      case 'sunday':
        return 'Sunday';
      default:
        return day;
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  String bestDayKey(String dayAbbr) {
    switch (dayAbbr) {
      case 'Mon':
        return 'monday';
      case 'Tue':
        return 'tuesday';
      case 'Wed':
        return 'wednesday';
      case 'Thu':
        return 'thursday';
      case 'Fri':
        return 'friday';
      case 'Sat':
        return 'saturday';
      case 'Sun':
        return 'sunday';
      default:
        return dayAbbr.toLowerCase();
    }
  }
}
