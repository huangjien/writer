import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/screens/pattern_form_screen.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/services/patterns_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePatternsService extends PatternsService {
  FakePatternsService() : super(baseUrl: 'http://example.com');
  bool createCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;
  bool shouldFailDelete = false;
  bool improveCalled = false;
  Object? improveError;
  Map<String, dynamic>? improveResponse;
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

  @override
  Future<Map<String, dynamic>> improvePattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
  }) async {
    improveCalled = true;
    if (improveError != null) throw improveError!;
    return improveResponse ??
        <String, dynamic>{
          'title': title,
          'description': description,
          'content': content,
          'usage_rules': usageRules,
          'language': language,
        };
  }

  @override
  Future<bool> deletePattern(String id) async {
    deleteCalled = true;
    if (shouldFailDelete) return false;
    return true;
  }
}

Finder _fieldByKey(String key) => find.byKey(ValueKey(key));

Future<void> _setFieldText(WidgetTester tester, String key, String text) async {
  var finder = _fieldByKey(key);
  if (finder.evaluate().isEmpty) {
    final fields = find.byType(TextFormField);
    if (key == 'patternForm_title') {
      finder = fields.at(0);
    } else if (key == 'patternForm_description') {
      finder = fields.at(1);
    } else if (key == 'patternForm_content' ||
        key == 'patternForm_usageRules') {
      finder = fields.at(2);
    }
  }
  final field = tester.widget<TextFormField>(finder);
  field.controller!.text = text;
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  createCommonOverrides(
    SharedPreferences prefs,
    FakePatternsService svc, {
    bool isSignedIn = false,
    String? authState,
    Future<BackendUser?> Function(Ref)? currentUser,
    bool isAdmin = false,
  }) {
    return [
      appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
      themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
      sharedPreferencesProvider.overrideWithValue(prefs),
      isSignedInProvider.overrideWithValue(isSignedIn),
      authStateProvider.overrideWithValue(authState),
      currentUserProvider.overrideWith(currentUser ?? (ref) async => null),
      patternsServiceRefProvider.overrideWith((_) => svc),
      isAdminProvider.overrideWithValue(isAdmin),
    ];
  }

  testWidgets('PatternFormScreen requires title and content', (tester) async {
    final svc = FakePatternsService();
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(),
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
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _setFieldText(tester, 'patternForm_title', 'Title');
    await _setFieldText(tester, 'patternForm_description', 'Desc');

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_content', 'Content body');

    // Switch to Usage Rules tab
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_usageRules', '{"x":true}');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(svc.createCalled, isTrue);
    expect(svc.lastCreate?['usage_rules'], isA<Map<String, dynamic>>());
    expect((svc.lastCreate?['usage_rules'] as Map)['x'], isTrue);
  });

  testWidgets('PatternFormScreen invalid JSON shows error', (tester) async {
    final svc = FakePatternsService();
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await _setFieldText(tester, 'patternForm_title', 'Title');

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_content', 'Body');

    // Switch to Usage Rules tab
    await tester.tap(
      find.descendant(
        of: find.byType(Tab),
        matching: find.text('Usage Rules (JSON)'),
      ),
    );
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_usageRules', '{bad json]');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Invalid JSON'), findsOneWidget);
    expect(svc.createCalled, isTrue);
  });

  testWidgets('PatternFormScreen edit calls update', (tester) async {
    final svc = FakePatternsService();
    final prefs = await SharedPreferences.getInstance();
    const initial = Pattern(
      id: 'p1',
      title: 'Old',
      description: null,
      content: 'A',
      usageRules: {'a': 1},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();
    await _setFieldText(tester, 'patternForm_title', 'New');

    // Switch to Edit tab for Content
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_content', 'B');
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
    final prefs = await SharedPreferences.getInstance();
    const initial = Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      locked: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
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
    final prefs = await SharedPreferences.getInstance();
    const initial = Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      language: 'en',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
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
    final prefs = await SharedPreferences.getInstance();
    svc.pauseSave();

    const initial = Pattern(id: 'p1', title: 'Old', content: 'A');
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pump();

    // Tap save
    await _setFieldText(tester, 'patternForm_title', 'New Title');
    await tester.tap(find.text('Save'));
    await tester.pump(); // Start animation

    // Verify spinner is shown
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Finish save
    svc.resumeSave();
    await tester.pump();
  });

  testWidgets('PatternFormScreen AI button applies improved result', (
    tester,
  ) async {
    final svc = FakePatternsService();
    final prefs = await SharedPreferences.getInstance();
    svc.improveResponse = <String, dynamic>{
      'title': 'Better',
      'description': 'D2',
      'content': 'C2',
      'usage_rules': {'x': 1},
      'language': 'zh',
    };
    await tester.binding.setSurfaceSize(const Size(900, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_title', 'Old');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await _setFieldText(tester, 'patternForm_content', 'C1');

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(svc.improveCalled, isTrue);
    expect(find.text('Better'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
  });

  testWidgets('PatternFormScreen AI error shows message', (tester) async {
    final svc = FakePatternsService();
    final prefs = await SharedPreferences.getInstance();
    svc.improveError = Exception('Boom');
    await tester.pumpWidget(
      ProviderScope(
        overrides: createCommonOverrides(prefs, svc),
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _setFieldText(tester, 'patternForm_title', 'Old');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await _setFieldText(tester, 'patternForm_content', 'C1');

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Boom'), findsOneWidget);
  });

  testWidgets('PatternFormScreen delete confirms and calls service', (
    tester,
  ) async {
    final svc = FakePatternsService();

    const initial = Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      ownerId: 'u1',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patternsServiceRefProvider.overrideWith((_) => svc),
          isSignedInProvider.overrideWithValue(true),
          isAdminProvider.overrideWithValue(false),
          currentUserProvider.overrideWith((ref) async {
            return const BackendUser(id: 'u1');
          }),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PatternFormScreen)),
    )!;
    await tester.tap(find.text(l10n.delete));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);

    await tester.tap(find.text(l10n.delete).last);
    await tester.pumpAndSettle();

    expect(svc.deleteCalled, isTrue);
    expect(find.byType(PatternFormScreen), findsNothing);
  });

  testWidgets('PatternFormScreen delete cancel does not call service', (
    tester,
  ) async {
    final svc = FakePatternsService();

    const initial = Pattern(
      id: 'p1',
      title: 'Old',
      content: 'A',
      ownerId: 'u1',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patternsServiceRefProvider.overrideWith((_) => svc),
          isSignedInProvider.overrideWithValue(true),
          isAdminProvider.overrideWithValue(false),
          currentUserProvider.overrideWith((ref) async {
            return const BackendUser(id: 'u1');
          }),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternFormScreen(initial: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PatternFormScreen)),
    )!;
    await tester.tap(find.text(l10n.delete));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.text(l10n.cancel),
      ),
    );
    await tester.pumpAndSettle();

    expect(svc.deleteCalled, isFalse);
    expect(find.byType(PatternFormScreen), findsOneWidget);
  });
}
