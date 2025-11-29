import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/features/reader/logic/progress_saver.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/supabase_config.dart';

// Fake User class
class FakeUser extends User {
  FakeUser({required super.id})
    : super(
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
}

// Fake ProgressPort
class FakeProgressPort implements ProgressPort {
  bool shouldSucceed = true;
  UserProgress? lastSaved;

  @override
  Future<void> upsertProgress(UserProgress progress) async {
    if (!shouldSucceed) throw Exception('Failed to save');
    lastSaved = progress;
  }

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async {
    return null;
  }

  @override
  Future<UserProgress?> latestProgressForUser() async {
    return null;
  }
}

final refProvider = Provider((ref) => ref);

void main() {
  setUp(() {
    mockSupabaseEnabled = null;
    mockGetUser = null;
  });

  tearDown(() {
    mockSupabaseEnabled = null;
    mockGetUser = null;
  });

  testWidgets('returns notEnabled when Supabase disabled (default)', (
    tester,
  ) async {
    mockSupabaseEnabled = false;
    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final status = await tester.runAsync(() async {
      return saveReaderProgress(
        ref: captured!,
        novelId: 'n-1',
        chapterId: 'c-1',
        scrollOffset: 10.0,
        ttsIndex: 0,
      );
    });
    expect(status, SaveStatus.notEnabled);
  });

  testWidgets('returns notEnabled when Supabase disabled explicitly', (
    tester,
  ) async {
    mockSupabaseEnabled = false;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final status = await tester.runAsync(() async {
      return saveReaderProgress(
        ref: captured!,
        novelId: 'n-1',
        chapterId: 'c-1',
        scrollOffset: 10.0,
        ttsIndex: 0,
      );
    });
    expect(status, SaveStatus.notEnabled);
  });

  testWidgets('returns noUser when enabled and no auth user', (tester) async {
    mockSupabaseEnabled = true;
    mockGetUser = () => null;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final status = await tester.runAsync(() async {
      return saveReaderProgress(
        ref: captured!,
        novelId: 'n-2',
        chapterId: 'c-2',
        scrollOffset: 0.0,
        ttsIndex: 5,
      );
    });
    expect(status, SaveStatus.noUser);
  });

  testWidgets('returns saved when enabled and save succeeds with user', (
    tester,
  ) async {
    mockSupabaseEnabled = true;
    final user = FakeUser(id: 'u1');
    mockGetUser = () => user;

    final fakePort = FakeProgressPort();
    fakePort.shouldSucceed = true;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressRepositoryProvider.overrideWithValue(fakePort)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final status = await tester.runAsync(() async {
      return saveReaderProgress(
        ref: captured!,
        novelId: 'n-3',
        chapterId: 'c-3',
        scrollOffset: 100.0,
        ttsIndex: 50,
      );
    });

    expect(status, SaveStatus.saved);
    expect(fakePort.lastSaved, isNotNull);
    expect(fakePort.lastSaved!.userId, 'u1');
    expect(fakePort.lastSaved!.novelId, 'n-3');
    expect(fakePort.lastSaved!.chapterId, 'c-3');
    expect(fakePort.lastSaved!.scrollOffset, 100.0);
    expect(fakePort.lastSaved!.ttsCharIndex, 50);
  });

  testWidgets('returns error when enabled and save fails with user', (
    tester,
  ) async {
    mockSupabaseEnabled = true;
    final user = FakeUser(id: 'u2');
    mockGetUser = () => user;

    final fakePort = FakeProgressPort();
    fakePort.shouldSucceed = false;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressRepositoryProvider.overrideWithValue(fakePort)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final status = await tester.runAsync(() async {
      return saveReaderProgress(
        ref: captured!,
        novelId: 'n-4',
        chapterId: 'c-4',
        scrollOffset: 20.0,
        ttsIndex: 10,
      );
    });

    expect(status, SaveStatus.error);
    expect(fakePort.lastSaved, isNull);
  });

  testWidgets(
    'handles Supabase.instance exception gracefully when enabled but not init',
    (tester) async {
      // This tests the catch block in the refactored code when mockGetUser is not set
      mockSupabaseEnabled = true;
      mockGetUser = null; // Forces access to Supabase.instance

      Ref? captured;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                captured = ref.read(refProvider);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final status = await tester.runAsync(() async {
        return saveReaderProgress(
          ref: captured!,
          novelId: 'n-5',
          chapterId: 'c-5',
          scrollOffset: 0.0,
          ttsIndex: 0,
        );
      });

      expect(status, isIn(<SaveStatus>[SaveStatus.error, SaveStatus.noUser]));
    },
    skip: supabaseEnabled,
  );
}
