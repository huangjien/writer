import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:writer/models/prompt.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/screens/prompts_list_screen.dart';
import 'package:writer/screens/prompt_form_screen.dart';
import 'package:writer/l10n/app_localizations.dart';

class FakePromptsService extends PromptsService {
  FakePromptsService() : super(baseUrl: 'http://test');
  List<Prompt> prompts = [];
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  bool throwOnUpdate = false;
  bool throwOnDelete = false;
  bool? lastFetchIsPublic;
  bool? lastCreatedIsPublic;
  bool createCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;
  @override
  Future<List<Prompt>> fetchPrompts({bool? isPublic}) async {
    lastFetchIsPublic = isPublic;
    if (throwOnFetch) {
      throw ApiException(500, 'fail');
    }
    return prompts;
  }

  @override
  Future<Prompt> createPrompt({
    required String promptKey,
    required String language,
    required String content,
    bool isPublic = false,
  }) async {
    createCalled = true;
    lastCreatedIsPublic = isPublic;
    if (throwOnCreate) {
      throw ApiException(500, 'fail');
    }
    final p = Prompt(
      id: 'new',
      userId: null,
      promptKey: promptKey,
      language: language,
      content: content,
      isPublic: isPublic,
    );
    prompts = [...prompts, p];
    return p;
  }

  @override
  Future<Prompt> updatePrompt({
    required String id,
    required String content,
  }) async {
    updateCalled = true;
    if (throwOnUpdate) {
      throw ApiException(500, 'fail');
    }
    prompts = prompts
        .map(
          (e) => e.id == id
              ? Prompt(
                  id: e.id,
                  userId: e.userId,
                  promptKey: e.promptKey,
                  language: e.language,
                  content: content,
                  isPublic: e.isPublic,
                  createdAt: e.createdAt,
                  updatedAt: e.updatedAt,
                )
              : e,
        )
        .toList();
    final p = prompts.firstWhere((e) => e.id == id);
    return p;
  }

  @override
  Future<bool> deletePrompt(String id) async {
    deleteCalled = true;
    if (throwOnDelete) {
      throw ApiException(500, 'fail');
    }
    prompts = prompts.where((e) => e.id != id).toList();
    return true;
  }
}

void main() {
  testWidgets('PromptsListScreen renders items and badges', (tester) async {
    final svc = FakePromptsService();
    svc.prompts = [
      Prompt(
        id: '1',
        userId: 'u1',
        promptKey: 'system.beta.male',
        language: 'en',
        content: 'A',
        isPublic: false,
      ),
      Prompt(
        id: '2',
        userId: null,
        promptKey: 'system.beta.editor',
        language: 'zh',
        content: 'B',
        isPublic: true,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pump();
    expect(find.text('Prompts'), findsOneWidget);
    expect(find.text('system.beta.male'), findsOneWidget);
    expect(find.text('system.beta.editor'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
  });

  testWidgets('PromptsListScreen error handling', (tester) async {
    final svc = FakePromptsService();
    svc.throwOnFetch = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc),
      ),
    );
    await tester.pump();
    expect(find.textContaining('ApiException'), findsOneWidget);
  });

  testWidgets('Admin toggle switches public view', (tester) async {
    final svc = FakePromptsService();
    svc.prompts = [];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pump();
    expect(svc.lastFetchIsPublic, anyOf(isNull, isFalse));
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(svc.lastFetchIsPublic, isTrue);
  });

  testWidgets('Make Public action publishes prompt', (tester) async {
    final svc = FakePromptsService();
    svc.prompts = [
      Prompt(
        id: '1',
        userId: 'u1',
        promptKey: 'system.beta.male',
        language: 'en',
        content: 'A',
        isPublic: false,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pumpAndSettle();
    final publicIcon = find.byIcon(Icons.public);
    expect(publicIcon, findsOneWidget);
    await tester.ensureVisible(publicIcon);
    await tester.tap(publicIcon);
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(svc.lastCreatedIsPublic, isTrue);
  });

  testWidgets('New Prompt dialog creates public when admin', (tester) async {
    final svc = FakePromptsService();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'New Prompt'));
    await tester.pump();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'system.beta.male');
    await tester.enterText(fields.at(1), 'en');
    await tester.enterText(fields.at(2), 'X');
    final dlgSwitch = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Switch),
    );
    await tester.tap(dlgSwitch);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isTrue);
    expect(svc.lastCreatedIsPublic, isTrue);
  });

  testWidgets('PromptFormScreen validates content required', (tester) async {
    final svc = FakePromptsService();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptFormScreen(service: svc),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isFalse);
  });

  testWidgets('PromptFormScreen create calls service', (tester) async {
    final svc = FakePromptsService();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptFormScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'Y');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isTrue);
  });

  testWidgets('PromptFormScreen edit calls update', (tester) async {
    final svc = FakePromptsService();
    final initial = Prompt(
      id: '1',
      userId: 'u1',
      promptKey: 'system.beta.male',
      language: 'en',
      content: 'A',
      isPublic: false,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptFormScreen(service: svc, initial: initial),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'B');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
  });
}
