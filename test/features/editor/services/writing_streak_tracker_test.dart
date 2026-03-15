import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:writer/features/editor/services/writing_streak_tracker.dart';
import 'package:writer/services/storage_service.dart';

@GenerateMocks([StorageService])
import 'writing_streak_tracker_test.mocks.dart';

void main() {
  group('WritingStreakTracker', () {
    late MockStorageService mockStorage;
    const tracker = WritingStreakTracker();

    setUp(() {
      mockStorage = MockStorageService();
    });

    group('loadStreak', () {
      test('returns 0 when no last write date exists', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(null);
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('returns 0 when last write date is invalid', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn('invalid-date');
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('returns 0 when stored streak is invalid', () async {
        final today = DateTime.now();
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(today.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('invalid');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('returns stored streak when last write was today', () async {
        final today = DateTime.now();
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(today.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('10');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 10);
      });

      test('returns stored streak when last write was yesterday', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(yesterday.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('7');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 7);
      });

      test('returns 0 when last write was more than 1 day ago', () async {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(twoDaysAgo.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('returns 0 when exception occurs', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenThrow(Exception('Storage error'));

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('handles null streak days value', () async {
        final today = DateTime.now();
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(today.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn(null);

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 0);
      });

      test('handles time portion in date correctly', () async {
        final todayWithTime = DateTime.now().subtract(const Duration(hours: 5));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(todayWithTime.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('3');

        final result = await tracker.loadStreak(mockStorage);

        expect(result, 3);
      });
    });

    group('recordWritingSessionIfNeeded', () {
      test('does not update streak for negative words', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(null);
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('0');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: -100,
        );

        expect(result, null);
        verifyNever(
          mockStorage.setString('writer.editor.last_write_date', any),
        );
        verifyNever(mockStorage.setString('writer.editor.streak_days', any));
      });

      test('does not update streak for zero words', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(null);
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('0');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 0,
        );

        expect(result, null);
        verifyNever(
          mockStorage.setString('writer.editor.last_write_date', any),
        );
        verifyNever(mockStorage.setString('writer.editor.streak_days', any));
      });

      test('initializes streak for first positive writing session', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(null);
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('0');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 100,
        );

        expect(result, 1);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verify(
          mockStorage.setString('writer.editor.streak_days', '1'),
        ).called(1);
      });

      test('increments streak when writing on consecutive days', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(yesterday.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 200,
        );

        expect(result, 6);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verify(
          mockStorage.setString('writer.editor.streak_days', '6'),
        ).called(1);
      });

      test('resets streak when writing after gap', () async {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(twoDaysAgo.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('10');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 150,
        );

        expect(result, 1);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verify(
          mockStorage.setString('writer.editor.streak_days', '1'),
        ).called(1);
      });

      test('updates date but not streak count when writing same day', () async {
        final today = DateTime.now();
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(today.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 100,
        );

        expect(result, 5);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verifyNever(mockStorage.setString('writer.editor.streak_days', any));
      });

      test('handles invalid stored date gracefully', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn('invalid-date');
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn('5');
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 100,
        );

        expect(result, 1);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verify(
          mockStorage.setString('writer.editor.streak_days', '1'),
        ).called(1);
      });

      test('handles missing streak count gracefully', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenReturn(yesterday.toIso8601String());
        when(
          mockStorage.getString('writer.editor.streak_days'),
        ).thenReturn(null);
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 100,
        );

        expect(result, 2);
        verify(
          mockStorage.setString('writer.editor.last_write_date', any),
        ).called(1);
        verify(
          mockStorage.setString('writer.editor.streak_days', '2'),
        ).called(1);
      });

      test('handles exception during storage read', () async {
        when(
          mockStorage.getString('writer.editor.last_write_date'),
        ).thenThrow(Exception('Storage error'));
        when(mockStorage.setString(any, any)).thenAnswer((_) async {});

        final result = await tracker.recordWritingSessionIfNeeded(
          mockStorage,
          words: 100,
        );

        expect(result, null);
        verifyNever(
          mockStorage.setString('writer.editor.last_write_date', any),
        );
        verifyNever(mockStorage.setString('writer.editor.streak_days', any));
      });
    });
  });
}
