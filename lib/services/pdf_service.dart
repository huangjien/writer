import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/chapter.dart';
import '../models/novel.dart';

abstract class PdfPrinter {
  Future<void> sharePdf({required Uint8List bytes, required String filename});
}

class DefaultPdfPrinter implements PdfPrinter {
  @override
  Future<void> sharePdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}

class PdfService {
  final AssetBundle assetBundle;
  final PdfPrinter printer;

  PdfService({AssetBundle? assetBundle, PdfPrinter? printer})
    : assetBundle = assetBundle ?? rootBundle,
      printer = printer ?? DefaultPdfPrinter();

  Future<void> generateAndSharePdf({
    required Novel novel,
    required List<Chapter> chapters,
    required String Function(String) l10nByAuthor,
    required String l10nChapter,
    required String l10nNovel,
    required String l10nLanguageLabel,
    required String l10nTableOfContents,
    required String Function(int, int) l10nPageOfTotal,
  }) async {
    final notoRegular = pw.Font.ttf(
      await assetBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
    );
    final notoBold = pw.Font.ttf(
      await assetBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
    );
    final pdfTheme = pw.ThemeData.withFont(base: notoRegular, bold: notoBold);

    final doc = pw.Document();

    // Title Page
    doc.addPage(
      pw.Page(
        theme: pdfTheme,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                novel.title,
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if ((novel.author ?? '').trim().isNotEmpty)
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 12),
                  child: pw.Text(
                    l10nByAuthor(novel.author!),
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ),
              ),
            pw.Spacer(),
            pw.Text(l10nLanguageLabel),
          ],
        ),
      ),
    );

    // Content with TOC
    doc.addPage(
      pw.MultiPage(
        theme: pdfTheme,
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(novel.title, style: const pw.TextStyle(fontSize: 12)),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            l10nPageOfTotal(context.pageNumber, context.pagesCount),
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
        build: (context) {
          final List<pw.Widget> content = [];

          // Table of Contents
          content.add(pw.Header(level: 0, text: l10nTableOfContents));

          for (final c in chapters) {
            final heading = (c.title == null || c.title!.trim().isEmpty)
                ? '$l10nChapter ${c.idx}'
                : '$l10nChapter ${c.idx}: ${c.title}';
            final anchorName = 'chapter-${c.idx}';
            content.add(
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Link(
                        destination: anchorName,
                        child: pw.Text(heading),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          content.add(pw.SizedBox(height: 20));

          // Chapters
          content.add(pw.Header(level: 0, text: novel.title));

          for (final c in chapters) {
            final heading = (c.title == null || c.title!.trim().isEmpty)
                ? '$l10nChapter ${c.idx}'
                : '$l10nChapter ${c.idx}: ${c.title}';
            final anchorName = 'chapter-${c.idx}';
            content.add(
              pw.Anchor(
                name: anchorName,
                child: pw.Header(level: 1, text: heading),
              ),
            );
            final body = (c.content ?? '').trim();
            if (body.isNotEmpty) {
              content.add(pw.Paragraph(text: body));
            }
          }
          return content;
        },
      ),
    );

    final bytes = await doc.save();
    await printer.sharePdf(
      bytes: bytes,
      filename: '${novel.title.replaceAll(' ', '_')}-${novel.id}.pdf',
    );
  }
}
