import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/summary/screens/scenes/scene_templates_screen.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class CapturingTemplateRepo extends TemplateRepository {
  CapturingTemplateRepo() : super(RemoteRepository('http://test/'));

  String? upsertedId;
  String? upsertedTitle;
  String? upsertedSummaries;
  String? upsertedLanguageCode;
  String? refreshedId;
  String? generatedName;
  bool generateShouldFail = false;
  bool generateReturnsNull = false;

  @override
  Future<String?> upsertSceneTemplate({
    String? id,
    String? title,
    String? summaries,
    String? synopses,
    String? languageCode,
  }) async {
    upsertedId = id;
    upsertedTitle = title;
    upsertedSummaries = summaries;
    upsertedLanguageCode = languageCode;
    return id ?? 't-1';
  }

  @override
  Future<Map<String, dynamic>?> generateSceneTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    generatedName = name;
    if (generateShouldFail) throw Exception('Network error');
    if (generateReturnsNull) return null;
    return {'id': 'generated-id-123', 'title': title};
  }

  int getTemplateCallCount = 0;

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    refreshedId = id;
    getTemplateCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (getTemplateCallCount == 1) {
      return SceneTemplateRow(
        id: id,
        idx: 1,
        title: upsertedTitle ?? 'Existing',
        sceneSummaries: '',
        sceneSynopses: '',
        languageCode: upsertedLanguageCode ?? 'zh',
        createdBy: null,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    }

    return SceneTemplateRow(
      id: id,
      idx: 1,
      title: upsertedTitle ?? 'Existing',
      sceneSummaries: upsertedSummaries ?? 'Old',
      sceneSynopses: 'AI-generated synopsis content',
      languageCode: upsertedLanguageCode ?? 'zh',
      createdBy: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }
}

class FakeRemoteRepo extends RemoteRepository {
  FakeRemoteRepo(this._profile) : super('http://test/');
  final Object? _profile;

  @override
  Future<String?> fetchSceneProfile(String name) async {
    final v = _profile;
    if (v is Exception) throw v;
    if (v is String) return v;
    return null;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SceneTemplatesScreen validates and saves', (tester) async {
    SharedPreferences.setMockInitialValues({'backend_session_id': 's-1'});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    final templates = CapturingTemplateRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith((_) => session),
          templateRepositoryProvider.overrideWithValue(templates),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Edit tab
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final descFieldPre = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    await tester.enterText(descFieldPre, 'X');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final nameField = find.widgetWithText(TextFormField, 'Template Name');
    final descField = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    await tester.enterText(nameField, 'Battle Scene');
    await tester.enterText(descField, 'High tension encounter');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(templates.upsertedId, isNull);
    expect(templates.upsertedTitle, 'Battle Scene');
    expect(templates.upsertedSummaries, 'High tension encounter');
    expect(templates.refreshedId, 't-1');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen retrieves profile and enables Save', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = CapturingTemplateRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          templateRepositoryProvider.overrideWithValue(templates),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'X',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.download));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate polling - first poll returns empty, second returns content
    await tester.pump(const Duration(seconds: 8));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));

    // Wait for everything to finish
    await tester.pumpAndSettle();

    expect(find.text('Profile retrieved'), findsOneWidget);

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen shows no-profile snackbar when null', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = CapturingTemplateRepo();
    templates.generateReturnsNull = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          templateRepositoryProvider.overrideWithValue(templates),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'X',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.download));
    await tester.pumpAndSettle();

    expect(find.text('No profile found'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen updates existing templateId', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'backend_session_id': 's-1'});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    final templates = CapturingTemplateRepo();
    templates.upsertedLanguageCode = 'zh';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith((_) => session),
          templateRepositoryProvider.overrideWithValue(templates),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1', templateId: 't-99'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'Updated Title',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter description in Markdown...'),
      'Updated Body',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(templates.upsertedId, 't-99');
    expect(templates.upsertedTitle, 'Updated Title');
    expect(templates.upsertedSummaries, 'Updated Body');
    expect(templates.upsertedLanguageCode, 'zh');
    expect(templates.refreshedId, 't-99');
    expect(find.text('Saved'), findsOneWidget);
  });
}
