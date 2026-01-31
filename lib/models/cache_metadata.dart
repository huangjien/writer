class CacheMetadata {
  final String key;
  final DateTime lastUpdated;
  final DateTime? lastSynced;

  CacheMetadata({
    required this.key,
    required this.lastUpdated,
    this.lastSynced,
  });

  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      key: json['key'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastSynced: json['lastSynced'] != null
          ? DateTime.parse(json['lastSynced'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'lastUpdated': lastUpdated.toIso8601String(),
    if (lastSynced != null) 'lastSynced': lastSynced!.toIso8601String(),
  };

  CacheMetadata copyWith({
    String? key,
    DateTime? lastUpdated,
    DateTime? lastSynced,
  }) {
    return CacheMetadata(
      key: key ?? this.key,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  bool isExpired({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(lastUpdated) > maxAge;
  }
}
