import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/screens/story_line_form_screen.dart';
import 'package:writer/services/story_lines_service.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/story_line_providers.dart';

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

void main() {
  testWidgets('StoryLineFormScreen requires content to save', (tester) async {
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Title',
    );
    await tester.pump();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isFalse);
  });

  testWidgets('StoryLineFormScreen create calls service', (tester) async {
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Title',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Desc',
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Content'),
      'Body',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usage Rules (JSON)'),
      '{"x":true}',
    );
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
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'C');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usage Rules (JSON)'),
      '{bad json]',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Invalid JSON'), findsOneWidget);
    expect(svc.createCalled, isTrue);
  });

  testWidgets('StoryLineFormScreen edit calls update', (tester) async {
    final svc = FakeStoryLinesService();
    final initial = const StoryLine(
      id: 's1',
      title: 'Old',
      description: null,
      content: 'A',
      usageRules: {'a': 1},
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'B');
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
    final svc = FakeStoryLinesService();
    final initial = const StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
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
    final svc = FakeStoryLinesService();
    final initial = const StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      language: 'en',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
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
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(svc.improveCalled, isTrue);
    expect(find.text('T+'), findsOneWidget);
  });

  testWidgets('AI ignores invalid JSON usage rules', (tester) async {
    final svc = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'C');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usage Rules (JSON)'),
      '{bad json]',
    );
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(svc.lastImprove?['usage_rules'], isNull);
  });

  testWidgets('Edit save falls back to initial usage rules when empty', (
    tester,
  ) async {
    final svc = FakeStoryLinesService();
    final initial = const StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      usageRules: {'a': 1},
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New');
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usage Rules (JSON)'),
      '',
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['usage_rules'], {'a': 1});
  });

  testWidgets('Improve error shows error text', (tester) async {
    final svc = FakeStoryLinesService()..throwImprove = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Improve failed'), findsOneWidget);
  });

  testWidgets('Create error shows error text', (tester) async {
    final svc = FakeStoryLinesService()..throwCreate = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLineFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'T');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'C');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Create failed'), findsOneWidget);
  });

  testWidgets('Shows spinner during save', (tester) async {
    final svc = FakeStoryLinesService()..pauseSave();
    final initial = const StoryLine(id: 's1', title: 'Old', content: 'A');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyLinesServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    svc.resumeSave();
    await tester.pump();
  });

  testWidgets('Delete dialog opens when canDelete is true', (tester) async {
    final initial = const StoryLine(
      id: 's1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => true),
          isAdminProvider.overrideWith((_) => true),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryLineFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final delete = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    expect(delete.onPressed, isNotNull);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
