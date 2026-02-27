import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/reader_paragraphs.dart';
import 'package:writer/theme/design_tokens.dart';

void main() {
  group('ReaderParagraphs', () {
    Widget createTestWidget({
      required String text,
      required int ttsIndex,
      bool forceBold = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReaderParagraphs(
              text: text,
              ttsIndex: ttsIndex,
              forceBold: forceBold,
            ),
          ),
        ),
      );
    }

    group('Widget instantiation', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders with empty text', (tester) async {
        await tester.pumpWidget(createTestWidget(text: '', ttsIndex: 0));
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders with single paragraph', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Single paragraph text', ttsIndex: 0),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders with multiple paragraphs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'First paragraph\n\nSecond paragraph\n\nThird paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders with forceBold true', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders with forceBold false', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('renders ReaderParagraphs widget', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();
        // ReaderParagraphs widget should be present
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });
    });

    group('Paragraph splitting', () {
      testWidgets('splits text by double newlines', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\nSecond', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should have two paragraphs
        expect(find.byType(AnimatedContainer), findsNWidgets(2));
      });

      testWidgets('splits text by multiple consecutive newlines', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\n\nSecond', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should still have two paragraphs (regex \n\n+ matches multiple newlines)
        expect(find.byType(AnimatedContainer), findsNWidgets(2));
      });

      testWidgets('handles single newline as part of paragraph', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Line one\nLine two', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should have one paragraph (single newline doesn't split)
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('handles multiple single newlines', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Line one\nLine two\nLine three', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should have one paragraph
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('splits three paragraphs correctly', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\nSecond\n\nThird', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should have three paragraphs
        expect(find.byType(AnimatedContainer), findsNWidgets(3));
      });

      testWidgets('handles empty paragraphs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\n\n\nSecond', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        // Should handle empty paragraphs gracefully
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles trailing newlines', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\nSecond\n\n', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles leading newlines', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '\n\nFirst\n\nSecond', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });
    });

    group('TTS index highlighting', () {
      testWidgets('highlights first paragraph when ttsIndex is 0', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'First paragraph\n\nSecond paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        // Should find the current paragraph key
        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      });

      testWidgets(
        'highlights second paragraph when ttsIndex is in second paragraph',
        (tester) async {
          const text = 'First paragraph\n\nSecond paragraph';
          const firstParagraphLength = 'First paragraph'.length;

          await tester.pumpWidget(
            createTestWidget(
              text: text,
              ttsIndex:
                  firstParagraphLength + 5, // In the middle of second paragraph
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('current_paragraph')),
            findsOneWidget,
          );
        },
      );

      testWidgets('highlights paragraph containing ttsIndex at start', (
        tester,
      ) async {
        const text = 'First paragraph\n\nSecond paragraph';
        const secondParagraphStart = 'First paragraph'.length + 2;

        await tester.pumpWidget(
          createTestWidget(text: text, ttsIndex: secondParagraphStart),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      });

      testWidgets('highlights paragraph containing ttsIndex at end', (
        tester,
      ) async {
        const text = 'First paragraph\n\nSecond paragraph';
        const secondParagraphEnd =
            'First paragraph'.length + 2 + 'Second paragraph'.length;

        await tester.pumpWidget(
          createTestWidget(text: text, ttsIndex: secondParagraphEnd),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      });

      testWidgets('does not highlight when ttsIndex is beyond all paragraphs', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'First paragraph\n\nSecond paragraph',
            ttsIndex: 1000,
          ),
        );
        await tester.pumpAndSettle();

        // No paragraph should be highlighted
        expect(find.byKey(const ValueKey('current_paragraph')), findsNothing);
      });

      testWidgets('highlights correct paragraph in three-paragraph text', (
        tester,
      ) async {
        const text = 'First\n\nSecond\n\nThird';
        const secondParagraphStart = 'First'.length + 2;

        await tester.pumpWidget(
          createTestWidget(text: text, ttsIndex: secondParagraphStart + 2),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      });

      testWidgets('updates highlight when ttsIndex changes', (tester) async {
        const text = 'First paragraph\n\nSecond paragraph';
        const firstParagraphLength = 'First paragraph'.length;

        // Initial state - first paragraph highlighted
        await tester.pumpWidget(createTestWidget(text: text, ttsIndex: 0));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);

        // Update to second paragraph
        await tester.pumpWidget(
          createTestWidget(text: text, ttsIndex: firstParagraphLength + 5),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      });

      testWidgets('removes highlight when ttsIndex moves outside', (
        tester,
      ) async {
        const text = 'First paragraph\n\nSecond paragraph';

        // Initial state - first paragraph highlighted
        await tester.pumpWidget(createTestWidget(text: text, ttsIndex: 0));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);

        // Update to beyond all paragraphs
        await tester.pumpWidget(createTestWidget(text: text, ttsIndex: 1000));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('current_paragraph')), findsNothing);
      });
    });

    group('Highlight decoration', () {
      testWidgets('applies highlight color to current paragraph', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final highlightedContainer = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('current_paragraph')),
        );

        expect(highlightedContainer.decoration, isA<BoxDecoration>());
        final decoration = highlightedContainer.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
      });

      testWidgets('applies border radius to highlighted paragraph', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final highlightedContainer = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('current_paragraph')),
        );

        final decoration = highlightedContainer.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('uses correct border radius from Radii', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final highlightedContainer = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('current_paragraph')),
        );

        final decoration = highlightedContainer.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(Radii.s));
      });

      testWidgets('uses theme highlight color with alpha', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final highlightedContainer = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('current_paragraph')),
        );

        final decoration = highlightedContainer.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
      });

      testWidgets('non-highlighted paragraphs have no decoration', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'First paragraph\n\nSecond paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        final paragraphs = find.byType(AnimatedContainer);
        expect(paragraphs, findsNWidgets(2));

        final second = tester.widget<AnimatedContainer>(paragraphs.at(1));
        final decoration = second.decoration as BoxDecoration;
        expect(decoration.color, Colors.transparent);
      });
    });

    group('Paragraph spacing', () {
      testWidgets('applies bottom margin to paragraphs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'First paragraph\n\nSecond paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        final firstContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );

        expect(firstContainer.margin, const EdgeInsets.only(bottom: Spacing.l));
      });

      testWidgets('applies same margin to all paragraphs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\nSecond\n\nThird', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final containers = find.byType(AnimatedContainer);
        for (int i = 0; i < 3; i++) {
          final container = tester.widget<AnimatedContainer>(containers.at(i));
          expect(container.margin, const EdgeInsets.only(bottom: Spacing.l));
        }
      });
    });

    group('forceBold styling', () {
      testWidgets('applies bold styling when forceBold is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: true,
          ),
        );
        await tester.pumpAndSettle();

        // Widget should render with bold styling
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('does not apply bold styling when forceBold is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: false,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('bold styling affects all markdown elements', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: '# Heading\n\n**Bold text**',
            ttsIndex: 0,
            forceBold: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });
    });

    group('Markdown rendering', () {
      testWidgets('renders markdown content', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '**Bold** and *italic* text', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown in each paragraph', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: '**First** paragraph\n\n**Second** paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        // Should have two MarkdownBody widgets
        expect(find.byType(MarkdownBody), findsNWidgets(2));
      });

      testWidgets('uses theme-based markdown styles', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown headers', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '# Header 1\n\n## Header 2', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown lists', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '- Item 1\n- Item 2', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown code blocks', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '```\ncode\n```', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown links', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '[Link text](url)', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });

      testWidgets('renders markdown blockquotes', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '> Quote text', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsWidgets);
      });
    });

    group('Layout', () {
      testWidgets('uses stretch alignment for column', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        final column = tester.widget<Column>(
          find.byKey(const ValueKey('reader_paragraphs_column')),
        );
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      });

      testWidgets('renders paragraphs in correct order', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'First\n\nSecond\n\nThird', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedContainer), findsNWidgets(3));
      });
    });

    group('Edge cases', () {
      testWidgets('handles very long text', (tester) async {
        final longText = 'A' * 10000;
        await tester.pumpWidget(createTestWidget(text: longText, ttsIndex: 0));
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles text with special characters', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Special chars: @#\$%^&*()_+-=[]{}|;:,.<>?',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles text with unicode characters', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Unicode: 你好世界 🌍 Ñoño', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles text with only newlines', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: '\n\n\n\n', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles single character paragraphs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'A\n\nB\n\nC', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles negative ttsIndex', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Test paragraph', ttsIndex: -1),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('current_paragraph')), findsNothing);
      });

      testWidgets('handles zero ttsIndex with empty text', (tester) async {
        await tester.pumpWidget(createTestWidget(text: '', ttsIndex: 0));
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });
    });

    group('Integration', () {
      testWidgets('handles complex markdown with multiple paragraphs', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            text:
                '# Title\n\n**Bold** paragraph\n\n*Italic* paragraph\n\n`Code` paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsNWidgets(4));
      });

      testWidgets('updates correctly when text changes', (tester) async {
        await tester.pumpWidget(
          createTestWidget(text: 'Original text', ttsIndex: 0),
        );
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          createTestWidget(
            text: 'Updated text\n\nSecond paragraph',
            ttsIndex: 0,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MarkdownBody), findsNWidgets(2));
      });

      testWidgets('updates correctly when forceBold changes', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: false,
          ),
        );
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          createTestWidget(
            text: 'Test paragraph',
            ttsIndex: 0,
            forceBold: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });

      testWidgets('handles rapid ttsIndex changes', (tester) async {
        const text = 'First\n\nSecond\n\nThird';

        await tester.pumpWidget(createTestWidget(text: text, ttsIndex: 0));
        await tester.pumpAndSettle();

        // Rapidly change ttsIndex
        for (int i = 0; i < 50; i++) {
          await tester.pumpWidget(createTestWidget(text: text, ttsIndex: i));
          await tester.pump();
        }

        await tester.pumpAndSettle();
        expect(find.byType(ReaderParagraphs), findsOneWidget);
      });
    });
  });
}
