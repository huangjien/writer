import 'package:flutter/material.dart';
import '../admin_logs_utils.dart';

class AdminLogLevelBadge extends StatelessWidget {
  const AdminLogLevelBadge({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final badgeColor = getAdminLogLevelColor(context, level);
    final badgeBgColor = getAdminLogLevelBackgroundColor(context, level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
