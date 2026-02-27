import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/screens/story_line_form_screen.dart';
import 'package:writer/services/story_lines_service.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/story_line_providers.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

class FakeStoryLinesService extends StoryLinesService {
  FakeStoryLinesService() : super(baseUrl: 'http://example.com');

  bool createCalled = false;
  bool updateCalled = false;
  bool improveCalled = false;
  bool throwCreate = false;
  bool throwUpdate = false;
  bool throwImprove = false;
  Map<String, dynamic>? lastCreate;
  Map<String, dynamic>? lastUpdate;
  Map<String, dynamic>? lastImprove;
  Completer<void>? _saveCompleter;
  Completer<void>? _improveCompleter;

  void pauseSave() {
    _saveCompleter = Completer<void>();
  }

  void resumeSave() {
    _saveCompleter?.complete();
  }

  void pauseImprove() {
    _improveCompleter = Completer<void>();
  }

  void resumeImprove() {
    _improveCompleter?.complete();
  }

  @override
  Future<StoryLine> createStoryLine({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
    bool? isPublic,
  }) async {
    if (throwCreate) {
      throw ApiException(500, 'Create failed');
    }
    createCalled = true;
    lastCreate = {
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
      if (language != null) 'language': language,
      if (isPublic != null) 'is_public': isPublic,
    };
    return StoryLine(
      id: 'new',
      title: title,
      description: description,
      content: content,
      usageRules: usageRules,
      language: language,
      isPublic: isPublic,
    );
  }

  @override
  Future<StoryLine> updateStoryLine({
    required String id,
    String? title,
    String? description,
    String? content,
    Map<String, dynamic>? usageRules,
    String? language,
    bool? isPublic,
    bool? locked,
  }) async {
    if (_saveCompleter != null) {
      await _saveCompleter!.future;
    }
    if (throwUpdate) {
      throw ApiException(500, 'Update failed');
    }
    updateCalled = true;
    lastUpdate = {
      'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (usageRules != null) 'usage_rules': usageRules,
      if (language != null) 'language': language,
      if (isPublic != null) 'is_public': isPublic,
      if (locked != null) 'locked': locked,
    };
    return StoryLine(
      id: id,
      title: title ?? 'T',
      description: description,
      content: content ?? 'C',
      usageRules: usageRules,
      language: language,
      isPublic: isPublic,
      locked: locked,
    );
  }

  @override
  Future<Map<String, dynamic>> improveStoryLine({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
  }) async {
    if (_improveCompleter != null) {
      await _improveCompleter!.future;
    }
    if (throwImprove) {
      throw ApiException(500, 'Improve failed');
    }
    improveCalled = true;
    lastImprove = {
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
      if (language != null) 'language': language,
    };
    return {
      'title': '$title+',
      'description': description,
      'content': '$content+',
      'usage_rules': usageRules ?? {'a': 1},
      'language': language ?? 'en',
    };
  }
}

Finder _textFormField(String labelOrHint) {
  final byDecoration = find.byWidgetPredicate((w) {
    if (w is! TextField) return false;
    final decoration = w.decoration;
    final labelText = decoration?.labelText;
    final hintText = decoration?.hintText;
    if (labelText == labelOrHint || hintText == labelOrHint) return true;
    final label = decoration?.label;
    return label is Text && label.data == labelOrHint;
  });
  if (byDecoration.evaluate().isNotEmpty) return byDecoration.first;

  final byTextDescendant = find.widgetWithText(TextField, labelOrHint);
  if (byTextDescendant.evaluate().isNotEmpty) return byTextDescendant.first;

  final allFields = find.byType(TextField);
  if (labelOrHint == 'Title') return allFields.at(0);
  if (labelOrHint == 'Description') return allFields.at(1);
  if (labelOrHint == 'Content') return allFields.at(2);
  if (labelOrHint == 'Usage Rules (JSON)') return allFields.at(3);
  return allFields.first;
}

