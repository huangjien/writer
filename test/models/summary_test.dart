import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/summary.dart';

void main() {
  group('Summary', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 's-1',
        'novel_id': 'n-1',
        'idx': 1,
        'title': 'Chapter 1',
        'sentence_summary': 'A sentence.',
        'paragraph_summary': 'A paragraph.',
        'page_summary': 'A page.',
        'expanded_summary': 'Expanded.',
        'language_code': 'en',
      };

      final summary = Summary.fromJson(json);

      expect(summary.id, 's-1');
      expect(summary.novelId, 'n-1');
      expect(summary.idx, 1);
      expect(summary.title, 'Chapter 1');
      expect(summary.sentenceSummary, 'A sentence.');
      expect(summary.paragraphSummary, 'A paragraph.');
      expect(summary.pageSummary, 'A page.');
      expect(summary.expandedSummary, 'Expanded.');
      expect(summary.languageCode, 'en');
    });

    test('toJson should serialize correctly', () {
      final summary = Summary(
        id: 's-1',
        novelId: 'n-1',
        idx: 1,
        title: 'Chapter 1',
        sentenceSummary: 'A sentence.',
        paragraphSummary: 'A paragraph.',
        pageSummary: 'A page.',
        expandedSummary: 'Expanded.',
        languageCode: 'en',
      );

      final json = summary.toJson();

      expect(json['id'], 's-1');
      expect(json['novel_id'], 'n-1');
      expect(json['idx'], 1);
      expect(json['title'], 'Chapter 1');
      expect(json['sentence_summary'], 'A sentence.');
      expect(json['paragraph_summary'], 'A paragraph.');
      expect(json['page_summary'], 'A page.');
      expect(json['expanded_summary'], 'Expanded.');
      expect(json['language_code'], 'en');
    });

    test('copyWith should update fields correctly', () {
      final summary = Summary(id: 's-1', novelId: 'n-1', idx: 1);

      final updated = summary.copyWith(
        title: 'New Title',
        sentenceSummary: 'New Sentence',
      );

      expect(updated.id, summary.id);
      expect(updated.novelId, summary.novelId);
      expect(updated.idx, summary.idx);
      expect(updated.title, 'New Title');
      expect(updated.sentenceSummary, 'New Sentence');
      expect(updated.paragraphSummary, isNull);
    });
  });
}
