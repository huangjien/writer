import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository remote;
  late ProgressRepository repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    remote = MockRemoteRepository();
    repository = ProgressRepository(remote);
  });

  group('ProgressRepository', () {
    test('upsertProgress posts progress payload', () async {
      final progress = UserProgress(
        userId: 'user1',
        novelId: 'novel1',
        chapterId: 'chap1',
        scrollOffset: 100.0,
        ttsCharIndex: 10,
        updatedAt: DateTime.now(),
      );

      final captured = <Map<String, dynamic>>[];
      when(() => remote.post(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return {};
      });

      await repository.upsertProgress(progress);

      expect(captured.single, {
        'novel_id': 'novel1',
        'chapter_id': 'chap1',
        'scroll_offset': 100.0,
        'tts_char_index': 10,
      });
      verify(() => remote.post('progress', any())).called(1);
    });

    test('lastProgressForNovel returns progress when found', () async {
      final progressData = {
        'user_id': 'user1',
        'novel_id': 'novel1',
        'chapter_id': 'chap1',
        'scroll_offset': 100.0,
        'tts_char_index': 10,
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(
        () => remote.get('progress/novels/novel1/last'),
      ).thenAnswer((_) async => progressData);

      final result = await repository.lastProgressForNovel('novel1');

      expect(result, isNotNull);
      expect(result!.novelId, 'novel1');
      expect(result.userId, 'user1');
    });

    test('lastProgressForNovel returns null on error', () async {
      when(
        () => remote.get('progress/novels/novel1/last'),
      ).thenThrow(Exception('404'));
      final result = await repository.lastProgressForNovel('novel1');
      expect(result, isNull);
    });

    test('latestProgressForUser returns progress', () async {
      final progressData = {
        'user_id': 'user1',
        'novel_id': 'novel1',
        'chapter_id': 'chap1',
        'scroll_offset': 100.0,
        'tts_char_index': 10,
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(
        () => remote.get('progress/latest'),
      ).thenAnswer((_) async => progressData);

      final result = await repository.latestProgressForUser();

      expect(result, isNotNull);
      expect(result!.novelId, 'novel1');
    });
  });
}
