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

  @override
  Future<SnowflakeRefinementOutput?> refineSummary(
    SnowflakeRefinementInput input,
  ) async {
    if (shouldFail) throw Exception('API Error');
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return response;
  }
}

void main() {
  late FakeSnowflakeService fakeService;

  setUp(() {
    fakeService = FakeSnowflakeService();
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [snowflakeServiceProvider.overrideWithValue(fakeService)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SnowflakeCoachWidget(
            novelId: '123',
            currentSummary: 'My summary',
            onSummaryUpdated: (_) {},
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

      await tester.pumpAndSettle();

      expect(find.text('How can we improve?'), findsOneWidget);
    },
  );

  testWidgets('SnowflakeCoachWidget shows error on failure', (tester) async {
    fakeService.shouldFail = true;

    await tester.pumpWidget(createWidget());

    await tester.pumpAndSettle();

    expect(find.textContaining('API Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
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
}
