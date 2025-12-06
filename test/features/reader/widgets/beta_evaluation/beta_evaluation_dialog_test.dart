import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/beta_evaluation/beta_evaluation_dialog.dart';
import '../../../../helpers/test_utils.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

void main() {
  testWidgets('BetaEvaluationDialog shows markdown content', (tester) async {
    final evaluation = {
      'markdown': '# Great story\n\n* Suggestion 1\n* Suggestion 2',
    };

    await tester.pumpWidget(
      materialAppFor(
        home: Builder(
          builder: (context) {
            return BetaEvaluationDialog(evaluation: evaluation);
          },
        ),
      ),
    );

    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.text('Great story'), findsOneWidget);
    expect(find.text('Suggestion 1'), findsOneWidget);
    expect(find.text('Suggestion 2'), findsOneWidget);
  });

  testWidgets('BetaEvaluationDialog handles empty data', (tester) async {
    final evaluation = <String, dynamic>{};

    await tester.pumpWidget(
      materialAppFor(
        home: Builder(
          builder: (context) {
            return BetaEvaluationDialog(evaluation: evaluation);
          },
        ),
      ),
    );

    expect(find.byType(MarkdownBody), findsOneWidget);
    // Close button should always be there (Cancel)
    expect(find.text('Cancel'), findsOneWidget);
  });
}
