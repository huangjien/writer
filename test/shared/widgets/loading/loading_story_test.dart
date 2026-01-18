import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/loading/loading_story.dart';

void main() {
  testWidgets('LoadingStory renders empty string when stories is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingStory(stories: [])),
      ),
    );

    expect(find.byKey(const ValueKey('')), findsOneWidget);
  });

  testWidgets('LoadingStory does not rotate when only one story', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingStory(
            stories: ['A'],
            interval: Duration(milliseconds: 10),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const ValueKey('A')), findsOneWidget);
  });

  testWidgets('LoadingStory rotates through stories over time', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingStory(
            stories: ['A', 'B'],
            interval: Duration(milliseconds: 10),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('A')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 15));
    expect(find.byKey(const ValueKey('B')), findsOneWidget);
  });

  testWidgets('LoadingStory resets index when interval changes', (
    tester,
  ) async {
    var interval = const Duration(seconds: 1);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  LoadingStory(stories: const ['A', 'B'], interval: interval),
                  TextButton(
                    onPressed: () => setState(() {
                      interval = const Duration(seconds: 2);
                    }),
                    child: const Text('Change'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('B')), findsOneWidget);
    expect(find.byKey(const ValueKey('A')), findsNothing);

    await tester.tap(find.text('Change'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('A')), findsOneWidget);
  });
}
