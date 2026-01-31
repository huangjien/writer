import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/services/pdf_service.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';

class MockRootBundle extends Mock implements AssetBundle {}

class MockPdfPrinter extends Mock implements PdfPrinter {}

void main() {
  late PdfService pdfService;
  late MockRootBundle mockRootBundle;
  late MockPdfPrinter mockPrinter;
  late ByteData regularFontData;
  late ByteData boldFontData;

  setUpAll(() async {
    final regularFile = File('assets/fonts/NotoSansSC-Regular.ttf');
    final boldFile = File('assets/fonts/NotoSansSC-Bold.ttf');

    if (await regularFile.exists()) {
      final regularBytes = await regularFile.readAsBytes();
      regularFontData = ByteData.sublistView(regularBytes);
    }

    if (await boldFile.exists()) {
      final boldBytes = await boldFile.readAsBytes();
      boldFontData = ByteData.sublistView(boldBytes);
    }
  });

  setUp(() {
    mockRootBundle = MockRootBundle();
    mockPrinter = MockPdfPrinter();

    pdfService = PdfService(assetBundle: mockRootBundle, printer: mockPrinter);

    registerFallbackValue('');
    registerFallbackValue(Uint8List(0));
  });

  group('PdfService', () {
    setUp(() {
      when(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).thenAnswer((_) async => regularFontData);
      when(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
      ).thenAnswer((_) async => boldFontData);
      when(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).thenAnswer((_) async {});
    });

    test('generates PDF with title page containing novel title', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'Test content for chapter 1',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test(
      'generates PDF with author information when author is provided',
      () async {
        final novel = const Novel(
          id: '1',
          title: 'Test Novel',
          author: 'Test Author',
          languageCode: 'zh',
          isPublic: true,
        );

        final chapters = [
          const Chapter(
            id: '1',
            novelId: '1',
            idx: 1,
            title: 'Chapter 1',
            content: 'Test content',
          ),
        ];

        await pdfService.generateAndSharePdf(
          novel: novel,
          chapters: chapters,
          l10nByAuthor: (author) => 'By $author',
          l10nChapter: 'Chapter',
          l10nNovel: 'Novel',
          l10nLanguageLabel: 'Language: zh',
          l10nTableOfContents: 'Table of Contents',
          l10nPageOfTotal: (page, total) => '$page of $total',
        );

        verify(
          () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
        ).called(1);
        verify(
          () => mockRootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
        ).called(1);
        verify(
          () => mockPrinter.sharePdf(
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
          ),
        ).called(1);
      },
    );

    test('handles novel with empty or null author', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: '',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'Test content',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('handles novel with whitespace-only author', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: '   ',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'Test content',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
    });

    test('generates PDF with table of contents', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'Content 1',
        ),
        const Chapter(
          id: '2',
          novelId: '1',
          idx: 2,
          title: 'Chapter 2',
          content: 'Content 2',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('handles chapters with empty or null titles', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: '',
          content: 'Content 1',
        ),
        const Chapter(
          id: '2',
          novelId: '1',
          idx: 2,
          title: null,
          content: 'Content 2',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('handles chapters with empty or null content', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: '',
        ),
        const Chapter(
          id: '2',
          novelId: '1',
          idx: 2,
          title: 'Chapter 2',
          content: null,
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('handles chapters with whitespace-only content', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: '   ',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
    });

    test('generates PDF with multiple chapters', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = List.generate(
        10,
        (i) => Chapter(
          id: 'id_$i',
          novelId: '1',
          idx: i + 1,
          title: 'Chapter ${i + 1}',
          content: 'Content for chapter ${i + 1}',
        ),
      );

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
      ).called(1);
    });

    test('generates PDF with custom localization strings', () async {
      final novel = const Novel(
        id: '1',
        title: '测试小说',
        author: '测试作者',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: '第一章',
          content: '测试内容',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => '作者: $author',
        l10nChapter: '第',
        l10nNovel: '小说',
        l10nLanguageLabel: '语言: zh',
        l10nTableOfContents: '目录',
        l10nPageOfTotal: (page, total) => '$page / $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('handles empty chapter list', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = <Chapter>[];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test(
      'generates correct filename with spaces replaced by underscores',
      () async {
        final novel = const Novel(
          id: '1',
          title: 'Test Novel With Spaces',
          author: 'Test Author',
          languageCode: 'zh',
          isPublic: true,
        );

        final chapters = [
          const Chapter(
            id: '1',
            novelId: '1',
            idx: 1,
            title: 'Chapter 1',
            content: 'Content',
          ),
        ];

        await pdfService.generateAndSharePdf(
          novel: novel,
          chapters: chapters,
          l10nByAuthor: (author) => 'By $author',
          l10nChapter: 'Chapter',
          l10nNovel: 'Novel',
          l10nLanguageLabel: 'Language: zh',
          l10nTableOfContents: 'Table of Contents',
          l10nPageOfTotal: (page, total) => '$page of $total',
        );

        verify(
          () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
        ).called(1);
        verify(
          () => mockPrinter.sharePdf(
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
          ),
        ).called(1);
      },
    );

    test('includes page numbers in footer', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'A' * 5000,
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => 'Page $page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });

    test('includes novel title in header', () async {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel Header',
        author: 'Test Author',
        languageCode: 'zh',
        isPublic: true,
      );

      final chapters = [
        const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Chapter 1',
          content: 'Content',
        ),
      ];

      await pdfService.generateAndSharePdf(
        novel: novel,
        chapters: chapters,
        l10nByAuthor: (author) => 'By $author',
        l10nChapter: 'Chapter',
        l10nNovel: 'Novel',
        l10nLanguageLabel: 'Language: zh',
        l10nTableOfContents: 'Table of Contents',
        l10nPageOfTotal: (page, total) => '$page of $total',
      );

      verify(
        () => mockRootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ).called(1);
      verify(
        () => mockPrinter.sharePdf(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).called(1);
    });
  });
}
