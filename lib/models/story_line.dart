class StoryLine {
  final String id;
  final String title;
  final String? description;
  final String content;
  final Map<String, dynamic>? usageRules;
  final List<double>? embedding;
  final String? language;
  final bool? isPublic;
  final bool? locked;
  final String? ownerId;
  final DateTime? createdAt;

  const StoryLine({
    required this.id,
    required this.title,
    this.description,
    required this.content,
    this.usageRules,
    this.embedding,
    this.language,
    this.isPublic,
    this.locked,
    this.ownerId,
    this.createdAt,
  });

  factory StoryLine.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'];
    List<double>? emb;
    final e = map['embedding'];
    if (e is List) {
      emb = e.map((v) {
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }).toList();
    }
    return StoryLine(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      content: (map['content'] ?? '') as String,
      usageRules: map['usage_rules'] is Map<String, dynamic>
          ? (map['usage_rules'] as Map<String, dynamic>)
          : (map['usage_rules'] is Map
                ? Map<String, dynamic>.from(map['usage_rules'] as Map)
                : null),
      embedding: emb,
      language: map['language'] as String?,
      isPublic: map['is_public'] as bool?,
      locked: map['locked'] as bool?,
      ownerId: map['owner_id'] as String?,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
      'embedding': embedding,
      'language': language,
      'is_public': isPublic,
      'locked': locked,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
