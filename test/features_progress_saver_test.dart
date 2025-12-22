import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:writer/features/reader/logic/progress_saver.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';

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
  testWidgets('returns notEnabled when signed out', (tester) async {
    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isSignedInProvider.overrideWithValue(false)],
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

  testWidgets('returns noUser when signed in but current user is null', (
    tester,
  ) async {
    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => null),
        ],
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

  testWidgets('returns saved when signed in and save succeeds', (tester) async {
    const user = BackendUser(id: 'u1');

    final fakePort = FakeProgressPort();
    fakePort.shouldSucceed = true;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => user),
          progressRepositoryProvider.overrideWithValue(fakePort),
        ],
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

  testWidgets('returns error when signed in and save fails', (tester) async {
    const user = BackendUser(id: 'u2');

    final fakePort = FakeProgressPort();
    fakePort.shouldSucceed = false;

    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => user),
          progressRepositoryProvider.overrideWithValue(fakePort),
        ],
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
}
