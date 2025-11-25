import 'package:writer/models/chapter_cache.dart';

class Chapter {
  final String id;
  final String novelId;
  final int idx;
  final String? title;
  final String? content;

  const Chapter({
    required this.id,
    required this.novelId,
    required this.idx,
    this.title,
    this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      novelId: json['novel_id'],
      idx: json['idx'],
      title: json['title'],
      content: json['content'],
    );
  }

  factory Chapter.fromCache(ChapterCache cache) {
    return Chapter(
      id: cache.chapterId,
      novelId: cache.novelId,
      idx: cache.idx,
      title: cache.title,
      content: cache.content,
    );
  }

  Chapter copyWith({
    String? id,
    String? novelId,
    int? idx,
    String? title,
    String? content,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      idx: idx ?? this.idx,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
