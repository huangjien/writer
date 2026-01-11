import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/rich_text_editor.dart';

void main() {
  testWidgets('RichTextEditor shows TextField when preview is false', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Hello');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: RichTextEditor(
              controller: controller,
              preview: false,
              hintText: 'Type here',
              semanticsLabel: 'My editor',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.bySemanticsLabel('My editor'), findsOneWidget);
    expect(find.text('Type here'), findsOneWidget);
  });

  testWidgets('RichTextEditor shows Markdown preview when preview is true', (
    tester,
  ) async {
    final controller = TextEditingController(text: '# Title\n\nBody');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RichTextEditor(controller: controller, preview: true),
        ),
      ),
    );

    final md = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(md.data, '# Title\n\nBody');
  });

  test('MarkdownEditActions wraps empty selection with bold markers', () {
    final controller = TextEditingController(text: 'abc');
    controller.selection = const TextSelection.collapsed(offset: 1);

    MarkdownEditActions.toggleBold(controller);

    expect(controller.text, 'a****bc');
    expect(controller.selection.baseOffset, 3);
    expect(controller.selection.extentOffset, 3);
  });

  test('MarkdownEditActions wraps selected text with italics markers', () {
    final controller = TextEditingController(text: 'hello');
    controller.selection = const TextSelection(baseOffset: 1, extentOffset: 4);

    MarkdownEditActions.toggleItalic(controller);

    expect(controller.text, 'h*ell*o');
    expect(controller.selection.baseOffset, 1);
    expect(controller.selection.extentOffset, 6);
  });

  test('MarkdownEditActions uses fenced block for multiline inline code', () {
    final controller = TextEditingController(text: 'one\ntwo');
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 7);

    MarkdownEditActions.toggleInlineCode(controller);

    expect(controller.text, '```\none\ntwo\n```');
    expect(controller.selection.baseOffset, 0);
    expect(controller.selection.extentOffset, controller.text.length);
  });

  test('MarkdownEditActions prefixes current line for heading', () {
    final controller = TextEditingController(text: 'a\nb');
    controller.selection = const TextSelection.collapsed(offset: 3);

    MarkdownEditActions.insertHeading(controller);

    expect(controller.text, 'a\n# b');
    expect(controller.selection.baseOffset, 5);
  });

  test('MarkdownEditActions inserts link and selects https part', () {
    final controller = TextEditingController(text: '');
    controller.selection = const TextSelection.collapsed(offset: 0);

    MarkdownEditActions.insertLink(controller);

    expect(controller.text, '[link text](https://)');
    expect(controller.selection.baseOffset, 12);
    expect(controller.selection.extentOffset, 20);
  });
}
