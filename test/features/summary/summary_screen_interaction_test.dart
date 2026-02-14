import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/screens/summary_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';

class FakeNovelRepository extends Fake implements NovelRepository {
  final Summary? summary;

  FakeNovelRepository({this.summary});

  @override
  Future<List<Summary>> fetchSummaries(String novelId) async =>
      summary != null ? [summary!] : [];

  @override
  Future<Summary> createSummary(Summary summary) async {
    return summary.copyWith(id: 'new-id');
  }

  @override
  Future<Summary> updateSummary(Summary summary) async {
    return summary;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpSummaryScreen(
    WidgetTester tester, {
    required ProviderContainer container,
    String novelId = 'novel-1',
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SummaryScreen(novelId: novelId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('SummaryScreen loads and displays all tabs', (tester) async {
    final summary = Summary(
      id: 'summary-1',
      idx: 0,
      novelId: 'novel-1',
      sentenceSummary: 'Sentence',
      paragraphSummary: 'Paragraph',
      pageSummary: 'Page',
      expandedSummary: 'Expanded',
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(LocalStorageService(prefs)),
        ),
        novelProvider.overrideWith(
          (ref, id) async => const Novel(
            id: 'novel-1',
            title: 'Test Novel',
            isPublic: false,
            languageCode: 'en',
          ),
        ),
        novelRepositoryProvider.overrideWithValue(
          FakeNovelRepository(summary: summary),
        ),
      ],
    );
    addTearDown(container.dispose);

    await pumpSummaryScreen(tester, container: container);

    // Check initial tab (Sentence Summary)
    expect(find.text('Sentence Summary'), findsOneWidget);
    expect(find.text('Sentence'), findsOneWidget);

    // Switch to Paragraph Summary
    await tester.tap(find.text('Paragraph Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Paragraph'), findsOneWidget);

    // Switch to Page Summary
    await tester.tap(find.text('Page Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Page'), findsOneWidget);

    // Switch to Expanded Summary
    await tester.tap(find.text('Expanded Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Expanded'), findsOneWidget);
  });

  testWidgets('SummaryScreen edits and enables save button', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(LocalStorageService(prefs)),
        ),
        novelProvider.overrideWith(
          (ref, id) async => const Novel(
            id: 'novel-1',
            title: 'Test Novel',
            isPublic: false,
            languageCode: 'en',
          ),
        ),
        novelRepositoryProvider.overrideWithValue(FakeNovelRepository()),
      ],
    );
    addTearDown(container.dispose);

    await pumpSummaryScreen(tester, container: container);

    // Go to Edit tab of Sentence Summary
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Find text field and enter text
    final textField = find.byKey(const Key('sentence_summary_field'));
    await tester.enterText(textField, 'New Sentence');
    await tester.pumpAndSettle();

    // Check save button is enabled
    final saveButtonFinder = find
        .widgetWithText(NeumorphicButton, 'Save')
        .first;
    expect(saveButtonFinder, findsOneWidget);
    final button = tester.widget<NeumorphicButton>(saveButtonFinder);
    expect(
      button.onPressed,
      isNotNull,
      reason: 'Save button should be enabled',
    );

    // Tap save
    await tester.tap(saveButtonFinder);
    await tester
        .pumpAndSettle(); // Wait for save operation and snackbar animation

    // Should show saved snackbar
    expect(find.text('Saved'), findsOneWidget);
  }, semanticsEnabled: false);

  testWidgets('SummaryScreen toggles AI Coach', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(LocalStorageService(prefs)),
        ),
        novelProvider.overrideWith(
          (ref, id) async => const Novel(
            id: 'novel-1',
            title: 'Test Novel',
            isPublic: false,
            languageCode: 'en',
          ),
        ),
        novelRepositoryProvider.overrideWithValue(FakeNovelRepository()),
      ],
    );
    addTearDown(container.dispose);

    await pumpSummaryScreen(tester, container: container);

    // Go to Edit tab
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Find AI Coach toggle button (icon button)
    // The icon is Icons.auto_awesome_outlined initially
    final aiButton = find.byIcon(Icons.auto_awesome_outlined);
    expect(aiButton, findsOneWidget);

    await tester.tap(aiButton);
    await tester.pumpAndSettle();

    // Should verify coach widget appears or icon changes
    // The coach widget is SnowflakeCoachWidget
    // But since we are not mocking the AI service properly here, it might just show up.
    // Let's check for the icon change if possible, or some text in the coach widget.
    // The coach widget might show "AI Coach" or something similar?
    // Based on implementation, it shows "Snowflake Method Coach" or similar if we look at that widget.
    // But let's just check the icon changed to auto_awesome (filled)
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  }, semanticsEnabled: false);
}
