class Summary {
  final String id;
  final String novelId;
  final int idx;
  final String? title;
  final String? sentenceSummary;
  final String? paragraphSummary;
  final String? pageSummary;
  final String? expandedSummary;
  final String languageCode;

  Summary({
    required this.id,
    required this.novelId,
    required this.idx,
    this.title,
    this.sentenceSummary,
    this.paragraphSummary,
    this.pageSummary,
    this.expandedSummary,
    this.languageCode = 'en',
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] as String,
      novelId: json['novel_id'] as String,
      idx: json['idx'] as int,
      title: json['title'] as String?,
      sentenceSummary: json['sentence_summary'] as String?,
      paragraphSummary: json['paragraph_summary'] as String?,
      pageSummary: json['page_summary'] as String?,
      expandedSummary: json['expanded_summary'] as String?,
      languageCode: json['language_code'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'sentence_summary': sentenceSummary,
      'paragraph_summary': paragraphSummary,
      'page_summary': pageSummary,
      'expanded_summary': expandedSummary,
      'language_code': languageCode,
    };
  }

  Summary copyWith({
    String? id,
    String? novelId,
    int? idx,
    String? title,
    String? sentenceSummary,
    String? paragraphSummary,
    String? pageSummary,
    String? expandedSummary,
    String? languageCode,
  }) {
    return Summary(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      idx: idx ?? this.idx,
      title: title ?? this.title,
      sentenceSummary: sentenceSummary ?? this.sentenceSummary,
      paragraphSummary: paragraphSummary ?? this.paragraphSummary,
      pageSummary: pageSummary ?? this.pageSummary,
      expandedSummary: expandedSummary ?? this.expandedSummary,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
