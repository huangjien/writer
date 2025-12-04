class CharacterTemplateRow {
  final String id;
  final int idx;
  final String? title;
  final String? characterSummaries;
  final String? characterSynopses;
  final String languageCode;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterTemplateRow({
    required this.id,
    required this.idx,
    this.title,
    this.characterSummaries,
    this.characterSynopses,
    this.languageCode = 'en',
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterTemplateRow.fromRow(Map<String, dynamic> row) {
    return CharacterTemplateRow(
      id: row['id'] as String,
      idx: row['idx'] as int,
      title: row['title'] as String?,
      characterSummaries: row['character_summaries'] as String?,
      characterSynopses: row['character_synopses'] as String?,
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
      'character_summaries': characterSummaries,
      'character_synopses': characterSynopses,
      'language_code': languageCode,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
