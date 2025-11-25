import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/preview_panel.dart';

void main() {
  testWidgets('PreviewPanel renders diff rows and cells', (tester) async {
    const draftTitle = 'Draft';
    const origTitle = 'Original';
    const orig = 'Line one\nLine two';
    const draft = 'Line one updated\nLine two';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PreviewPanel(
            draftTitle: draftTitle,
            draftContent: draft,
            originalTitle: origTitle,
            originalContent: orig,
          ),
        ),
      ),
    );
    expect(find.text(draftTitle), findsOneWidget);
    expect(find.text(origTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('preview_row_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('draft_cell_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('orig_cell_0')), findsOneWidget);
  });
}
