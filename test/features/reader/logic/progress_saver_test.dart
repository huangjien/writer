import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/reader/logic/progress_saver.dart' as saver;

void main() {
  tearDown(() {
    saver.mockGetUser = null;
    saver.mockSupabaseEnabled = null;
  });

  test('saveReaderProgress returns notEnabled when disabled', () async {
    saver.mockSupabaseEnabled = false;
    final container = ProviderContainer();
    final refProvider = Provider((ref) => ref);
    final status = await saver.saveReaderProgress(
      ref: container.read(refProvider),
      novelId: 'n1',
      chapterId: 'c1',
      scrollOffset: 12.3,
      ttsIndex: 5,
    );
    expect(status, saver.SaveStatus.notEnabled);
  });

  test(
    'saveReaderProgress returns noUser when enabled but user null',
    () async {
      saver.mockSupabaseEnabled = true;
      saver.mockGetUser = () => null;
      final container = ProviderContainer();
      final refProvider = Provider((ref) => ref);
      final status = await saver.saveReaderProgress(
        ref: container.read(refProvider),
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 1.0,
        ttsIndex: 0,
      );
      expect(status, saver.SaveStatus.noUser);
    },
  );

  test(
    'saveReaderProgress returns error when enabled without Supabase init',
    () async {
      saver.mockSupabaseEnabled = true;
      saver.mockGetUser = null;
      final container = ProviderContainer();
      final refProvider = Provider((ref) => ref);
      final status = await saver.saveReaderProgress(
        ref: container.read(refProvider),
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0.0,
        ttsIndex: 0,
      );
      expect(status, saver.SaveStatus.error);
    },
  );
}
