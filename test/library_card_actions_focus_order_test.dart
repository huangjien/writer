import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/features/library/library_providers.dart'
    as lib_providers;
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/user_progress.dart';

void main() {
  testWidgets('Focus order: Download → Continue → Remove', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // Provide progress for novel-001 so Continue is visible.
    final continuedProgress = UserProgress(
      userId: 'u',
      novelId: 'novel-001',
      chapterId: 'chap-001-01',
      scrollOffset: 0.0,
      ttsCharIndex: 10,
      updatedAt: DateTime(2024, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Ensure Download is enabled in tests without Supabase.
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          // Show Continue button for novel-001.
          mockLastProgressProvider.overrideWith((ref, novelId) async {
            if (novelId == 'novel-001') return continuedProgress;
            return null;
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final download = find.byKey(const Key('downloadButton_novel-001'));
    final cont = find.byKey(const Key('continueButton_novel-001'));
    final remove = find.byKey(const Key('removeButton_novel-001'));

    expect(download, findsOneWidget);
    expect(cont, findsOneWidget);
    expect(remove, findsOneWidget);

    // Verify declared numeric focus order wrappers around each action.
    final downloadOrderWidget = tester.widget<FocusTraversalOrder>(
      find.ancestor(of: download, matching: find.byType(FocusTraversalOrder)),
    );
    final continueOrderWidget = tester.widget<FocusTraversalOrder>(
      find.ancestor(of: cont, matching: find.byType(FocusTraversalOrder)),
    );
    final removeOrderWidget = tester.widget<FocusTraversalOrder>(
      find.ancestor(of: remove, matching: find.byType(FocusTraversalOrder)),
    );

    final downloadOrder = downloadOrderWidget.order as NumericFocusOrder;
    final continueOrder = continueOrderWidget.order as NumericFocusOrder;
    final removeOrder = removeOrderWidget.order as NumericFocusOrder;

    expect(downloadOrder.order, 1.0);
    expect(continueOrder.order, 2.0);
    expect(removeOrder.order, 3.0);
  });
}
