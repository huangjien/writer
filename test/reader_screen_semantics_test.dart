import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ReaderScreen chapter tiles have semantics labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chaptersProvider.overrideWith(
            (ref, novelId) async => const [
              Chapter(
                id: 'chap-001-01',
                novelId: 'novel-001',
                idx: 1,
                title: 'Into the Woods',
                content: 'x',
              ),
              Chapter(
                id: 'chap-001-02',
                novelId: 'novel-001',
                idx: 2,
                title: 'Hidden Creek',
                content: 'x',
              ),
            ],
          ),
          novelProvider.overrideWith(
            (ref, novelId) async => const Novel(
              id: 'novel-001',
              title: 'The Whispering Forest',
              languageCode: 'en',
              isPublic: true,
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: 'novel-001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Chapter 1: Into the Woods'), findsOneWidget);
    expect(find.bySemanticsLabel('Chapter 2: Hidden Creek'), findsOneWidget);
  });
}
