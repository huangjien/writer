import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/library/library_providers.dart'
    as lib_providers;
import 'package:writer/state/mock_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

void main() {
  testWidgets('Focus order: Download → Continue → Remove', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);

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
          // Standard provider overrides
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => ttsSettings),
          motionSettingsProvider.overrideWith((ref) => motion),
          remoteRepositoryProvider.overrideWith(
            (ref) => RemoteRepository('http://localhost:5600/'),
          ),
          aiChatServiceProvider.overrideWith(
            (ref) => AiChatService(ref.read(remoteRepositoryProvider)),
          ),
          libraryNovelsProvider.overrideWith(
            (ref) async => await ref.watch(mockNovelsProvider.future),
          ),
          chaptersProvider.overrideWith(
            (ref, novelId) async =>
                await ref.watch(mockChaptersProvider(novelId).future),
          ),
          // Ensure Download is enabled in tests without Supabase.
          lib_providers.downloadFeatureFlagProvider.overrideWithValue(true),
          // Show Continue button for novel-001.
          mockLastProgressProvider.overrideWith((ref, novelId) async {
            if (novelId == 'novel-001') return continuedProgress;
            return null;
          }),
          lastProgressProvider.overrideWith((ref, novelId) async {
            return ref.watch(mockLastProgressProvider(novelId).future);
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

    final list = find.byKey(const Key('libraryListView'));
    expect(list, findsOneWidget);
    await tester.scrollUntilVisible(
      find.descendant(of: list, matching: find.text('The Whispering Forest')),
      200,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
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
