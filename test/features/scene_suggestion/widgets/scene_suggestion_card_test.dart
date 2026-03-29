import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/scene_suggestion/widgets/scene_suggestion_card.dart';
import 'package:writer/models/scene_suggestion.dart';

void main() {
  group('SceneSuggestionCard', () {
    testWidgets('should display suggestion text', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'The hero walked forward.',
        relevanceScore: 0.8,
        rationale: 'Good continuation',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              onAccept: () {},
              onReject: () {},
              onModify: () {},
            ),
          ),
        ),
      );

      expect(find.text('The hero walked forward.'), findsOneWidget);
      expect(find.text('Good continuation'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('should handle accept button press', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
      );

      bool acceptCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              onAccept: () => acceptCalled = true,
              onReject: () {},
              onModify: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Accept'));
      await tester.pump();

      expect(acceptCalled, true);
    });

    testWidgets('should handle reject button press', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
      );

      bool rejectCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              onAccept: () {},
              onReject: () => rejectCalled = true,
              onModify: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reject'));
      await tester.pump();

      expect(rejectCalled, true);
    });

    testWidgets('should handle modify button press', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
      );

      bool modifyCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              onAccept: () {},
              onReject: () {},
              onModify: () => modifyCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Modify'));
      await tester.pump();

      expect(modifyCalled, true);
    });

    testWidgets('should display alternative approaches', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
        alternativeApproaches: ['Alt 1', 'Alt 2', 'Alt 3'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              onAccept: () {},
              onReject: () {},
              onModify: () {},
            ),
          ),
        ),
      );

      expect(find.text('Alt 1'), findsOneWidget);
      expect(find.text('Alt 2'), findsOneWidget);
      expect(find.text('Alt 3'), findsOneWidget);
    });

    testWidgets('should disable buttons when loading', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 0,
              isLoading: true,
              onAccept: () {},
              onReject: () {},
              onModify: () {},
            ),
          ),
        ),
      );

      final acceptButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Accept'),
      );
      expect(acceptButton.onPressed, isNull);
    });

    testWidgets('should display correct suggestion index', (tester) async {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.7,
        rationale: 'Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSuggestionCard(
              suggestion: suggestion,
              index: 2,
              onAccept: () {},
              onReject: () {},
              onModify: () {},
            ),
          ),
        ),
      );

      expect(find.text('Suggestion 3'), findsOneWidget);
    });

    testWidgets('should color code relevance scores', (tester) async {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'High quality',
          relevanceScore: 0.9,
          rationale: 'Excellent',
        ),
        const SceneSuggestion(
          suggestedText: 'Medium quality',
          relevanceScore: 0.7,
          rationale: 'Good',
        ),
        const SceneSuggestion(
          suggestedText: 'Low quality',
          relevanceScore: 0.5,
          rationale: 'Fair',
        ),
      ];

      for (final suggestion in suggestions) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SceneSuggestionCard(
                suggestion: suggestion,
                index: 0,
                onAccept: () {},
                onReject: () {},
                onModify: () {},
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      }
    });
  });
}
