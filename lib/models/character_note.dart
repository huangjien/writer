class CharacterNote {
  final String id;
  final String novelId;
  final int idx;
  final String? title;
  final String? characterSummaries;
  final String? characterSynopses;
  final String languageCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterNote({
    required this.id,
    required this.novelId,
    required this.idx,
    this.title,
    this.characterSummaries,
    this.characterSynopses,
    this.languageCode = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterNote.fromRow(Map<String, dynamic> row) {
    return CharacterNote(
      id: row['id'] as String,
      novelId: row['novel_id'] as String,
      idx: row['idx'] as int,
      title: row['title'] as String?,
      characterSummaries: row['character_summaries'] as String?,
      characterSynopses: row['character_synopses'] as String?,
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
      'character_summaries': characterSummaries,
      'character_synopses': characterSynopses,
      'language_code': languageCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
