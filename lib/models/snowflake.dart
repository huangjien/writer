class SnowflakeRefinementInput {
  final String novelId;
  final String summaryType;
  final String summaryContent;
  final String? userResponse;
  final String language;

  const SnowflakeRefinementInput({
    required this.novelId,
    required this.summaryType,
    required this.summaryContent,
    this.userResponse,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'novel_id': novelId,
      'summary_type': summaryType,
      'summary_content': summaryContent,
      if (userResponse != null) 'user_response': userResponse,
      'language': language,
    };
  }
}

class SnowflakeRefinementOutput {
  final String novelId;
  final String summaryContent;
  final String status;
  final String? aiQuestion;
  final List<String>? suggestions;
  final String? critique;
  final List<Map<String, String>>? history;

  final String? createdAt;
  final String? updatedAt;

  const SnowflakeRefinementOutput({
    required this.novelId,
    required this.summaryContent,
    required this.status,
    this.aiQuestion,
    this.suggestions,
    this.critique,
    this.history,
    this.createdAt,
    this.updatedAt,
  });

  factory SnowflakeRefinementOutput.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>>? hist;
    final rawHist = json['history'];
    if (rawHist is List) {
      hist = rawHist
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => {
              'role': (e['role'] ?? '').toString(),
              'content': (e['content'] ?? '').toString(),
            },
          )
          .toList();
    }
    return SnowflakeRefinementOutput(
      novelId: json['novel_id'] as String,
      summaryContent: json['summary_content'] as String,
      status: json['status'] as String,
      aiQuestion: json['ai_question'] as String?,
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      critique: json['critique'] as String?,
      history: hist,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
