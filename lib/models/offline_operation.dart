enum OperationType {
  createChapter,
  updateChapter,
  deleteChapter,
  updateChapterIdx,
}

class OfflineOperation {
  final String id;
  final OperationType type;
  final String? chapterId; // null for create
  final String novelId;
  final Map<String, dynamic>? data; // Operation data payload
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final bool isPending;
  final String? baseSha; // SHA of base version for three-way merge

  const OfflineOperation({
    required this.id,
    required this.type,
    this.chapterId,
    required this.novelId,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.isPending = true,
    this.baseSha,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: OperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OperationType.updateChapter,
      ),
      chapterId: json['chapterId'] as String?,
      novelId: json['novelId'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
      isPending: json['isPending'] as bool? ?? true,
      baseSha: json['baseSha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'chapterId': chapterId,
      'novelId': novelId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
      'isPending': isPending,
      'baseSha': baseSha,
    };
  }

  OfflineOperation copyWith({
    String? id,
    OperationType? type,
    String? chapterId,
    String? novelId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
    bool? isPending,
    String? baseSha,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      chapterId: chapterId ?? this.chapterId,
      novelId: novelId ?? this.novelId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      isPending: isPending ?? this.isPending,
      baseSha: baseSha ?? this.baseSha,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineOperation &&
        other.id == id &&
        other.type == type &&
        other.chapterId == chapterId &&
        other.novelId == novelId &&
        other.retryCount == retryCount &&
        other.isPending == isPending &&
        other.baseSha == baseSha;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      chapterId,
      novelId,
      retryCount,
      isPending,
      baseSha,
    );
  }
}
