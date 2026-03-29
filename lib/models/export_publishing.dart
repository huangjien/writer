class ExportJob {
  final String id;
  final String documentId;
  final String exportFormat;
  final ExportStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? filePath;
  final String? error;
  final ExportSettings settings;

  ExportJob({
    required this.id,
    required this.documentId,
    required this.exportFormat,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.filePath,
    this.error,
    required this.settings,
  });

  bool get isCompleted => status == ExportStatus.completed;
  bool get hasFailed => status == ExportStatus.failed;

  Duration? get processingTime {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  ExportJob copyWith({
    String? id,
    String? documentId,
    String? exportFormat,
    ExportStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? filePath,
    String? error,
    ExportSettings? settings,
  }) {
    return ExportJob(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      exportFormat: exportFormat ?? this.exportFormat,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'export_format': exportFormat,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'file_path': filePath,
      'error': error,
      'settings': settings.toMap(),
    };
  }

  factory ExportJob.fromMap(Map<String, dynamic> map) {
    return ExportJob(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      exportFormat: map['export_format'] as String,
      status: ExportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExportStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      filePath: map['file_path'] as String?,
      error: map['error'] as String?,
      settings: ExportSettings.fromMap(map['settings'] as Map<String, dynamic>),
    );
  }
}

enum ExportStatus { pending, processing, completed, failed, cancelled }

class ExportSettings {
  final bool includeTitle;
  final bool includeMetadata;
  final bool includeTableOfContents;
  final bool includePageNumbers;
  final String? fontFamily;
  final double? fontSize;
  final double? lineHeight;
  final String? paperSize;
  final String? margin;
  final bool convertSmartQuotes;
  final bool removeExtraWhitespace;
  final List<String>? customCSS;
  final Map<String, String>? metadata;

  ExportSettings({
    this.includeTitle = true,
    this.includeMetadata = true,
    this.includeTableOfContents = false,
    this.includePageNumbers = true,
    this.fontFamily,
    this.fontSize,
    this.lineHeight,
    this.paperSize,
    this.margin,
    this.convertSmartQuotes = true,
    this.removeExtraWhitespace = true,
    this.customCSS,
    this.metadata,
  });

  ExportSettings copyWith({
    bool? includeTitle,
    bool? includeMetadata,
    bool? includeTableOfContents,
    bool? includePageNumbers,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    String? paperSize,
    String? margin,
    bool? convertSmartQuotes,
    bool? removeExtraWhitespace,
    List<String>? customCSS,
    Map<String, String>? metadata,
  }) {
    return ExportSettings(
      includeTitle: includeTitle ?? this.includeTitle,
      includeMetadata: includeMetadata ?? this.includeMetadata,
      includeTableOfContents:
          includeTableOfContents ?? this.includeTableOfContents,
      includePageNumbers: includePageNumbers ?? this.includePageNumbers,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paperSize: paperSize ?? this.paperSize,
      margin: margin ?? this.margin,
      convertSmartQuotes: convertSmartQuotes ?? this.convertSmartQuotes,
      removeExtraWhitespace:
          removeExtraWhitespace ?? this.removeExtraWhitespace,
      customCSS: customCSS ?? this.customCSS,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'include_title': includeTitle,
      'include_metadata': includeMetadata,
      'include_table_of_contents': includeTableOfContents,
      'include_page_numbers': includePageNumbers,
      'font_family': fontFamily,
      'font_size': fontSize,
      'line_height': lineHeight,
      'paper_size': paperSize,
      'margin': margin,
      'convert_smart_quotes': convertSmartQuotes,
      'remove_extra_whitespace': removeExtraWhitespace,
      'custom_css': customCSS,
      'metadata': metadata,
    };
  }

  factory ExportSettings.fromMap(Map<String, dynamic> map) {
    return ExportSettings(
      includeTitle: map['include_title'] as bool? ?? true,
      includeMetadata: map['include_metadata'] as bool? ?? true,
      includeTableOfContents:
          map['include_table_of_contents'] as bool? ?? false,
      includePageNumbers: map['include_page_numbers'] as bool? ?? true,
      fontFamily: map['font_family'] as String?,
      fontSize: (map['font_size'] as num?)?.toDouble(),
      lineHeight: (map['line_height'] as num?)?.toDouble(),
      paperSize: map['paper_size'] as String?,
      margin: map['margin'] as String?,
      convertSmartQuotes: map['convert_smart_quotes'] as bool? ?? true,
      removeExtraWhitespace: map['remove_extra_whitespace'] as bool? ?? true,
      customCSS: map['custom_css'] != null
          ? List<String>.from(map['custom_css'])
          : null,
      metadata: map['metadata'] != null
          ? Map<String, String>.from(map['metadata'])
          : null,
    );
  }
}

class ExportFormat {
  final String id;
  final String name;
  final String extension;
  final String mimeType;
  final String description;
  final bool supportsStyling;
  final bool supportsImages;
  final bool isRecommended;

  const ExportFormat({
    required this.id,
    required this.name,
    required this.extension,
    required this.mimeType,
    required this.description,
    required this.supportsStyling,
    required this.supportsImages,
    required this.isRecommended,
  });

  static const pdf = ExportFormat(
    id: 'pdf',
    name: 'PDF Document',
    extension: '.pdf',
    mimeType: 'application/pdf',
    description: 'Portable document format, preserves formatting',
    supportsStyling: true,
    supportsImages: true,
    isRecommended: true,
  );

  static const docx = ExportFormat(
    id: 'docx',
    name: 'Word Document',
    extension: '.docx',
    mimeType:
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    description: 'Microsoft Word format, easy to edit',
    supportsStyling: true,
    supportsImages: true,
    isRecommended: false,
  );

  static const txt = ExportFormat(
    id: 'txt',
    name: 'Plain Text',
    extension: '.txt',
    mimeType: 'text/plain',
    description: 'Simple text file, no formatting',
    supportsStyling: false,
    supportsImages: false,
    isRecommended: false,
  );

  static const html = ExportFormat(
    id: 'html',
    name: 'HTML Document',
    extension: '.html',
    mimeType: 'text/html',
    description: 'Web page format',
    supportsStyling: true,
    supportsImages: true,
    isRecommended: false,
  );

  static const epub = ExportFormat(
    id: 'epub',
    name: 'EPUB E-Book',
    extension: '.epub',
    mimeType: 'application/epub+zip',
    description: 'E-book format for readers',
    supportsStyling: true,
    supportsImages: true,
    isRecommended: false,
  );

  static const markdown = ExportFormat(
    id: 'markdown',
    name: 'Markdown',
    extension: '.md',
    mimeType: 'text/markdown',
    description: 'Lightweight markup language',
    supportsStyling: false,
    supportsImages: false,
    isRecommended: false,
  );

  static List<ExportFormat> get allFormats => [
    pdf,
    docx,
    txt,
    html,
    epub,
    markdown,
  ];
}

class PublishingMetadata {
  final String? title;
  final String? author;
  final String? description;
  final String? publisher;
  final String? language;
  final List<String>? tags;
  final String? isbn;
  final String? copyright;
  final DateTime? publishedDate;

  PublishingMetadata({
    this.title,
    this.author,
    this.description,
    this.publisher,
    this.language,
    this.tags,
    this.isbn,
    this.copyright,
    this.publishedDate,
  });

  PublishingMetadata copyWith({
    String? title,
    String? author,
    String? description,
    String? publisher,
    String? language,
    List<String>? tags,
    String? isbn,
    String? copyright,
    DateTime? publishedDate,
  }) {
    return PublishingMetadata(
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      isbn: isbn ?? this.isbn,
      copyright: copyright ?? this.copyright,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'publisher': publisher,
      'language': language,
      'tags': tags,
      'isbn': isbn,
      'copyright': copyright,
      'published_date': publishedDate?.toIso8601String(),
    };
  }

  factory PublishingMetadata.fromMap(Map<String, dynamic> map) {
    return PublishingMetadata(
      title: map['title'] as String?,
      author: map['author'] as String?,
      description: map['description'] as String?,
      publisher: map['publisher'] as String?,
      language: map['language'] as String?,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      isbn: map['isbn'] as String?,
      copyright: map['copyright'] as String?,
      publishedDate: map['published_date'] != null
          ? DateTime.parse(map['published_date'] as String)
          : null,
    );
  }
}
