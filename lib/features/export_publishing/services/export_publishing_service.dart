import 'package:uuid/uuid.dart';
import 'package:writer/models/export_publishing.dart';

class ExportPublishingService {
  final Uuid _uuid = Uuid();
  final List<ExportJob> _exportJobs = [];
  final List<ExportFormat> _supportedFormats = ExportFormat.allFormats;

  Future<ExportJob> createExportJob({
    required String documentId,
    required String exportFormat,
    ExportSettings? settings,
  }) async {
    final job = ExportJob(
      id: _uuid.v4(),
      documentId: documentId,
      exportFormat: exportFormat,
      status: ExportStatus.pending,
      createdAt: DateTime.now(),
      settings: settings ?? ExportSettings(),
    );

    _exportJobs.add(job);
    return job;
  }

  Future<ExportJob> startExport(ExportJob job, String documentContent) async {
    final updatedJob = job.copyWith(status: ExportStatus.processing);

    _updateJob(updatedJob);

    try {
      final processedContent = await _processContent(
        documentContent,
        updatedJob.settings,
        updatedJob.exportFormat,
      );

      final filePath = await _saveToFile(
        processedContent,
        updatedJob.documentId,
        updatedJob.exportFormat,
      );

      final completedJob = updatedJob.copyWith(
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        filePath: filePath,
      );

      _updateJob(completedJob);
      return completedJob;
    } catch (e) {
      final failedJob = updatedJob.copyWith(
        status: ExportStatus.failed,
        completedAt: DateTime.now(),
        error: e.toString(),
      );

      _updateJob(failedJob);
      return failedJob;
    }
  }

  Future<String> _processContent(
    String content,
    ExportSettings settings,
    String format,
  ) async {
    var processed = content;

    if (settings.removeExtraWhitespace) {
      processed = _removeExtraWhitespace(processed);
    }

    if (settings.convertSmartQuotes) {
      processed = _convertSmartQuotes(processed);
    }

    switch (format) {
      case 'pdf':
        return await _convertToPDF(processed, settings);
      case 'docx':
        return await _convertToDOCX(processed, settings);
      case 'html':
        return await _convertToHTML(processed, settings);
      case 'epub':
        return await _convertToEPUB(processed, settings);
      case 'markdown':
        return await _convertToMarkdown(processed, settings);
      case 'txt':
      default:
        return processed;
    }
  }

