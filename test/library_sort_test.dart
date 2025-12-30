import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/providers.dart';

void main() {
  testWidgets('Library sort by author changes order', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'Quiet City Nights',
        author: 'L. Dreamer',
        description: 'Slice-of-life stories set in a peaceful city.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n-2',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n-3',
        title: 'Stars Above, Seas Below',
        author: 'M. Voyager',
        description: 'Exploring the cosmos and the depths of the ocean.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

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
          libraryNovelsProvider.overrideWith((ref) async => novels),
          memberNovelsProvider.overrideWith((ref) async => const []),
          chaptersProvider.overrideWith((ref, novelId) async => const []),
          lastProgressProvider.overrideWith((ref, novelId) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Initial sort by title (asc) should place 'Quiet City Nights' first.
    final quietPos = tester.getTopLeft(find.text('Quiet City Nights'));
    final starsPos = tester.getTopLeft(find.text('Stars Above, Seas Below'));
    final whisperPos = tester.getTopLeft(find.text('The Whispering Forest'));
    expect(quietPos.dy < starsPos.dy, isTrue);
    expect(starsPos.dy < whisperPos.dy, isTrue);

    // Change sort to Author and validate new first item.
    final dropdown = find.byType(DropdownButton);
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Tap 'Author' menu item.
    await tester.tap(find.text('Author').last);
    await tester.pumpAndSettle();

    final whisperPos2 = tester.getTopLeft(find.text('The Whispering Forest'));
    final quietPos2 = tester.getTopLeft(find.text('Quiet City Nights'));
    final starsPos2 = tester.getTopLeft(find.text('Stars Above, Seas Below'));
    // Now 'The Whispering Forest' (A. Storyteller) should be first.
    expect(whisperPos2.dy < quietPos2.dy, isTrue);
    expect(quietPos2.dy < starsPos2.dy, isTrue);
  });
}
