import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/main.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/providers.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  TemplateItem? lastItem;
  String? updatedId;
  String? updatedTitle;
  String? updatedSummaries;
  String? updatedLanguageCode;
  String? getById;
  @override
  Future<String?> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {
    lastItem = item;
    return 't-1';
  }

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    getById = id;
    final title = updatedTitle ?? lastItem?.name ?? 'Existing';
    final summaries = updatedSummaries ?? lastItem?.description ?? 'Old';
    final language = updatedLanguageCode ?? 'zh';
    return SceneTemplateRow(
      id: id,
      idx: 1,
      title: title,
      sceneSummaries: summaries,
      sceneSynopses: null,
      languageCode: language,
      createdBy: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  @override
  Future<void> updateSceneTemplate(
    String id, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
  }) async {
    updatedId = id;
    updatedTitle = title;
    updatedSummaries = summaries;
    updatedLanguageCode = languageCode;
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

class MockSession extends Mock implements Session {}

class MockAiChatService extends Mock implements AiChatService {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SceneTemplatesScreen validates and saves', (tester) async {
    final repo = CapturingLocalRepo();
    final session = MockSession();
    final ai = MockAiChatService();
    when(
      () => ai.embed(any(), model: any(named: 'model')),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWith((_) => repo),
          aiChatServiceProvider.overrideWithValue(ai),
          supabaseEnabledProvider.overrideWith((_) => true),
          supabaseSessionProvider.overrideWith((_) => session),
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
    await tester.pump();

    expect(repo.lastItem?.name, 'Battle Scene');
    expect(repo.lastItem?.description, 'High tension encounter');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen retrieves profile and enables Save', (
    tester,
  ) async {
    final repo = CapturingLocalRepo();
    final remote = FakeRemoteRepo('# Profile');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
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

    expect(find.text('Profile retrieved'), findsOneWidget);

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save');
    final saveButton = tester.widget<ElevatedButton>(saveButtonFinder);
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('SceneTemplatesScreen shows no-profile snackbar when null', (
    tester,
  ) async {
    final repo = CapturingLocalRepo();
    final remote = FakeRemoteRepo(null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
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
    final repo = CapturingLocalRepo();
    final session = MockSession();
    final ai = MockAiChatService();
    when(
      () => ai.embed(any(), model: any(named: 'model')),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repo),
          aiChatServiceProvider.overrideWithValue(ai),
          supabaseEnabledProvider.overrideWith((_) => true),
          supabaseSessionProvider.overrideWith((_) => session),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1', templateId: 't-99'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(repo.getById, 't-99');

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

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repo.updatedId, 't-99');
    expect(repo.updatedTitle, 'Updated Title');
    expect(repo.updatedSummaries, 'Updated Body');
    expect(repo.updatedLanguageCode, 'zh');
    expect(find.text('Saved'), findsOneWidget);
  });
}
