import 'package:flutter/material.dart';
import 'package:writer/models/character_profile.dart';

class CharacterProfileCard extends StatelessWidget {
  final CharacterProfile profile;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CharacterProfileCard({
    super.key,
    required this.profile,
    required this.onDelete,
    required this.onTap,
  });

  Color _getConsistencyColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final consistencyColor = _getConsistencyColor(profile.consistencyScore);
    final consistencyPercentage = (profile.consistencyScore * 100);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (profile.role != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.work,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.role!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: consistencyColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: consistencyColor.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          consistencyPercentage >= 80
                              ? Icons.check_circle
                              : consistencyPercentage >= 60
                              ? Icons.warning
                              : Icons.error,
                          size: 16,
                          color: consistencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${consistencyPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: consistencyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete Character',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(
                    context,
                    'Appearances',
                    '${profile.totalAppearances}',
                    Icons.visibility,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    'Traits',
                    '${profile.personalityTraits.length + profile.physicalTraits.length}',
                    Icons.psychology,
                    Colors.purple,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    'Relationships',
                    '${profile.relationships.length}',
                    Icons.people,
                    Colors.green,
                  ),
                ],
              ),
              if (profile.personalityTraits.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.personalityTraits
                      .take(3)
                      .map(
                        (trait) => Chip(
                          label: Text(
                            trait,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                if (profile.personalityTraits.length > 3)
                  Chip(
                    label: Text(
                      '+${profile.personalityTraits.length - 3} more',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey.shade100,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
              if (profile.inconsistentTraits.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${profile.inconsistentTraits.length} inconsistent trait${profile.inconsistentTraits.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
