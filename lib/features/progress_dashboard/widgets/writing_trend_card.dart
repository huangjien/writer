import 'package:flutter/material.dart';
import 'package:writer/models/writing_progress.dart';

class WritingTrendCard extends StatelessWidget {
  final List<WritingProgress> trendData;

  const WritingTrendCard({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.show_chart, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No trend data available yet'),
                Text(
                  'Start writing to see your trends',
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

    final maxWords = trendData
        .map((p) => p.wordsWritten)
        .reduce((a, b) => a > b ? a : b);
    final totalWords = trendData.fold<int>(0, (sum, p) => sum + p.wordsWritten);
    final avgWords = totalWords / trendData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Writing Trend',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildSummaryChip(
                  context,
                  'Avg: ${avgWords.toStringAsFixed(0)} words/day',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: _buildTrendChart(context, maxWords)),
            const SizedBox(height: 16),
            _buildTrendInsights(context, avgWords),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(BuildContext context, String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      avatar: const Icon(Icons.analytics, size: 18),
    );
  }

  Widget _buildTrendChart(BuildContext context, int maxWords) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _TrendChartPainter(data: trendData, maxWords: maxWords),
    );
  }

  Widget _buildTrendInsights(BuildContext context, double avgWords) {
    if (trendData.length < 14) {
      return const SizedBox.shrink();
    }

    final lastWeek = trendData.skip(trendData.length - 7).take(7).toList();
    final previousWeek = trendData.skip(trendData.length - 14).take(7).toList();

    final lastWeekAvg = lastWeek.isNotEmpty
        ? lastWeek.map((p) => p.wordsWritten).reduce((a, b) => a + b) /
              lastWeek.length
        : 0.0;
    final previousWeekAvg = previousWeek.isNotEmpty
        ? previousWeek.map((p) => p.wordsWritten).reduce((a, b) => a + b) /
              previousWeek.length
        : 0.0;

    final trend = lastWeekAvg > previousWeekAvg * 1.1
        ? 'up'
        : lastWeekAvg < previousWeekAvg * 0.9
        ? 'down'
        : 'stable';

    final trendColor = trend == 'up'
        ? Colors.green
        : trend == 'down'
        ? Colors.red
        : Colors.grey;
    final trendIcon = trend == 'up'
        ? Icons.trending_up
        : trend == 'down'
        ? Icons.trending_down
        : Icons.trending_flat;

    return Row(
      children: [
        Icon(trendIcon, color: trendColor, size: 20),
        const SizedBox(width: 8),
        Text(
          'Last week: ${trend == "up"
              ? "Increased"
              : trend == "down"
              ? "Decreased"
              : "Stable"}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Last 7 days: ${lastWeekAvg.toStringAsFixed(0)} words/day',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<WritingProgress> data;
  final int maxWords;

  _TrendChartPainter({required this.data, required this.maxWords});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxWords == 0) return;
    if (data.length == 1) {
      final x = size.width / 2;
      final y = size.height / 2;
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5.0, pointPaint);
      return;
    }

    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    final chartWidth = size.width - padding.horizontal;
    final chartHeight = size.height - padding.vertical;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    final stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (i * stepX);
      final y =
          padding.top +
          chartHeight -
          ((data[i].wordsWritten / maxWords) * chartHeight);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      final pointRadius = data[i].wordsWritten == maxWords ? 5.0 : 3.5;
      canvas.drawCircle(Offset(x, y), pointRadius, pointPaint);
    }

    fillPath.lineTo(padding.left + chartWidth, padding.top + chartHeight);
    fillPath.lineTo(padding.left, padding.top + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.maxWords != maxWords;
  }
}
