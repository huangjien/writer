class SceneTemplateRow {
  final String id;
  final int idx;
  final String? title;
  final String? sceneSummaries;
  final String? sceneSynopses;
  final String languageCode;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SceneTemplateRow({
    required this.id,
    required this.idx,
    this.title,
    this.sceneSummaries,
    this.sceneSynopses,
    this.languageCode = 'en',
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SceneTemplateRow.fromRow(Map<String, dynamic> row) {
    return SceneTemplateRow(
      id: row['id'] as String,
      idx: row['idx'] as int,
      title: row['title'] as String?,
      sceneSummaries: row['scene_summaries'] as String?,
      sceneSynopses: row['scene_synopses'] as String?,
      languageCode: (row['language_code'] as String?) ?? 'en',
      createdBy: row['created_by'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'idx': idx,
      'title': title,
      'scene_summaries': sceneSummaries,
      'scene_synopses': sceneSynopses,
      'language_code': languageCode,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
