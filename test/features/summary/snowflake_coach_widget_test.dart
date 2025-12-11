import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/features/summary/snowflake_service.dart';

void main() {
  testWidgets('SnowflakeCoachWidget applies refined summary', (tester) async {
    String? updated;
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path.endsWith('snowflake/refine')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['summary_content'], 'base');
        return http.Response(
          jsonEncode({
            'novel_id': 'n1',
            'summary_content': 'updated',
            'status': 'refined',
            'critique': 'ok',
            'history': [
              {'role': 'ai', 'content': 'Done'},
            ],
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final container = ProviderContainer(
      overrides: [
        snowflakeServiceProvider.overrideWithValue(
          SnowflakeService('http://example.com/', client: client),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SnowflakeCoachWidget(
              novelId: 'n1',
              currentSummary: 'base',
              onSummaryUpdated: (s) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final coach = find.byType(SnowflakeCoachWidget);
    expect(coach, findsOneWidget);

    await tester.pumpAndSettle();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SnowflakeCoachWidget(
              novelId: 'n1',
              currentSummary: 'base',
              onSummaryUpdated: (s) => updated = s,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(updated, 'updated');
    expect(find.text('Refinement Complete!'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
    'SnowflakeCoachWidget shows suggestions and input when refining',
    (tester) async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('snowflake/refine')) {
          return http.Response(
            jsonEncode({
              'novel_id': 'n1',
              'summary_content': 'base',
              'status': 'refining',
              'ai_question': 'Q',
              'suggestions': ['s1', 's2'],
              'history': [],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });

      final container = ProviderContainer(
        overrides: [
          snowflakeServiceProvider.overrideWithValue(
            SnowflakeService('http://example.com/', client: client),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SnowflakeCoachWidget(
                novelId: 'n1',
                currentSummary: 'base',
                onSummaryUpdated: (s) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Suggestions:'), findsOneWidget);
      expect(find.text('s1'), findsOneWidget);
      expect(find.text('s2'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets('SnowflakeCoachWidget submits answer and completes refinement', (
    tester,
  ) async {
    int calls = 0;
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path.endsWith('snowflake/refine')) {
        calls += 1;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (calls == 1) {
          return http.Response(
            jsonEncode({
              'novel_id': 'n1',
              'summary_content': body['summary_content'],
              'status': 'refining',
              'ai_question': 'Q',
              'suggestions': ['s1'],
              'history': [],
            }),
            200,
          );
        } else {
          expect(body['user_response'], 'answer');
          return http.Response(
            jsonEncode({
              'novel_id': 'n1',
              'summary_content': 'final',
              'status': 'refined',
              'critique': 'done',
              'history': [
                {'role': 'ai', 'content': 'Done'},
              ],
            }),
            200,
          );
        }
      }
      return http.Response('not found', 404);
    });

    final container = ProviderContainer(
      overrides: [
        snowflakeServiceProvider.overrideWithValue(
          SnowflakeService('http://example.com/', client: client),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SnowflakeCoachWidget(
              novelId: 'n1',
              currentSummary: 'base',
              onSummaryUpdated: (s) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'answer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Refinement Complete!'), findsOneWidget);
  });
}
