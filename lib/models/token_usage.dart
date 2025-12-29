class TokenUsageRecord {
  final String operationType;
  final String modelName;
  final int inputTokens;
  final int outputTokens;
  final String? requestId;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  TokenUsageRecord({
    required this.operationType,
    required this.modelName,
    required this.inputTokens,
    required this.outputTokens,
    this.requestId,
    this.metadata,
    this.createdAt,
  });

  factory TokenUsageRecord.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    }

    return TokenUsageRecord(
      operationType: json['operation_type'] as String,
      modelName: json['model_name'] as String,
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      requestId: json['request_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: createdAt,
    );
  }

  int get totalTokens => inputTokens + outputTokens;
}

class TokenUsage {
  final String userId;
  final int year;
  final int month;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final int requestCount;

  TokenUsage({
    required this.userId,
    required this.year,
    required this.month,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.requestCount,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      userId: json['user_id'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      requestCount: json['request_count'] as int,
    );
  }
}

class TokenUsageHistory {
  final List<TokenUsageRecord> records;
  final int totalCount;

  TokenUsageHistory({required this.records, required this.totalCount});

  factory TokenUsageHistory.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'] as List<dynamic>;
    final records = recordsList
        .map(
          (record) => TokenUsageRecord.fromJson(record as Map<String, dynamic>),
        )
        .toList();

    return TokenUsageHistory(
      records: records,
      totalCount: json['total_count'] as int,
    );
  }
}
