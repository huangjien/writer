import 'package:flutter/material.dart';
import 'package:writer/models/writing_progress.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadge({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final color = _getTypeColor(achievement.type);

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Card(
        elevation: isUnlocked ? 2 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(context, color, isUnlocked),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? color : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (achievement.description.isNotEmpty)
                  Text(
                    achievement.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                if (achievement.progress != null && achievement.target != null)
                  _buildProgressBar(context, color, isUnlocked),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, Color color, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withValues(alpha: 0.2) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(achievement.type),
        color: isUnlocked ? color : Colors.grey[500],
        size: 28,
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Color color, bool isUnlocked) {
    final progress = achievement.progressPercentage;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            isUnlocked ? color : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.progress}/${achievement.target}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isUnlocked ? color : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.wordCount:
        return Colors.blue;
      case AchievementType.streak:
        return Colors.orange;
      case AchievementType.consistency:
        return Colors.green;
      case AchievementType.milestone:
        return Colors.purple;
      case AchievementType.special:
        return Colors.amber;
    }
  }

  IconData _getTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.wordCount:
        return Icons.edit;
      case AchievementType.streak:
        return Icons.whatshot;
      case AchievementType.consistency:
        return Icons.calendar_today;
      case AchievementType.milestone:
        return Icons.military_tech;
      case AchievementType.special:
        return Icons.stars;
    }
  }
}
