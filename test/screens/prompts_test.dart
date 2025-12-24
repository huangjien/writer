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
    bool isPublic = false,
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

class TrackingPromptsService extends FakePromptsService {
  int searchCalls = 0;
  String? lastSearchQ;
  @override
  Future<List<Prompt>> searchPrompts(String query, {bool? isPublic}) async {
    searchCalls++;
    lastSearchQ = query;
    return prompts;
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
    final addIcon = find.byIcon(Icons.add);
    expect(addIcon, findsOneWidget);
    await tester.tap(addIcon);
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
    // Already in Edit tab by default
    // await tester.tap(find.text('Edit'));
    // await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Y');
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'B');
    await tester.pumpAndSettle();
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    final btn = tester.widget<ElevatedButton>(saveButton);
    expect(btn.onPressed, isNotNull);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
  });

  testWidgets('PromptsListScreen search debounced and thresholded', (
    tester,
  ) async {
    final svc = TrackingPromptsService();
    svc.prompts = [];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptsListScreen(service: svc, isAdmin: true),
      ),
    );
    await tester.pump();
    final searchField = find.widgetWithText(TextField, 'Search');
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'a');
    await tester.pump(const Duration(milliseconds: 300));
    expect(svc.searchCalls, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(svc.searchCalls, 0);
    await tester.enterText(searchField, 'ab');
    await tester.pump(const Duration(milliseconds: 300));
    expect(svc.searchCalls, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(svc.searchCalls, 1);
    expect(svc.lastSearchQ, 'ab');
  });

  testWidgets('PromptFormScreen save disabled until changes', (tester) async {
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
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);
    final btn = tester.widget<ElevatedButton>(saveButton);
    expect(btn.onPressed, isNull);
    // Already in Edit tab by default
    // await tester.tap(find.text('Edit'));
    // await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'B');
    await tester.pump();
    final btn2 = tester.widget<ElevatedButton>(saveButton);
    expect(btn2.onPressed, isNotNull);
  });

  testWidgets('PromptFormScreen allows editing when signed in', (tester) async {
    final svc = FakePromptsService();
    final initial = Prompt(
      id: '1',
      userId: null,
      promptKey: 'system.qa.autogen',
      language: 'en',
      content: 'A',
      isPublic: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PromptFormScreen(
          service: svc,
          initial: initial,
          isSignedIn: true,
          canEdit: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Not signed in'), findsNothing);

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    final btn = tester.widget<ElevatedButton>(saveButton);
    expect(btn.onPressed, isNull);

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.readOnly, isFalse);

    await tester.enterText(find.byType(TextFormField), 'B');
    await tester.pump();
    final btn2 = tester.widget<ElevatedButton>(saveButton);
    expect(btn2.onPressed, isNotNull);
  });
}
