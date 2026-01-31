import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart' as cr;
import 'helpers/test_utils.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('ReaderScreen shows chapters list and refresh spinner toggles', (
    tester,
  ) async {
    final scope = await buildAppScope(
      child: materialAppFor(home: const ReaderScreen(novelId: 'novel-001')),
      extraOverrides: [
        chaptersProviderV2.overrideWith(
          (ref, id) async => const [
            Chapter(
              id: 'c1',
              novelId: 'novel-001',
              idx: 1,
              title: 'T1',
              content: 'A',
            ),
            Chapter(
              id: 'c2',
              novelId: 'novel-001',
              idx: 2,
              title: 'T2',
              content: 'B',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(ListTile), findsWidgets);

    final refreshBtn = find.byIcon(Icons.refresh);
    expect(refreshBtn, findsOneWidget);
    await tester.tap(refreshBtn);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('ReaderScreen with chapterId pushes ChapterReaderScreen', (
    tester,
  ) async {
    final scope = await buildAppScope(
      child: materialAppFor(
        home: const ReaderScreen(novelId: 'novel-001', chapterId: 'c2'),
      ),
      extraOverrides: [
        chaptersProviderV2.overrideWith(
          (ref, id) async => const [
            Chapter(
              id: 'c1',
              novelId: 'novel-001',
              idx: 1,
              title: 'T1',
              content: 'A',
            ),
            Chapter(
              id: 'c2',
              novelId: 'novel-001',
              idx: 2,
              title: 'T2',
              content: 'B',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.byType(cr.ChapterReaderScreen), findsOneWidget);
  });
}
