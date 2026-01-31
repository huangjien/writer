import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/my_novels_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MyNovelsScreen shows sign-in prompt when signed out', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in to sync progress across devices.'), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('MyNovelsScreen shows empty state when signed in', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final sessionNotifier = SessionNotifier(storageService);
    await sessionNotifier.setSessionId('s-123');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith((ref) => sessionNotifier),
          memberNovelsProviderV2.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No novels found.'), findsOneWidget);
  });

  testWidgets('MyNovelsScreen shows member novels list when signed in', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final sessionNotifier = SessionNotifier(storageService);
    await sessionNotifier.setSessionId('s-123');

    const novels = [
      Novel(
        id: 'n1',
        title: 'Novel 1',
        author: 'Author',
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      Novel(
        id: 'n2',
        title: 'Novel 2',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith((ref) => sessionNotifier),
          memberNovelsProviderV2.overrideWith((ref) async => novels),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Novel 1'), findsOneWidget);
    expect(find.text('Novel 2'), findsOneWidget);
  });
}