  String _removeExtraWhitespace(String content) {
    return content
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  String _convertSmartQuotes(String content) {
    return content
        .replaceAll(''', "'")
        .replaceAll(''', "'")
        .replaceAll('"', '"')
        .replaceAll('"', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-');
  }

  Future<String> _convertToPDF(String content, ExportSettings settings) async {
    // print('Converting to PDF format...');
    await Future.delayed(const Duration(milliseconds: 100));

    final html = await _generateHTMLTemplate(content, settings);
    return 'PDF_FILE: document.pdf\n$html';
  }

  Future<String> _convertToDOCX(String content, ExportSettings settings) async {
    // print('Converting to DOCX format...');
    await Future.delayed(const Duration(milliseconds: 100));

    return 'DOCX_FILE: document.docx\n$content';
  }

  Future<String> _convertToHTML(String content, ExportSettings settings) async {
    // print('Converting to HTML format...');
    await Future.delayed(const Duration(milliseconds: 50));

    return await _generateHTMLTemplate(content, settings);
  }

  Future<String> _generateHTMLTemplate(
    String content,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );

    if (settings.includeTitle) {
      buffer.writeln('  <title>Document</title>');
    }

    if (settings.fontFamily != null || settings.fontSize != null) {
      buffer.writeln('  <style>');
      buffer.writeln('    body {');
      if (settings.fontFamily != null) {
        buffer.writeln('      font-family: ${settings.fontFamily};');
      }
      if (settings.fontSize != null) {
        buffer.writeln('      font-size: ${settings.fontSize}px;');
      }
      if (settings.lineHeight != null) {
        buffer.writeln('      line-height: ${settings.lineHeight};');
      }
      buffer.writeln('    }');

      if (settings.customCSS != null) {
        for (final css in settings.customCSS!) {
          buffer.writeln('    $css');
        }
      }

      buffer.writeln('  </style>');
    }

    buffer.writeln('</head>');
    buffer.writeln('<body>');

    if (settings.includeMetadata && settings.metadata != null) {
      buffer.writeln('  <div class="metadata">');
      for (final entry in settings.metadata!.entries) {
        buffer.writeln(
          '    <p><strong>${entry.key}:</strong> ${entry.value}</p>',
        );
      }
      buffer.writeln('  </div>');
    }

    buffer.writeln('  <div class="content">');
    buffer.writeln('    $content');
    buffer.writeln('  </div>');

    if (settings.includePageNumbers) {
      buffer.writeln('  <script>');
      buffer.writeln('    // Add page numbers');
      buffer.writeln('  </script>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  Future<String> _convertToEPUB(String content, ExportSettings settings) async {
    // print('Converting to EPUB format...');
    await Future.delayed(const Duration(milliseconds: 100));

    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<package xmlns="http://www.idpf.org/2007/opf" version="3.0">',
    );
    buffer.writeln('  <metadata>');
    buffer.writeln('    <title>Document</title>');
    buffer.writeln('    <language>en</language>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <manifest>');
    buffer.writeln(
      '    <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>',
    );
    buffer.writeln('  </manifest>');
    buffer.writeln('  <spine>');
    buffer.writeln('    <itemref idref="chapter1"/>');
    buffer.writeln('  </spine>');
    buffer.writeln('</package>');
    buffer.writeln('EPUB_CONTENT:');
    buffer.writeln(content);

    return buffer.toString();
  }

  Future<String> _convertToMarkdown(
    String content,
    ExportSettings settings,
  ) async {
    // print('Converting to Markdown format...');

    var markdown = content;

    markdown = markdown.replaceAll(RegExp(r'<h1[^>]*>(.*?)</h1>'), '# \$1');
    markdown = markdown.replaceAll(RegExp(r'<h2[^>]*>(.*?)</h2>'), '## \$1');
    markdown = markdown.replaceAll(RegExp(r'<h3[^>]*>(.*?)</h3>'), '### \$1');
    markdown = markdown.replaceAll(
      RegExp(r'<strong[^>]*>(.*?)</strong>'),
      '**\$1**',
    );
    markdown = markdown.replaceAll(RegExp(r'<em[^>]*>(.*?)</em>'), '*\$1*');
    markdown = markdown.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    markdown = markdown.replaceAll(RegExp(r'<p[^>]*>(.*?)</p>'), '\$1\n\n');

    return markdown;
  }

  Future<String> _saveToFile(
    String content,
    String documentId,
    String format,
  ) async {
    // print('Saving $format file for document $documentId...');
    await Future.delayed(const Duration(milliseconds: 50));

    final extension = _getExtension(format);
    final fileName = '$documentId$extension';

    return '/exports/$fileName';
  }

  String _getExtension(String format) {
    switch (format) {
      case 'pdf':
        return '.pdf';
      case 'docx':
        return '.docx';
      case 'html':
        return '.html';
      case 'epub':
        return '.epub';
      case 'markdown':
        return '.md';
      case 'txt':
      default:
        return '.txt';
    }
  }

  void _updateJob(ExportJob job) {
    final index = _exportJobs.indexWhere((j) => j.id == job.id);
    if (index != -1) {
      _exportJobs[index] = job;
    }
  }

  Future<List<ExportJob>> getExportHistory(String documentId) async {
    return _exportJobs.where((job) => job.documentId == documentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ExportJob?> getExportJob(String jobId) async {
    try {
      return _exportJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelExport(String jobId) async {
    final job = await getExportJob(jobId);
    if (job != null && job.status == ExportStatus.pending) {
      final cancelledJob = job.copyWith(
        status: ExportStatus.cancelled,
        completedAt: DateTime.now(),
      );
      _updateJob(cancelledJob);
    }
  }

  Future<void> deleteExportJob(String jobId) async {
    _exportJobs.removeWhere((job) => job.id == jobId);
  }

  List<ExportFormat> getSupportedFormats() {
    return _supportedFormats;
  }

  ExportFormat? getFormatById(String id) {
    try {
      return _supportedFormats.firstWhere((format) => format.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<PublishingMetadata> validateMetadata(
    PublishingMetadata metadata,
  ) async {
    if (metadata.title == null || metadata.title!.isEmpty) {
      throw Exception('Title is required for publishing');
    }

    if (metadata.author == null || metadata.author!.isEmpty) {
      throw Exception('Author name is required for publishing');
    }

    if (metadata.language != null && metadata.language!.length != 2) {
      throw Exception('Language code must be 2 characters (e.g., "en", "es")');
    }

    if (metadata.isbn != null && !_isValidISBN(metadata.isbn!)) {
      throw Exception('Invalid ISBN format');
    }

    return metadata;
  }

  bool _isValidISBN(String isbn) {
    final cleanISBN = isbn.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanISBN.length == 10) {
      return _validateISBN10(cleanISBN);
    } else if (cleanISBN.length == 13) {
      return _validateISBN13(cleanISBN);
    }

    return false;
  }

  bool _validateISBN10(String isbn) {
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      final digit = int.tryParse(isbn[i]);
      if (digit == null) return false;
      sum += digit * (10 - i);
    }

    final lastChar = isbn[9].toUpperCase();
    if (lastChar == 'X') {
      sum += 10;
    } else {
      final lastDigit = int.tryParse(lastChar);
      if (lastDigit == null) return false;
      sum += lastDigit;
    }

    return sum % 11 == 0;
  }

  bool _validateISBN13(String isbn) {
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      final digit = int.tryParse(isbn[i]);
      if (digit == null) return false;
      sum += digit * (i.isEven ? 1 : 3);
    }

    return sum % 10 == 0;
  }

  Future<String> generateTableOfContents(String content) async {
    final headings = <Map<String, dynamic>>[];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('# ')) {
        headings.add({'level': 1, 'text': line.substring(2), 'line': i});
      } else if (line.startsWith('## ')) {
        headings.add({'level': 2, 'text': line.substring(3), 'line': i});
      } else if (line.startsWith('### ')) {
        headings.add({'level': 3, 'text': line.substring(4), 'line': i});
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('# Table of Contents\n');

    for (final heading in headings) {
      final level = (heading['level'] as int) - 1;
      final indent = '  ' * level;
      buffer.writeln('$indent- ${heading['text']}');
    }

    return buffer.toString();
  }

  Future<List<String>> getExportPresets() async {
    return [
      'Standard Document',
      'Academic Paper',
      'Creative Writing',
      'Technical Manual',
      'Blog Post',
      'E-Book',
    ];
  }

  Future<ExportSettings> getPresetSettings(String presetName) async {
    switch (presetName) {
      case 'Standard Document':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: true,
          includePageNumbers: true,
          fontSize: 12.0,
          lineHeight: 1.5,
          paperSize: 'A4',
          margin: '1in',
        );

      case 'Academic Paper':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: true,
          includeTableOfContents: true,
          includePageNumbers: true,
          fontFamily: 'Times New Roman',
          fontSize: 12.0,
          lineHeight: 2.0,
          paperSize: 'Letter',
          margin: '1in',
          convertSmartQuotes: true,
          removeExtraWhitespace: true,
        );

      case 'Creative Writing':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: false,
          includePageNumbers: false,
          fontFamily: 'Georgia',
          fontSize: 11.0,
          lineHeight: 1.8,
          paperSize: 'Book',
          margin: '1.5in',
        );

      case 'Technical Manual':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: true,
          includeTableOfContents: true,
          includePageNumbers: true,
          fontFamily: 'Arial',
          fontSize: 10.0,
          lineHeight: 1.4,
          paperSize: 'A4',
          margin: '0.75in',
        );

      case 'Blog Post':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: false,
          includePageNumbers: false,
          fontSize: 14.0,
          lineHeight: 1.6,
        );

      case 'E-Book':
        return ExportSettings(
          includeTitle: true,
          includeMetadata: true,
          includeTableOfContents: true,
          includePageNumbers: false,
          fontSize: 12.0,
          lineHeight: 1.5,
        );

      default:
        return ExportSettings();
    }
  }

  Future<void> savePreset(String name, ExportSettings settings) async {
    // print('Saving preset: $name');
  }

  Future<void> deletePreset(String name) async {
    // print('Deleting preset: $name');
  }
}
