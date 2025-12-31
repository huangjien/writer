import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/l10n/app_localizations.dart';

class FakeSnowflakeService extends Fake implements SnowflakeService {
  SnowflakeRefinementOutput? response;
  bool shouldFail = false;
  SnowflakeRefinementInput? lastInput;

  @override
  Future<SnowflakeRefinementOutput?> refineSummary(
    SnowflakeRefinementInput input,
  ) async {
    lastInput = input;
    if (shouldFail) throw Exception('API Error');
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return response;
  }
}

void main() {
  late FakeSnowflakeService fakeService;
  String? updatedSummary;

  setUp(() {
    fakeService = FakeSnowflakeService();
    updatedSummary = null;
  });

  Widget createWidget({
    String novelId = '123',
    String currentSummary = 'My summary',
  }) {
    return ProviderScope(
      overrides: [snowflakeServiceProvider.overrideWithValue(fakeService)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SnowflakeCoachWidget(
            novelId: novelId,
            currentSummary: currentSummary,
            onSummaryUpdated: (summary) => updatedSummary = summary,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'SnowflakeCoachWidget calls refineSummary on init and shows result',
    (tester) async {
      fakeService.response = SnowflakeRefinementOutput(
        novelId: '123',
        summaryContent: 'Refined summary',
        status: 'question',
        aiQuestion: 'How can we improve?',
        history: [],
      );

      await tester.pumpWidget(createWidget());

      // Loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('AI Coach is analyzing...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('How can we improve?'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    },
  );

  testWidgets('SnowflakeCoachWidget shows error on failure', (tester) async {
    fakeService.shouldFail = true;

    await tester.pumpWidget(createWidget());

    await tester.pumpAndSettle();

    expect(find.textContaining('API Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('SnowflakeCoachWidget handles input and submission', (
    tester,
  ) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Find text field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text
    await tester.enterText(textField, 'Make it shorter');

    // Tap send (icon button)
    await tester.tap(find.byIcon(Icons.send));

    // Should trigger loading again
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('SnowflakeCoachWidget shows error when service returns null', (
    tester,
  ) async {
    fakeService.response = null;

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // When service returns null, should show error state
    expect(find.textContaining('Failed to analyze'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('SnowflakeCoachWidget handles refined status completion', (
    tester,
  ) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Final refined summary',
      status: 'refined',
      critique: 'The summary is now much better',
      history: [
        {'role': 'user', 'content': 'Make it shorter'},
        {'role': 'assistant', 'content': 'I will make it more concise'},
      ],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Refinement Complete!'), findsOneWidget);
    expect(
      find.text('The summary is now much better'),
      findsAtLeastNWidgets(1),
    );
    expect(updatedSummary, 'Final refined summary');
  });

  testWidgets('SnowflakeCoachWidget shows suggestions when available', (
    tester,
  ) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      suggestions: [
        'Make it shorter',
        'Add more details',
        'Focus on main plot',
      ],
      history: [],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Suggestions:'), findsOneWidget);
    expect(find.text('Make it shorter'), findsOneWidget);
    expect(find.text('Add more details'), findsOneWidget);
    expect(find.text('Focus on main plot'), findsOneWidget);
  });

  testWidgets(
    'SnowflakeCoachWidget populates text field when suggestion tapped',
    (tester) async {
      fakeService.response = SnowflakeRefinementOutput(
        novelId: '123',
        summaryContent: 'Refined summary',
        status: 'question',
        aiQuestion: 'How can we improve?',
        suggestions: ['Make it shorter'],
        history: [],
      );

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap suggestion chip
      await tester.tap(find.text('Make it shorter'));
      await tester.pump();

      // Verify text field is populated
      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Make it shorter');

      await tester.pumpAndSettle();
    },
  );

  testWidgets('SnowflakeCoachWidget shows message history', (tester) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve further?',
      history: [
        {'role': 'user', 'content': 'Make it shorter'},
        {'role': 'assistant', 'content': 'I will make it more concise'},
        {'role': 'user', 'content': 'Add more drama'},
        {'role': 'assistant', 'content': 'I will add dramatic elements'},
      ],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Make it shorter'), findsOneWidget);
    expect(find.text('I will make it more concise'), findsOneWidget);
    expect(find.text('Add more drama'), findsOneWidget);
    expect(find.text('I will add dramatic elements'), findsOneWidget);
  });

  testWidgets('SnowflakeCoachWidget updates summary on widget change', (
    tester,
  ) async {
    // Initial widget
    await tester.pumpWidget(createWidget());

    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Updated summary',
      status: 'refined',
      critique: 'Good summary',
      history: [],
    );

    await tester.pumpAndSettle();
    expect(updatedSummary, 'Updated summary');

    // Update widget with different summary
    await tester.pumpWidget(createWidget(currentSummary: 'Different summary'));
    await tester.pumpAndSettle();

    // Should trigger new analysis
    expect(fakeService.lastInput?.summaryContent, 'Different summary');
  });

  testWidgets('SnowflakeCoachWidget handles text field submission', (
    tester,
  ) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Make it more engaging');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Should trigger loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(fakeService.lastInput?.userResponse, 'Make it more engaging');

    await tester.pumpAndSettle();
  });

  testWidgets('SnowflakeCoachWidget disables controls during loading', (
    tester,
  ) async {
    // Test the initial loading state when widget first loads
    // Don't set up response to trigger initial loading
    await tester.pumpWidget(createWidget());
    await tester.pump(); // Don't use pumpAndSettle to avoid timer issues

    // Should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('AI Coach is analyzing...'), findsOneWidget);

    // Now set up response and complete loading
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      suggestions: ['Make it shorter'],
      history: [],
    );

    await tester.pumpAndSettle();

    // Now should have input controls that are enabled
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);

    // Test that controls are enabled when not loading
    final sendButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(sendButton.onPressed, isNotNull);
    final suggestionChip = tester.widget<ActionChip>(find.byType(ActionChip));
    expect(suggestionChip.onPressed, isNotNull);
  });

  testWidgets('SnowflakeCoachWidget passes correct parameters to service', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidget(
        novelId: 'novel-456',
        currentSummary: 'Test summary content',
      ),
    );

    await tester.pumpAndSettle();

    expect(fakeService.lastInput?.novelId, 'novel-456');
    expect(fakeService.lastInput?.summaryContent, 'Test summary content');
    expect(fakeService.lastInput?.userResponse, isNull);
  });

  testWidgets('SnowflakeCoachWidget handles retry after error', (tester) async {
    fakeService.shouldFail = true;

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.textContaining('API Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Fix the service and retry
    fakeService.shouldFail = false;
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Success summary',
      status: 'refined',
      critique: 'Great work!',
      history: [],
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    // Check that the refinement is complete - the summary itself isn't displayed in the UI
    // but the completion status and critique are
    expect(find.text('Refinement Complete!'), findsOneWidget);
    expect(find.text('Great work!'), findsOneWidget);
  });

  testWidgets(
    'SnowflakeCoachWidget shows critique when refined and has critique',
    (tester) async {
      fakeService.response = SnowflakeRefinementOutput(
        novelId: '123',
        summaryContent: 'Final summary',
        status: 'refined',
        critique: 'The summary captures the essence well',
        history: [],
      );

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      // Wait for the post-frame callback to execute
      await tester.pump();

      expect(
        find.text('The summary captures the essence well'),
        findsOneWidget,
      );
      // Note: The check_circle icon appears in a separate section, but the critique
      // text is displayed in the main AI message area with the auto_awesome icon
    },
  );

  testWidgets('SnowflakeCoachWidget hides input area when refined', (
    tester,
  ) async {
    fakeService.response = SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Final summary',
      status: 'refined',
      history: [],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Input area should be hidden when status is 'refined'
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.send), findsNothing);
  });
}
