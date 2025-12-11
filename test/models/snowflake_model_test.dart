import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/snowflake.dart';

void main() {
  group('SnowflakeRefinementOutput', () {
    test('fromJson parses all fields including history', () {
      final json = {
        'novel_id': 'n1',
        'summary_content': 's1',
        'status': 'refining',
        'ai_question': 'q1',
        'suggestions': ['A', 'B', 'C'],
        'critique': 'c1',
        'history': [
          {'role': 'user', 'content': 'u'},
          {'role': 'ai', 'content': 'a'},
        ],
      };
      final out = SnowflakeRefinementOutput.fromJson(json);
      expect(out.novelId, 'n1');
      expect(out.summaryContent, 's1');
      expect(out.status, 'refining');
      expect(out.aiQuestion, 'q1');
      expect(out.suggestions, ['A', 'B', 'C']);
      expect(out.critique, 'c1');
      expect(out.history?.length, 2);
      expect(out.history?[0]['role'], 'user');
      expect(out.history?[0]['content'], 'u');
      expect(out.history?[1]['role'], 'ai');
      expect(out.history?[1]['content'], 'a');
    });

    test('fromJson handles missing or invalid history', () {
      final json = {
        'novel_id': 'n2',
        'summary_content': 's2',
        'status': 'refined',
        'ai_question': null,
        'suggestions': [],
        'critique': null,
      };
      final out = SnowflakeRefinementOutput.fromJson(json);
      expect(out.novelId, 'n2');
      expect(out.status, 'refined');
      expect(out.history, isNull);
    });
  });
}
