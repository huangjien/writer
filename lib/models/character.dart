class Character {
  final String novelId;
  final String name;
  final String? role;
  final String? bio;

  const Character({
    required this.novelId,
    required this.name,
    this.role,
    this.bio,
  });

  Map<String, dynamic> toMap() => {
    'novel_id': novelId,
    'name': name,
    'role': role,
    'bio': bio,
  };

  factory Character.fromMap(Map<String, dynamic> map) => Character(
    novelId: map['novel_id'] as String,
    name: map['name'] as String,
    role: map['role'] as String?,
    bio: map['bio'] as String?,
  );
}
