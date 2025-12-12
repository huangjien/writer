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

  @override
  Future<Pattern> createPattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
  }) async {
    createCalled = true;
    lastCreate = {
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
    };
    return Pattern(
      id: 'new',
      title: title,
      description: description,
      content: content,
      usageRules: usageRules,
    );
  }

  @override
  Future<Pattern> updatePattern({
    required String id,
    String? title,
    String? description,
    String? content,
    Map<String, dynamic>? usageRules,
  }) async {
    updateCalled = true;
    lastUpdate = {
      'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (usageRules != null) 'usage_rules': usageRules,
    };
    return Pattern(
      id: id,
      title: title ?? 'T',
      description: description,
      content: content ?? 'C',
      usageRules: usageRules,
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
    final fields = find.byType(TextFormField);
    // Title
    await tester.enterText(fields.at(0), 'Title');
    // Description (optional)
    await tester.enterText(fields.at(1), 'Desc');
    // Content
    await tester.enterText(fields.at(2), 'Content body');
    // Usage (JSON)
    await tester.enterText(fields.at(3), '{"x":true}');
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
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Title');
    await tester.enterText(fields.at(2), 'Body');
    await tester.enterText(fields.at(3), '{bad json]');
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
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'New');
    await tester.enterText(fields.at(2), 'B');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.updateCalled, isTrue);
    expect(svc.lastUpdate?['id'], 'p1');
    expect(svc.lastUpdate?['title'], 'New');
    expect(svc.lastUpdate?['content'], 'B');
  });
}
