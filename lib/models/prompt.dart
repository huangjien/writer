class Prompt {
  final String id;
  final String? userId;
  final String promptKey;
  final String language;
  final String content;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Prompt({
    required this.id,
    required this.userId,
    required this.promptKey,
    required this.language,
    required this.content,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    final updated = json['updated_at'];
    return Prompt(
      id: (json['id'] ?? '') as String,
      userId: json['user_id'] as String?,
      promptKey: (json['prompt_key'] ?? '') as String,
      language: (json['language'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      isPublic: (json['is_public'] ?? false) as bool,
      createdAt: created is String ? DateTime.tryParse(created) : null,
      updatedAt: updated is String ? DateTime.tryParse(updated) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'prompt_key': promptKey,
      'language': language,
      'content': content,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static bool isValidPromptKey(String key) {
    final re = RegExp(r'^system\.(beta|qa)\.[a-z]+$');
    return re.hasMatch(key);
  }

  static bool isValidLanguage(String lang) {
    final re = RegExp(r'^[a-z]{2,3}(-[A-Za-z]{2,4})?$');
    return re.hasMatch(lang);
  }
}
