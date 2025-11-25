import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late ProgressRepository repository;

  setUpAll(() {
    registerFallbackValue((List<Map<String, dynamic>> _) {});
    registerFallbackValue((dynamic _) {});
    registerFallbackValue((Object error, StackTrace stackTrace) {});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);

    repository = ProgressRepository(mockClient);
  });

  group('ProgressRepository', () {
    test('upsertProgress calls upsert', () async {
      final progress = UserProgress(
        userId: 'user1',
        novelId: 'novel1',
        chapterId: 'chap1',
        scrollOffset: 100.0,
        ttsCharIndex: 10,
        updatedAt: DateTime.now(),
      );

      when(
        () => mockQueryBuilder.upsert(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repository.upsertProgress(progress);

      verify(() => mockClient.from('user_progress')).called(1);
      verify(() => mockQueryBuilder.upsert(any())).called(1);
    });

    test('lastProgressForNovel returns progress when found', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user1');

      final progressData = {
        'user_id': 'user1',
        'novel_id': 'novel1',
        'chapter_id': 'chap1',
        'scroll_offset': 100.0,
        'tts_char_index': 10,
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([progressData]));

      final result = await repository.lastProgressForNovel('novel1');

      expect(result, isNotNull);
      expect(result!.novelId, 'novel1');
      expect(result.userId, 'user1');
    });

    test('lastProgressForNovel returns null when user is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.lastProgressForNovel('novel1');

      expect(result, isNull);
      verifyNever(() => mockClient.from(any()));
    });

    test('lastProgressForNovel returns null when empty', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user1');

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([]));

      final result = await repository.lastProgressForNovel('novel1');

      expect(result, isNull);
    });

    test('latestProgressForUser returns progress', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user1');

      final progressData = {
        'user_id': 'user1',
        'novel_id': 'novel1',
        'chapter_id': 'chap1',
        'scroll_offset': 100.0,
        'tts_char_index': 10,
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([progressData]));

      final result = await repository.latestProgressForUser();

      expect(result, isNotNull);
      expect(result!.novelId, 'novel1');
    });
  });
}
