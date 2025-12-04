class SceneNote {
  final String id;
  final String novelId;
  final int idx;
  final String? title;
  final String? sceneSummaries;
  final String? sceneSynopses;
  final String languageCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SceneNote({
    required this.id,
    required this.novelId,
    required this.idx,
    this.title,
    this.sceneSummaries,
    this.sceneSynopses,
    this.languageCode = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory SceneNote.fromRow(Map<String, dynamic> row) {
    return SceneNote(
      id: row['id'] as String,
      novelId: row['novel_id'] as String,
      idx: row['idx'] as int,
      title: row['title'] as String?,
      sceneSummaries: row['scene_summaries'] as String?,
      sceneSynopses: row['scene_synopses'] as String?,
      languageCode: (row['language_code'] as String?) ?? 'en',
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'scene_summaries': sceneSummaries,
      'scene_synopses': sceneSynopses,
      'language_code': languageCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
