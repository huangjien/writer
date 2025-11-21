class Scene {
  final String novelId;
  final String title;
  final String? location;
  final String? summary;

  const Scene({
    required this.novelId,
    required this.title,
    this.location,
    this.summary,
  });

  Map<String, dynamic> toMap() => {
    'novel_id': novelId,
    'title': title,
    'location': location,
    'summary': summary,
  };

  factory Scene.fromMap(Map<String, dynamic> map) => Scene(
    novelId: map['novel_id'] as String,
    title: map['title'] as String,
    location: map['location'] as String?,
    summary: map['summary'] as String?,
  );
}
