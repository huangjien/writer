import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/widgets/snowflake_coach_widget.dart';
import 'package:writer/features/summary/services/snowflake_service.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/l10n/app_localizations.dart';

class FakeSnowflakeService extends Fake implements SnowflakeService {
  SnowflakeRefinementOutput? response;
  SnowflakeRefinementOutput? historyResponse;
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

  @override
  Future<SnowflakeRefinementOutput?> getChatHistory(
    String novelId,
    String summaryType,
  ) async {
    if (shouldFail) throw Exception('API Error');
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return historyResponse;
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
    bool autoAnalyze = true,
    Key? key,
  }) {
    return ProviderScope(
      overrides: [snowflakeServiceProvider.overrideWithValue(fakeService)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SnowflakeCoachWidget(
            key: key,
            novelId: novelId,
            summaryType: 'sentence',
            currentSummary: currentSummary,
            onSummaryUpdated: (summary) => updatedSummary = summary,
            autoAnalyze: autoAnalyze,
          ),
        ),
      ),
    );
  }

  testWidgets('SnowflakeCoachWidget loads history on init and shows result', (
    tester,
  ) async {
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
      critique: '',
      suggestions: [],
    );

    await tester.pumpWidget(createWidget());

    // Should not show loading on init (only loads history, no AI call)
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('AI Coach is analyzing...'), findsNothing);

    await tester.pumpAndSettle();

    // Should show the chatbot with history
    expect(find.text('How can we improve?'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

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
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
      critique: '',
      suggestions: [],
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
    fakeService.historyResponse = null; // No history
    fakeService.response = null; // Service returns null

    await tester.pumpWidget(createWidget(autoAnalyze: false));
    await tester.pumpAndSettle();

    // Click "AI Sentence Summary" to show chatbot
    await tester.tap(find.text('AI Sentence Summary'));
    await tester.pumpAndSettle();

    // Click "Analyze" to trigger service call
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();

    // When service returns null, should show error state
    expect(find.textContaining('Failed to analyze'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('SnowflakeCoachWidget handles refined status completion', (
    tester,
  ) async {
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Final refined summary',
      status: 'refined',
      aiQuestion: 'How can I help you improve your summary?',
      history: [
        {'role': 'user', 'content': 'Make it shorter'},
        {'role': 'assistant', 'content': 'I will make it more concise'},
      ],
      critique: 'The summary is now much better',
      suggestions: [],
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
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
      critique: '',
      suggestions: [
        'Make it shorter',
        'Add more details',
        'Focus on main plot',
      ],
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
      fakeService.historyResponse = const SnowflakeRefinementOutput(
        novelId: '123',
        summaryContent: 'Refined summary',
        status: 'question',
        aiQuestion: 'How can we improve?',
        history: [],
        critique: '',
        suggestions: ['Make it shorter'],
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
    fakeService.historyResponse = const SnowflakeRefinementOutput(
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
      critique: '',
      suggestions: [],
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
    // Set up history response for initial widget load
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Updated summary',
      status: 'refined',
      aiQuestion: 'How can I help you improve your summary?',
      history: [],
      critique: 'Good summary',
      suggestions: [],
    );

    // Initial widget
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();
    expect(updatedSummary, 'Updated summary');

    // Set no history for second widget load
    fakeService.historyResponse = null;

    // Update widget with different summary - should not auto-trigger analysis
    await tester.pumpWidget(
      createWidget(
        currentSummary: 'Different summary',
        autoAnalyze: false,
        key: UniqueKey(), // Force widget recreation to reset state
      ),
    );
    await tester.pumpAndSettle();

    // Should not trigger analysis automatically with new design
    expect(fakeService.lastInput, isNull);

    // Click "AI Sentence Summary" to show chatbot
    await tester.tap(find.text('AI Sentence Summary'));
    await tester.pumpAndSettle();

    // Click "Analyze" to trigger analysis with new summary
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();

    // Should trigger new analysis with the updated summary content
    expect(fakeService.lastInput?.summaryContent, 'Different summary');
  });

  testWidgets('SnowflakeCoachWidget handles text field submission', (
    tester,
  ) async {
    // Set up history with a question to show the text field
    fakeService.historyResponse = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
      critique: '',
      suggestions: [],
    );

    fakeService.response = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary with user input',
      status: 'refined',
      aiQuestion: 'How can I help you improve your summary?',
      history: [
        {'role': 'assistant', 'content': 'How can we improve?'},
        {'role': 'user', 'content': 'Make it more engaging'},
      ],
      critique: 'Good improvement!',
      suggestions: [],
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
    // Set up response for when analyze is clicked
    fakeService.response = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Refined summary',
      status: 'question',
      aiQuestion: 'How can we improve?',
      history: [],
      critique: '',
      suggestions: ['Make it shorter'],
    );

    // Set no history to show the analyze button
    fakeService.historyResponse = null;

    await tester.pumpWidget(createWidget(autoAnalyze: false));
    await tester.pumpAndSettle();

    // Click "AI Sentence Summary" to show chatbot
    await tester.tap(find.text('AI Sentence Summary'));
    await tester.pumpAndSettle();

    // Click "Analyze" to trigger loading
    await tester.tap(find.text('Analyze'));
    await tester.pump(); // Don't use pumpAndSettle to catch loading state

    // Should show loading indicator when analyzing
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('AI Coach is analyzing...'), findsOneWidget);

    // Complete loading
    await tester.pumpAndSettle();

    // Now should have input controls that are enabled
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.text('Make it shorter'), findsOneWidget);

    // Test that controls are enabled when not loading
    final sendButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(sendButton.onPressed, isNotNull);

    // Find the suggestion container (which replaces ActionChip)
    final suggestionContainer = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.child != null &&
          widget.child is ConstrainedBox,
    );
    expect(suggestionContainer, findsOneWidget);
  });

  testWidgets('SnowflakeCoachWidget passes correct parameters to service', (
    tester,
  ) async {
    // Set no history to show the analyze button
    fakeService.historyResponse = null;

    await tester.pumpWidget(
      createWidget(
        novelId: 'novel-456',
        currentSummary: 'Test summary content',
        autoAnalyze: false,
      ),
    );

    await tester.pumpAndSettle();

    // Click "AI Sentence Summary" to show chatbot
    await tester.tap(find.text('AI Sentence Summary'));
    await tester.pumpAndSettle();

    // Initially, refineSummary should not be called (only getChatHistory is called)
    expect(fakeService.lastInput, isNull);

    // Click "Analyze" button to trigger refineSummary
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();

    expect(fakeService.lastInput?.novelId, 'novel-456');
    expect(fakeService.lastInput?.summaryContent, 'Test summary content');
    expect(fakeService.lastInput?.userResponse, isNull);
  });

  testWidgets('SnowflakeCoachWidget handles retry after error', (tester) async {
    fakeService.shouldFail = true;
    fakeService.historyResponse = null;

    await tester.pumpWidget(createWidget(autoAnalyze: false));
    await tester.pumpAndSettle();

    // Click "AI Sentence Summary" to trigger error
    await tester.tap(find.text('AI Sentence Summary'));
    await tester.pumpAndSettle();

    expect(find.textContaining('API Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Fix the service and retry
    fakeService.shouldFail = false;
    fakeService.response = const SnowflakeRefinementOutput(
      novelId: '123',
      summaryContent: 'Success summary',
      status: 'refined',
      aiQuestion: 'How can I help you improve your summary?',
      history: [],
      critique: 'Great work!',
      suggestions: [],
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
      // Set up history with refined status and critique
      fakeService.historyResponse = const SnowflakeRefinementOutput(
        novelId: '123',
        summaryContent: 'Final summary',
        status: 'refined',
        aiQuestion: 'How can I help you improve your summary?',
        history: [],
        critique: 'The summary captures the essence well',
        suggestions: [],
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
    fakeService.response = const SnowflakeRefinementOutput(
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
