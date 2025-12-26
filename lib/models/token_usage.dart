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
