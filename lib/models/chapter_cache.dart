class ChapterCache {
  final String chapterId;
  final String novelId;
  final int idx;
  final String? title;
  final String content;
  final DateTime lastUpdated;

  ChapterCache({
    required this.chapterId,
    required this.novelId,
    required this.idx,
    this.title,
    required this.content,
    required this.lastUpdated,
  });

  factory ChapterCache.fromJson(Map<String, dynamic> json) {
    return ChapterCache(
      chapterId: json['chapterId'],
      novelId: json['novelId'],
      idx: json['idx'],
      title: json['title'],
      content: json['content'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'novelId': novelId,
    'idx': idx,
    'title': title,
    'content': content,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}
