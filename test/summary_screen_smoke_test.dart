import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers.dart';

void main() {
  testWidgets('Summary screen shows for novel route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith((ref, novelId) async {
          return const Novel(
            id: 'novel-001',
            title: 'The Whispering Forest',
            author: 'A. Storyteller',
            description: 'Desc',
            coverUrl: null,
            languageCode: 'en',
            isPublic: true,
          );
        }),
        chaptersProvider.overrideWith((ref, novelId) async {
          return const [
            Chapter(
              id: 'chap-001-01',
              novelId: 'novel-001',
              idx: 1,
              title: 'Into the Woods',
              content: 'Hello world',
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/novel/novel-001/summary');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Summary'), findsOneWidget);
    expect(find.textContaining('Chapters'), findsWidgets);
  });
}
