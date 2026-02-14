import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/state/summary_notifier.dart';
import 'package:writer/features/summary/widgets/snowflake_coach_widget.dart';

Widget? buildSummaryCoachPanel({
  required BuildContext context,
  required WidgetRef ref,
  required String novelId,
  required SummaryState summaryState,
  required TextEditingController sentenceController,
  required TextEditingController paragraphController,
  required TextEditingController pageController,
  required TextEditingController expandedController,
  required VoidCallback onFieldChanged,
}) {
  final showCoach =
      summaryState.showCoach ||
      summaryState.showSentenceCoach ||
      summaryState.showParagraphCoach ||
      summaryState.showPageCoach;
  if (!showCoach) return null;

  if (summaryState.showSentenceCoach) {
    return SnowflakeCoachWidget(
      novelId: novelId,
      summaryType: 'sentence',
      currentSummary: sentenceController.text,
      onSummaryUpdated: (newSummary) {
        sentenceController.text = newSummary;
        onFieldChanged();
      },
      autoAnalyze: !summaryState.sentenceAiSatisfied,
      lastOutput: summaryState.sentenceLastOutput,
      onAiCompleted: (output) {
        ref.read(summaryProvider.notifier).setSentenceLastOutput(output);
        ref.read(summaryProvider.notifier).setSentenceAiSatisfied(true);
      },
    );
  }

  if (summaryState.showParagraphCoach) {
    return SnowflakeCoachWidget(
      novelId: novelId,
      summaryType: 'paragraph',
      currentSummary: paragraphController.text,
      onSummaryUpdated: (newSummary) {
        paragraphController.text = newSummary;
        onFieldChanged();
      },
      autoAnalyze: !summaryState.paragraphAiSatisfied,
      lastOutput: summaryState.paragraphLastOutput,
      onAiCompleted: (output) {
        ref.read(summaryProvider.notifier).setParagraphLastOutput(output);
        ref.read(summaryProvider.notifier).setParagraphAiSatisfied(true);
      },
    );
  }

  if (summaryState.showPageCoach) {
    return SnowflakeCoachWidget(
      novelId: novelId,
      summaryType: 'page',
      currentSummary: pageController.text,
      onSummaryUpdated: (newSummary) {
        pageController.text = newSummary;
        onFieldChanged();
      },
      autoAnalyze: !summaryState.pageAiSatisfied,
      lastOutput: summaryState.pageLastOutput,
      onAiCompleted: (output) {
        ref.read(summaryProvider.notifier).setPageLastOutput(output);
        ref.read(summaryProvider.notifier).setPageAiSatisfied(true);
      },
    );
  }

  return SnowflakeCoachWidget(
    novelId: novelId,
    summaryType: 'expanded',
    currentSummary: expandedController.text,
    onSummaryUpdated: (newSummary) {
      expandedController.text = newSummary;
      onFieldChanged();
    },
    autoAnalyze: !summaryState.expandedAiSatisfied,
    lastOutput: summaryState.expandedLastOutput,
    onAiCompleted: (output) {
      ref.read(summaryProvider.notifier).setExpandedLastOutput(output);
      ref.read(summaryProvider.notifier).setExpandedAiSatisfied(true);
    },
  );
}
