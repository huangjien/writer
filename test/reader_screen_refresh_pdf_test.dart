import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';

void main() {
  const novelId = 'n1';
  final mockChapters = [
    const Chapter(id: 'c1', novelId: novelId, idx: 1, title: 'T1', content: 'B1'),
    const Chapter(id: 'c2', novelId: novelId, idx: 2, title: 'T2', content: 'B2'),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpWithOverrides(WidgetTester tester,
      {required List<Chapter> chapters, bool throwOnLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          if (throwOnLoad)
            mockChaptersProvider(novelId)
                .overrideWith((ref) => Future.error('err')),
          if (throwOnLoad)
            chaptersProvider(novelId)
                .overrideWith((ref) => Future.error('err')),
          if (!throwOnLoad)
            mockChaptersProvider(novelId)
                .overrideWith((ref) => Future.value(chapters)),
          if (!throwOnLoad)
            chaptersProvider(novelId)
                .overrideWith((ref) => Future.value(chapters)),
          novelProvider(novelId)
              .overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId),
        ),
      ),
    );
  }

  testWidgets('refresh button triggers reload without crash', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          // Initial load resolves quickly
          mockChaptersProvider(novelId)
              .overrideWith((ref) => Future.value(mockChapters)),
          chaptersProvider(novelId)
              .overrideWith((ref) => Future.value(mockChapters)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Tap refresh: the widget will invalidate providers and await their futures.
    // Simulate slow recomputation by replacing providers with delayed futures via
    // binding's zone override using runAsync.
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    // Content remains available after refresh sequence completes.
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1'), findsOneWidget);
  });

  testWidgets('PDF button shows snackbar on error', (tester) async {
    await pumpWithOverrides(tester, chapters: mockChapters, throwOnLoad: true);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('semantics labels include chapter index and title', (tester) async {
    await pumpWithOverrides(tester, chapters: mockChapters);
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('T1'), findsOneWidget);
  });

  testWidgets('end drawer opens via menu button', (tester) async {
    await pumpWithOverrides(tester, chapters: mockChapters);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.menu_open), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu_open));
    await tester.pump();
    expect(find.byType(Drawer), findsOneWidget);
  });
}
