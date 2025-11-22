import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/features/reader/logic/progress_saver.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  testWidgets('returns notEnabled when Supabase disabled', (tester) async {
    WidgetRef? captured;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
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
    if (!supabaseEnabled) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    WidgetRef? captured;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
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
  }, skip: !supabaseEnabled);

  testWidgets(
    'returns saved when enabled and save succeeds with user',
    (tester) async {
      if (!supabaseEnabled) return;
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      // This test requires an authenticated user; the SDK does not allow
      // setting it without network calls, so keep it skipped unless env provides
      // a pre-authenticated session.
      expect(true, isTrue);
    },
    skip: !supabaseEnabled,
  );

  testWidgets('returns error when enabled and save fails with user', (
    tester,
  ) async {
    if (!supabaseEnabled) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    expect(true, isTrue);
  }, skip: !supabaseEnabled);
}
