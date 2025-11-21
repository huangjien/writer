class UserProgress {
  final String userId;
  final String novelId;
  final String chapterId;
  final double scrollOffset;
  final int ttsCharIndex;
  final DateTime updatedAt;

  const UserProgress({
    required this.userId,
    required this.novelId,
    required this.chapterId,
    required this.scrollOffset,
    required this.ttsCharIndex,
    required this.updatedAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['user_id'],
      novelId: json['novel_id'],
      chapterId: json['chapter_id'],
      scrollOffset: (json['scroll_offset'] as num).toDouble(),
      ttsCharIndex: json['tts_char_index'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'novel_id': novelId,
    'chapter_id': chapterId,
    'scroll_offset': scrollOffset,
    'tts_char_index': ttsCharIndex,
    'updated_at': updatedAt.toIso8601String(),
  };
}
