import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/library/library_screen.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Golden: Offline ring row (en)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.06,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    // Standardize viewport for stable golden rendering (matches 768px width goldens)
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();

    final app = await buildAppScope(
      prefs: prefs,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          platform: TargetPlatform.android,
          visualDensity: VisualDensity.standard,
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LibraryScreen(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Locate the first offline ring row via its text and capture the row.
    final notStartedText = find.text('Not started');
    expect(notStartedText, findsWidgets);
    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);

    // Capture the row container (Actions ancestor) for full 768px width
    final fullRowEn = find.ancestor(
      of: firstTile,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowEn, findsOneWidget);
    await expectLater(
      fullRowEn,
      matchesGoldenFile('goldens/library_offline_ring_row_en.png'),
    );
  });

  testWidgets('Golden: Offline ring row (zh)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.06,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    // Standardize viewport for stable golden rendering (matches 768px width goldens)
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();

    final app = await buildAppScope(
      prefs: prefs,
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          platform: TargetPlatform.android,
          visualDensity: VisualDensity.standard,
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LibraryScreen(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Locate the first offline ring row via its text and capture the row (Chinese locale).
    final notStartedZh = find.text('尚未开始');
    expect(notStartedZh, findsWidgets);
    final firstTileZh = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTileZh, findsOneWidget);

    // Capture the row container (Actions ancestor) for full 768px width
    final fullRowZh = find.ancestor(
      of: firstTileZh,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowZh, findsOneWidget);
    await expectLater(
      fullRowZh,
      matchesGoldenFile('goldens/library_offline_ring_row_zh.png'),
    );
  });
}
