class TemplateItem {
  final String novelId;
  final String name;
  final String? description;

  const TemplateItem({
    required this.novelId,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'novel_id': novelId,
    'name': name,
    'description': description,
  };

  factory TemplateItem.fromMap(Map<String, dynamic> map) => TemplateItem(
    novelId: map['novel_id'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
  );
}
