import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/loading/loading_story.dart';
import 'package:writer/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:writer/shared/widgets/loading/step_progress.dart';
import 'package:writer/shared/widgets/loading_state.dart';

void main() {
  testWidgets('LoadingState shows shimmer skeleton when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingState(useSkeleton: true))),
    );

    expect(find.byType(ShimmerSkeleton), findsOneWidget);
  });

  testWidgets('LoadingState uses provided skeleton child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(
            useSkeleton: true,
            skeletonChild: Text('Custom skeleton'),
          ),
        ),
      ),
    );

    expect(find.byType(ShimmerSkeleton), findsOneWidget);
    expect(find.text('Custom skeleton'), findsOneWidget);
  });

  testWidgets('LoadingState shows message when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingState(message: 'Loading...')),
      ),
    );

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LoadingStory), findsNothing);
  });

  testWidgets('LoadingState shows stories when message is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(message: '', stories: ['Tip one', 'Tip two']),
        ),
      ),
    );

    expect(find.byType(LoadingStory), findsOneWidget);
    expect(find.text('Tip one'), findsOneWidget);
  });

  testWidgets('LoadingState shows step progress when steps provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(steps: ['A', 'B', 'C'], currentStep: 1),
        ),
      ),
    );

    expect(find.byType(StepProgress), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
