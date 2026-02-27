import 'package:flutter/material.dart';

import 'package:writer/features/admin/admin_logs_utils.dart';
import 'admin_log_level_badge.dart';

class AdminLogsList extends StatelessWidget {
  const AdminLogsList({
    super.key,
    required this.logs,
    required this.scrollController,
    required this.onTapLog,
  });

  final List<Map<String, dynamic>> logs;
  final ScrollController scrollController;
  final void Function(
    BuildContext context,
    Map<String, dynamic> log,
    String level,
    String timestamp,
    String logger,
    String? requestId,
    String message,
  )
  onTapLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (listContext, index) {
        final log = logs[index];
        final level = (log['level'] as String?)?.toUpperCase() ?? 'INFO';
        final bgColor = getAdminLogLevelBackgroundColor(listContext, level);
        final message =
            log['message'] as String? ?? log['raw'] as String? ?? '';
        final timestamp = log['timestamp'] as String? ?? '';
        final logger = log['logger'] as String? ?? '';
        final requestId = log['request_id'] as String?;

        return Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              onTapLog(
                listContext,
                log,
                level,
                timestamp,
                logger,
                requestId,
                message,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      timestamp.isNotEmpty ? timestamp.split(',')[0] : '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AdminLogLevelBadge(level: level),
                            const SizedBox(width: 10),
                            if (logger.isNotEmpty)
                              Expanded(
                                child: Text(
                                  logger,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectionArea(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
