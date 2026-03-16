import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/screens/my_novels_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/storage_service_provider.dart';

import 'package:writer/shared/widgets/empty_states/novel_empty_state.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('MyNovelsScreen', () {
    testWidgets('shows sign-in prompt when signed out', (tester) async {
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
      expect(
        find.text('Sign in to sync progress across devices.'),
        findsWidgets,
      );
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows empty state when signed in', (tester) async {
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

    testWidgets('shows member novels list when signed in', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);
      await sessionNotifier.setSessionId('s-123');

      const novels = [
        Novel(
          id: 'n1',
          title: 'Novel 1',
          author: 'Author 1',
          description: null,
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        Novel(
          id: 'n2',
          title: 'Novel 2',
          author: 'Author 2',
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
      expect(find.text('Author 1'), findsOneWidget);
      expect(find.text('Novel 2'), findsOneWidget);
      expect(find.text('Author 2'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows loading state', (tester) async {
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
            // Return a future that doesn't complete immediately to show loading
            memberNovelsProviderV2.overrideWith((ref) {
              return Future.delayed(const Duration(seconds: 1), () => []);
            }),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MyNovelsScreen(),
          ),
        ),
      );

      // Pump a frame but don't settle (to see loading)
      await tester.pump();
      expect(find.text('Loading novels…'), findsOneWidget);

      // Finish
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    /*
    testWidgets('shows error state', (tester) async {
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
            memberNovelsProviderV2.overrideWith((ref) async {
              await Future.delayed(Duration.zero);
              throw 'Error';
            }),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MyNovelsScreen(),
          ),
        ),
      );
      
      // Initial pump
      await tester.pump();
      // Pump again to allow Future to complete and UI to update
      await tester.pump();
      
      expect(find.text('Error loading novels'), findsOneWidget);
    });

    testWidgets('shows loading for 401 error', (tester) async {
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
            memberNovelsProviderV2.overrideWith((ref) async {
              await Future.delayed(Duration.zero);
              throw ApiException(401, 'Unauthorized');
            }),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MyNovelsScreen(),
          ),
        ),
      );
      
      // Initial pump
      await tester.pump();
      // Pump again
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Error loading novels'), findsNothing);
    });
    */

    testWidgets('empty state action navigates to create novel', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);
      await sessionNotifier.setSessionId('s-123');

      final router = GoRouter(
        initialLocation: '/my-novels',
        routes: [
          GoRoute(
            path: '/my-novels',
            builder: (context, state) => const MyNovelsScreen(),
          ),
          GoRoute(
            path: '/create-novel',
            builder: (context, state) =>
                const Scaffold(body: Text('Create Novel Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            localStorageRepositoryProvider.overrideWithValue(
              LocalStorageRepository(storageService),
            ),
            sessionProvider.overrideWith((ref) => sessionNotifier),
            memberNovelsProviderV2.overrideWith((ref) async => []),
          ],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(NovelEmptyState), findsOneWidget);

      // Tap create novel
      await tester.tap(find.text('Create Novel'));
      await tester.pumpAndSettle();

      expect(find.text('Create Novel Screen'), findsOneWidget);
    });

    testWidgets('navigates to auth when sign in tapped', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);

      // We need to use GoRouter to test navigation
      final router = GoRouter(
        initialLocation: '/my-novels',
        routes: [
          GoRoute(
            path: '/my-novels',
            builder: (context, state) => const MyNovelsScreen(),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) =>
                const Scaffold(body: Text('Auth Screen')),
          ),
        ],
      );

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
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Auth Screen'), findsOneWidget);
    });

    testWidgets('navigates to home when home icon tapped', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);

      final router = GoRouter(
        initialLocation: '/my-novels',
        routes: [
          GoRoute(
            path: '/my-novels',
            builder: (context, state) => const MyNovelsScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Home Screen')),
          ),
        ],
      );

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
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('shows member novels list with covers', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final sessionNotifier = SessionNotifier(storageService);
      await sessionNotifier.setSessionId('s-123');

      const novels = [
        Novel(
          id: 'n1',
          title: 'Cover Novel',
          author: 'Author 1',
          coverUrl: 'https://example.com/cover.jpg',
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      await HttpOverrides.runZoned(() async {
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
        expect(find.text('Cover Novel'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      }, createHttpClient: (_) => _MockHttpClient());
    });
  });
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value([]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
