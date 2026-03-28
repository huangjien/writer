import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/widgets/enhanced_markdown_body.dart';

void main() {
  group('EnhancedMarkdownBody Widget Tests', () {
    testWidgets('renders plain text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: 'Plain text content'),
          ),
        ),
      );

      expect(find.text('Plain text content'), findsOneWidget);
    });

    testWidgets('renders markdown headers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '# H1\n## H2\n### H3'),
          ),
        ),
      );

      expect(find.text('H1'), findsOneWidget);
      expect(find.text('H2'), findsOneWidget);
      expect(find.text('H3'), findsOneWidget);
    });

    testWidgets('renders markdown bold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '**bold**')),
        ),
      );

      expect(find.text('bold'), findsOneWidget);
    });

    testWidgets('renders markdown lists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '- Item 1\n- Item 2\n- Item 3'),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('renders markdown code blocks with language', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '```dart\nvoid main() {}\n```'),
          ),
        ),
      );

      expect(find.text('DART'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('renders markdown inline code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: 'This has `inline code`'),
          ),
        ),
      );

      expect(find.text('inline code'), findsOneWidget);
    });

    testWidgets('renders markdown blockquotes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '> This is a quote')),
        ),
      );

      expect(find.text('This is a quote'), findsOneWidget);
    });

    testWidgets('renders markdown links', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data: '[Link text](https://example.com)',
            ),
          ),
        ),
      );

      expect(find.text('Link text'), findsOneWidget);
    });

    testWidgets('renders markdown tables', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data:
                  '| Header 1 | Header 2 |\n| --- | --- |\n| Cell 1 | Cell 2 |',
            ),
          ),
        ),
      );

      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      expect(find.text('Cell 1'), findsOneWidget);
      expect(find.text('Cell 2'), findsOneWidget);
    });

    testWidgets('renders markdown horizontal rules', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: 'Above\n\n---\n\nBelow'),
          ),
        ),
      );

      expect(find.text('Above'), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('renders checkboxes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '- [x] Checked\n- [ ] Unchecked'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('handles multiple code blocks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data:
                  '```dart\nvoid main() {}\n```\n\n```python\nprint("hello")\n```',
            ),
          ),
        ),
      );

      expect(find.text('DART'), findsOneWidget);
      expect(find.text('PYTHON'), findsOneWidget);
    });

    testWidgets('handles empty string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '')),
        ),
      );

      expect(find.byType(EnhancedMarkdownBody), findsOneWidget);
    });

    testWidgets('handles multiline content', (tester) async {
      const content = 'Line 1\nLine 2\nLine 3\nLine 4';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: content)),
        ),
      );

      expect(find.textContaining('Line 1'), findsOneWidget);
      expect(find.textContaining('Line 4'), findsOneWidget);
    });

    testWidgets('handles special characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: 'Special chars: < > & " \''),
          ),
        ),
      );

      expect(find.textContaining('Special chars:'), findsOneWidget);
    });

    testWidgets('handles unicode characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: 'Unicode: 你好 🌍')),
        ),
      );

      expect(find.textContaining('Unicode:'), findsOneWidget);
    });

    testWidgets('respects selectable parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data: 'Selectable text',
              selectable: true,
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsWidgets);
    });

    testWidgets('applies dark theme styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EnhancedMarkdownBody(data: '# Test\n\n**Bold**'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Bold'), findsOneWidget);
    });

    testWidgets('applies light theme styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EnhancedMarkdownBody(data: '# Test\n\n**Bold**'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Bold'), findsOneWidget);
    });

    testWidgets('copy button appears in code blocks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '```dart\nvoid main() {}\n```'),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('supports multiple language highlighting', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data:
                  '```javascript\nconst x = 1;\n```\n\n```dart\nfinal x = 1;\n```',
            ),
          ),
        ),
      );

      expect(find.text('JAVASCRIPT'), findsOneWidget);
      expect(find.text('DART'), findsOneWidget);
    });

    testWidgets('handles escaped characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: r'Escaped: \*not bold\*'),
          ),
        ),
      );

      expect(find.textContaining('Escaped:'), findsOneWidget);
    });

    testWidgets('code block has proper styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '```dart\nvoid main() {}\n```'),
          ),
        ),
      );

      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });

    testWidgets('handles empty code block', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '```dart\n\n```')),
        ),
      );

      expect(find.text('DART'), findsOneWidget);
    });
  });

  group('EnhancedMarkdownBody Edge Cases', () {
    testWidgets('handles markdown with only whitespace', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '   \n\n   \n   ')),
        ),
      );

      expect(find.byType(EnhancedMarkdownBody), findsOneWidget);
    });

    testWidgets('handles malformed markdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(data: '**unclosed\n\n###\n\n* list'),
          ),
        ),
      );

      expect(find.byType(EnhancedMarkdownBody), findsOneWidget);
    });

    testWidgets('handles null data gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '')),
        ),
      );

      expect(find.byType(EnhancedMarkdownBody), findsOneWidget);
    });

    testWidgets('handles deep nesting', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data: '- Level 1\n  - Level 2\n    - Level 3',
            ),
          ),
        ),
      );

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
    });

    testWidgets('does not throw on invalid markdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EnhancedMarkdownBody(data: '```')),
        ),
      );

      expect(find.byType(EnhancedMarkdownBody), findsOneWidget);
    });

    testWidgets('handles mixed content types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data: '# Title\n\nText paragraph.\n\n> Quote\n\n- List item',
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Quote'), findsOneWidget);
      expect(find.text('List item'), findsOneWidget);
    });

    testWidgets('handles links with special characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedMarkdownBody(
              data: '[Link](https://example.com?param=value&other=123)',
            ),
          ),
        ),
      );

      expect(find.text('Link'), findsOneWidget);
    });
  });
}
