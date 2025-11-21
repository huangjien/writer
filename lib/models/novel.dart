class Novel {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String languageCode;
  final bool isPublic;

  const Novel({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    required this.languageCode,
    required this.isPublic,
  });

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String?,
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      languageCode: map['language_code'] as String? ?? 'en',
      isPublic: map['is_public'] as bool? ?? true,
    );
  }

  Novel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      languageCode: languageCode ?? this.languageCode,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
