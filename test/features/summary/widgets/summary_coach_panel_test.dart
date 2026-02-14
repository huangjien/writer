import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/summary/widgets/summary_coach_panel.dart';
import 'package:writer/features/summary/widgets/snowflake_coach_widget.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/features/summary/state/summary_notifier.dart'
    show SummaryState, summaryProvider;
import 'package:writer/repositories/novel_repository.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

void main() {
  group('buildSummaryCoachPanel', () {
    testWidgets('returns null when no coach is shown', (tester) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) {
                final panel = buildSummaryCoachPanel(
                  context: context,
                  ref: ref,
                  novelId: 'novel-1',
                  summaryState: summaryState,
                  sentenceController: sentenceController,
                  paragraphController: paragraphController,
                  pageController: pageController,
                  expandedController: expandedController,
                  onFieldChanged: () {},
                );
                return Scaffold(
                  body: panel ?? const SizedBox(key: Key('empty')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty')), findsOneWidget);
    });

    testWidgets('shows sentence coach when showSentenceCoach is true', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: true,
        showParagraphCoach: false,
        showPageCoach: false,
        sentenceAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    });

    testWidgets('triggers onFieldChanged when sentence coach updates summary', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'initial');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');
      bool onFieldChangedCalled = false;

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: true,
        showParagraphCoach: false,
        showPageCoach: false,
        sentenceAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) {
                final panel = buildSummaryCoachPanel(
                  context: context,
                  ref: ref,
                  novelId: 'novel-1',
                  summaryState: summaryState,
                  sentenceController: sentenceController,
                  paragraphController: paragraphController,
                  pageController: pageController,
                  expandedController: expandedController,
                  onFieldChanged: () => onFieldChangedCalled = true,
                );
                return Scaffold(body: panel ?? const SizedBox());
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI Sentence Summary'), findsOneWidget);
      expect(onFieldChangedCalled, false);

      sentenceController.text = 'updated';
      await tester.pump();

      expect(sentenceController.text, 'updated');
    });

    testWidgets('shows paragraph coach when showParagraphCoach is true', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: true,
        showPageCoach: false,
        paragraphAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    });

    testWidgets('shows page coach when showPageCoach is true', (tester) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: true,
        pageAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    });

    testWidgets('shows expanded coach when showCoach is true', (tester) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: true,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: false,
        expandedAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    });

    testWidgets('prioritizes sentence coach over other coaches', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: true,
        showSentenceCoach: true,
        showParagraphCoach: true,
        showPageCoach: true,
        sentenceAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    });

    testWidgets('triggers onSummaryUpdated callback for sentence coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'initial');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');
      bool onFieldChangedCalled = false;

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: true,
        showParagraphCoach: false,
        showPageCoach: false,
        sentenceAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () => onFieldChangedCalled = true,
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onSummaryUpdated('updated summary');

      expect(sentenceController.text, 'updated summary');
      expect(onFieldChangedCalled, true);
    });

    testWidgets('triggers onSummaryUpdated callback for paragraph coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'initial');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');
      bool onFieldChangedCalled = false;

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: true,
        showPageCoach: false,
        paragraphAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () => onFieldChangedCalled = true,
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onSummaryUpdated('updated paragraph');

      expect(paragraphController.text, 'updated paragraph');
      expect(onFieldChangedCalled, true);
    });

    testWidgets('triggers onSummaryUpdated callback for page coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'initial');
      final expandedController = TextEditingController(text: 'test');
      bool onFieldChangedCalled = false;

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: true,
        pageAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () => onFieldChangedCalled = true,
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onSummaryUpdated('updated page');

      expect(pageController.text, 'updated page');
      expect(onFieldChangedCalled, true);
    });

    testWidgets('triggers onSummaryUpdated callback for expanded coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'initial');
      bool onFieldChangedCalled = false;

      final summaryState = const SummaryState(
        showCoach: true,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: false,
        expandedAiSatisfied: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () => onFieldChangedCalled = true,
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onSummaryUpdated('updated expanded');

      expect(expandedController.text, 'updated expanded');
      expect(onFieldChangedCalled, true);
    });

    testWidgets('triggers onAiCompleted callback for sentence coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: true,
        showParagraphCoach: false,
        showPageCoach: false,
        sentenceAiSatisfied: true,
      );

      final testOutput = const SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'AI generated summary',
        status: 'completed',
      );

      final mockRepository = MockNovelRepository();
      WidgetRef? capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onAiCompleted!(testOutput);

      await tester.pump();

      final updatedState = capturedRef!.read(summaryProvider);
      expect(updatedState.sentenceLastOutput, equals(testOutput));
      expect(updatedState.sentenceAiSatisfied, isTrue);
    });

    testWidgets('triggers onAiCompleted callback for paragraph coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: true,
        showPageCoach: false,
        paragraphAiSatisfied: true,
      );

      final testOutput = const SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'AI generated summary',
        status: 'completed',
      );

      final mockRepository = MockNovelRepository();
      WidgetRef? capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onAiCompleted!(testOutput);

      await tester.pump();

      final updatedState = capturedRef!.read(summaryProvider);
      expect(updatedState.paragraphLastOutput, equals(testOutput));
      expect(updatedState.paragraphAiSatisfied, isTrue);
    });

    testWidgets('triggers onAiCompleted callback for page coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: false,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: true,
        pageAiSatisfied: true,
      );

      final testOutput = const SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'AI generated summary',
        status: 'completed',
      );

      final mockRepository = MockNovelRepository();
      WidgetRef? capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onAiCompleted!(testOutput);

      await tester.pump();

      final updatedState = capturedRef!.read(summaryProvider);
      expect(updatedState.pageLastOutput, equals(testOutput));
      expect(updatedState.pageAiSatisfied, isTrue);
    });

    testWidgets('triggers onAiCompleted callback for expanded coach', (
      tester,
    ) async {
      final sentenceController = TextEditingController(text: 'test');
      final paragraphController = TextEditingController(text: 'test');
      final pageController = TextEditingController(text: 'test');
      final expandedController = TextEditingController(text: 'test');

      final summaryState = const SummaryState(
        showCoach: true,
        showSentenceCoach: false,
        showParagraphCoach: false,
        showPageCoach: false,
        expandedAiSatisfied: true,
      );

      final testOutput = const SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'AI generated summary',
        status: 'completed',
      );

      final mockRepository = MockNovelRepository();
      WidgetRef? capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  final panel = buildSummaryCoachPanel(
                    context: context,
                    ref: ref,
                    novelId: 'novel-1',
                    summaryState: summaryState,
                    sentenceController: sentenceController,
                    paragraphController: paragraphController,
                    pageController: pageController,
                    expandedController: expandedController,
                    onFieldChanged: () {},
                  );
                  return panel ?? const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final coachWidget = tester.widget<SnowflakeCoachWidget>(
        find.byType(SnowflakeCoachWidget),
      );

      coachWidget.onAiCompleted!(testOutput);

      await tester.pump();

      final updatedState = capturedRef!.read(summaryProvider);
      expect(updatedState.expandedLastOutput, equals(testOutput));
      expect(updatedState.expandedAiSatisfied, isTrue);
    });
  });
}
