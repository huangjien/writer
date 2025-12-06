import 'package:writer/models/chapter_cache.dart';

class Chapter {
  final String id;
  final String novelId;
  final int idx;
  final String? title;
  final String? content;
  final String? sha;

  const Chapter({
    required this.id,
    required this.novelId,
    required this.idx,
    this.title,
    this.content,
    this.sha,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      novelId: json['novel_id'],
      idx: json['idx'],
      title: json['title'],
      content: json['content'],
      sha: json['sha'],
    );
  }

  factory Chapter.fromCache(ChapterCache cache) {
    return Chapter(
      id: cache.chapterId,
      novelId: cache.novelId,
      idx: cache.idx,
      title: cache.title,
      content: cache.content,
      sha: null,
    );
  }

  Chapter copyWith({
    String? id,
    String? novelId,
    int? idx,
    String? title,
    String? content,
    String? sha,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      idx: idx ?? this.idx,
      title: title ?? this.title,
      content: content ?? this.content,
      sha: sha ?? this.sha,
    );
  }
}