List<dynamic> createCommonProviderOverrides(SharedPreferences prefs) {
  final appSettings = AppSettingsNotifier(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);
  final motion = MotionSettingsNotifier(prefs);
  final storageService = LocalStorageService(prefs);

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    localStorageRepositoryProvider.overrideWithValue(
      LocalStorageRepository(storageService),
    ),
    sessionProvider.overrideWith((ref) => SessionNotifier(storageService)),
    appSettingsProvider.overrideWith((_) => appSettings),
    ttsSettingsProvider.overrideWith((_) => ttsSettings),
    motionSettingsProvider.overrideWith((_) => motion),
    aiChatServiceProvider.overrideWith(
      (ref) => AiChatService(RemoteRepository('http://localhost:5600/')),
    ),
  ];
}

void main() {
  testWidgets('StoryLineFormScreen requires content to save', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ex = tester.takeException();
    if (ex != null) fail(ex.toString());

    await tester.enterText(_textFormField('Title'), 'Title');
    await tester.pump();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isFalse);
  });

  testWidgets('StoryLineFormScreen create calls service', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'Title');
    await tester.enterText(_textFormField('Description'), 'Desc');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'Body');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Usage Rules (JSON)'), '{"x":true}');
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isTrue);
    expect(svc.lastCreate?['title'], 'Title');
    expect((svc.lastCreate?['usage_rules'] as Map)['x'], isTrue);
  });

  testWidgets('StoryLineFormScreen invalid JSON shows error but still saves', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'C');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Usage Rules (JSON)'), '{bad json]');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Invalid JSON'), findsOneWidget);
    expect(svc.createCalled, isTrue);
  });

  testWidgets('StoryLineFormScreen edit calls update', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    const initial = StoryLine(
      id: 's1',
      title: 'Old',
      description: null,
      content: 'A',
      usageRules: {'a': 1},
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Title'), 'New');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'B');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['id'], 's1');
    expect(svc.lastUpdate?['title'], 'New');
    expect(svc.lastUpdate?['content'], 'B');
  });

  testWidgets('StoryLineFormScreen lock toggle updates and saves', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    const initial = StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlocked'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pump();
    expect(find.text('Locked'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['locked'], isTrue);
  });

  testWidgets('StoryLineFormScreen language dropdown updates state and saves', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    const initial = StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      language: 'en',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['language'], 'zh');
  });

  testWidgets('AI button triggers improve and updates fields', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(svc.improveCalled, isTrue);
    expect(find.text('T+'), findsOneWidget);
  });

  testWidgets('AI ignores invalid JSON usage rules', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'C');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Usage Rules (JSON)'), '{bad json]');
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(svc.lastImprove?['usage_rules'], isNull);
  });

  testWidgets('Edit save falls back to initial usage rules when empty', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService();
    const initial = StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      usageRules: {'a': 1},
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'New');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Usage Rules (JSON)'), '');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['usage_rules'], {'a': 1});
  });

  testWidgets('Improve error shows error text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService()..throwImprove = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Improve failed'), findsOneWidget);
  });

  testWidgets('Create error shows error text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService()..throwCreate = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(_textFormField('Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Create failed'), findsOneWidget);
  });

  testWidgets('Shows spinner during save', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = FakeStoryLinesService()..pauseSave();
    const initial = StoryLine(id: 's1', title: 'Old', content: 'A');
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          storyLinesServiceRefProvider.overrideWith((_) => svc),
          isAdminProvider.overrideWithValue(false),
          appSettingsProvider.overrideWith((_) => appSettings),
          ttsSettingsProvider.overrideWith((_) => ttsSettings),
          motionSettingsProvider.overrideWith((_) => motion),
          aiChatServiceProvider.overrideWith(
            (ref) => AiChatService(RemoteRepository('http://localhost:5600/')),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormField('Title'), 'New');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    svc.resumeSave();
    await tester.pump();
  });

  testWidgets('Delete dialog opens when canDelete is true', (tester) async {
    const initial = StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAdminProvider.overrideWith((_) => true),
          isSignedInProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.text('Delete');
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsNothing);
  });
}
