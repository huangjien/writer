import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/progress_dashboard/services/progress_analytics_service.dart';
import 'package:writer/features/progress_dashboard/widgets/overview_stats_card.dart';
import 'package:writer/features/progress_dashboard/widgets/achievement_badge.dart';
import 'package:writer/features/progress_dashboard/widgets/writing_trend_card.dart';
import 'package:writer/features/progress_dashboard/widgets/productivity_patterns_card.dart';
import 'package:writer/features/progress_dashboard/widgets/export_dialog.dart';
import 'package:writer/models/writing_progress.dart';

final progressAnalyticsServiceProvider = Provider<ProgressAnalyticsService>((
  ref,
) {
  return ProgressAnalyticsService();
});

final statsProvider = FutureProvider.autoDispose<WritingStats>((ref) async {
  final service = ref.watch(progressAnalyticsServiceProvider);
  return service.calculateStats();
});

final achievementsProvider = FutureProvider.autoDispose<List<Achievement>>((
  ref,
) async {
  final service = ref.watch(progressAnalyticsServiceProvider);
  await service.updateAchievementProgress();
  return service.getAchievements();
});

final productivityPatternsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final service = ref.watch(progressAnalyticsServiceProvider);
      return service.getProductivityPatterns();
    });

final writingTrendProvider = FutureProvider.autoDispose<List<WritingProgress>>((
  ref,
) async {
  final service = ref.watch(progressAnalyticsServiceProvider);
  return service.getWritingTrend(days: 30);
});

class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(statsProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(productivityPatternsProvider);
      ref.invalidate(writingTrendProvider);
    });
  }

  Future<void> _refreshDashboard() async {
    ref.invalidate(statsProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(productivityPatternsProvider);
    ref.invalidate(writingTrendProvider);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        onExportCSV: () async {
          final service = ref.read(progressAnalyticsServiceProvider);
          final csv = await service.exportToCSV();
          // Here you would save the file or share it
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'CSV exported successfully (${csv.length} characters)',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onExportReport: () async {
          final service = ref.read(progressAnalyticsServiceProvider);
          final report = await service.generateSummaryReport();
          // Here you would save the file or share it
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Report generated successfully (${report.length} characters)',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final statsAsync = ref.watch(statsProvider);
                  return statsAsync.when(
                    data: (stats) => OverviewStatsCard(stats: stats),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading stats: $error'),
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
                    'Achievements',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final achievementsAsync = ref.watch(achievementsProvider);
                  return achievementsAsync.when(
                    data: (achievements) {
                      final unlocked = achievements
                          .where((a) => a.isUnlocked)
                          .take(6)
                          .toList();
                      final locked = achievements
                          .where((a) => !a.isUnlocked)
                          .take(6)
                          .toList();

                      if (achievements.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text('No achievements yet'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          if (unlocked.isNotEmpty) ...[
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: unlocked.length,
                              itemBuilder: (context, index) {
                                return AchievementBadge(
                                  achievement: unlocked[index],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (locked.isNotEmpty) ...[
                            Text(
                              'Locked Achievements',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: locked.length,
                              itemBuilder: (context, index) {
                                return AchievementBadge(
                                  achievement: locked[index],
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading achievements: $error'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Writing Trends (30 Days)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final trendAsync = ref.watch(writingTrendProvider);
                  return trendAsync.when(
                    data: (trend) => WritingTrendCard(trendData: trend),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading trends: $error'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Productivity Patterns',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final patternsAsync = ref.watch(productivityPatternsProvider);
                  return patternsAsync.when(
                    data: (patterns) =>
                        ProductivityPatternsCard(patterns: patterns),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading patterns: $error'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
