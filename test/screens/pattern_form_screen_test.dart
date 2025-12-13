import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/screens/pattern_form_screen.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/services/patterns_service.dart';

class FakePatternsService extends PatternsService {
  FakePatternsService() : super(baseUrl: 'http://example.com');
  bool createCalled = false;
  bool updateCalled = false;
  Map<String, dynamic>? lastCreate;
  Map<String, dynamic>? lastUpdate;
  Completer<void>? _saveCompleter;

  void pauseSave() {
    _saveCompleter = Completer<void>();
  }

  void resumeSave() {
    _saveCompleter?.complete();
  }

  @override
  Future<Pattern> createPattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
    bool? isPublic,
  }) async {
    createCalled = true;
    lastCreate = {
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
      if (language != null) 'language': language,
    };
    return Pattern(
      id: 'new',
      title: title,
      description: description,
      content: content,
      usageRules: usageRules,
      language: language,
    );
  }

  @override
  Future<Pattern> updatePattern({
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
    updateCalled = true;
    lastUpdate = {
      'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (usageRules != null) 'usage_rules': usageRules,
      if (language != null) 'language': language,
      if (locked != null) 'locked': locked,
    };
    return Pattern(
      id: id,
      title: title ?? 'T',
      description: description,
      content: content ?? 'C',
      usageRules: usageRules,
      language: language,
      locked: locked,
    );
  }
}

void main() {
  testWidgets('PatternFormScreen requires title and content', (tester) async {
    final svc = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PatternFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isFalse);
  });

  testWidgets('PatternFormScreen create calls repository', (tester) async {
    final svc = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PatternFormScreen(),
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

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Content'),
      'Content body',
    );

    // Switch to Usage Rules tab
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usage Rules (JSON)'), // Field hint
      '{"x":true}',
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isTrue);
    expect(svc.lastCreate?['usage_rules'], isA<Map<String, dynamic>>());
    expect((svc.lastCreate?['usage_rules'] as Map)['x'], isTrue);
  });

  testWidgets('PatternFormScreen invalid JSON shows error', (tester) async {
    final svc = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PatternFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Title',
    );

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Content'),
      'Body',
    );

    // Switch to Usage Rules tab
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

  testWidgets('PatternFormScreen edit calls update', (tester) async {
    final svc = FakePatternsService();
    final initial = const Pattern(
      id: 'p1',
      title: 'Old',
      description: null,
      content: 'A',
      usageRules: {'a': 1},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New');

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Content'), 'B');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['id'], 'p1');
    expect(svc.lastUpdate?['title'], 'New');
    expect(svc.lastUpdate?['content'], 'B');
  });

  testWidgets('PatternFormScreen lock button toggles and sends update', (
    tester,
  ) async {
    final svc = FakePatternsService();
    final initial = const Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();

    // Verify initial state is unlocked
    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.byIcon(Icons.lock_open), findsOneWidget);

    // Tap lock button
    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pump();

    // Verify state changed to locked visually
    expect(find.text('Locked'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);

    // Save
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify update called with locked=true
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['locked'], isTrue);
  });

  testWidgets('PatternFormScreen language dropdown updates state', (
    tester,
  ) async {
    final svc = FakePatternsService();
    final initial = const Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      language: 'en',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();

    // Verify initial language
    expect(find.text('English'), findsOneWidget);

    // Open dropdown
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Select Chinese
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    // Verify selection
    expect(find.text('Chinese'), findsOneWidget);

    // Save
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify update called with language='zh'
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['language'], 'zh');
  });

  testWidgets('PatternFormScreen shows spinner during save', (tester) async {
    final svc = FakePatternsService();
    svc.pauseSave();

    final initial = const Pattern(id: 'p1', title: 'Old', content: 'A');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [patternsServiceRefProvider.overrideWith((_) => svc)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();

    // Tap save
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New Title');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump(); // Start animation

    // Verify spinner is shown in save button
    expect(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    // Verify spinner is also in AI button
    expect(
      find.descendant(
        of: find.byType(TextButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    // Finish save
    svc.resumeSave();
    await tester.pump();
  });
}
