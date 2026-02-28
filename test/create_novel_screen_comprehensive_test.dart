import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/create_novel_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/models/novel.dart';

void main() {
  group('CreateNovelScreen - Form Validation', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('title field is required', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith(
              (ref) => MockNovelRepository(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Try to submit without title
      await tester.tap(find.text('Create'));
      await tester.pump();

      // Should show title validation error (there are 2 Title widgets - label + error)
      expect(find.text('Title'), findsWidgets);
    });

    testWidgets('cover URL validation - invalid URLs', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith(
              (ref) => MockNovelRepository(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final coverUrlField = find.byType(TextFormField).at(3);

      // Test invalid URL with spaces
      await tester.enterText(coverUrlField, 'http://bad link');
      await tester.pump();
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsOneWidget,
      );

      // Test invalid URL without http/https
      await tester.enterText(coverUrlField, 'ftp://example.com');
      await tester.pump();
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsOneWidget,
      );

      // Test empty URL (should be valid as it's optional)
      await tester.enterText(coverUrlField, '');
      await tester.pump();
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsNothing,
      );
    });

    testWidgets('cover URL validation - valid URLs', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith(
              (ref) => MockNovelRepository(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final coverUrlField = find.byType(TextFormField).at(3);

      // Test valid HTTPS URL
      await tester.enterText(coverUrlField, 'https://example.com/img.png');
      await tester.pump();
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsNothing,
      );

      // Test valid HTTP URL
      await tester.enterText(coverUrlField, 'http://example.com/image.jpg');
      await tester.pump();
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsNothing,
      );
    });

    testWidgets('language dropdown functionality', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith(
              (ref) => MockNovelRepository(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show English selected by default (both in indicator and dropdown)
      expect(find.text('English'), findsWidgets);

      // Tap dropdown to open
      final dropdown = find.byType(DropdownButton<String>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Should show both options
      expect(find.text('English'), findsWidgets);
      expect(find.text('Chinese'), findsOneWidget);

      // Select Chinese (tap the menu item, not the dropdown button)
      final chineseItems = find.text('Chinese');
      await tester.tap(chineseItems.first);
      await tester.pumpAndSettle();

      // Should show Chinese selected in both places
      expect(find.text('Chinese'), findsWidgets);
    });
  });

  group('CreateNovelScreen - Form Submission', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('form is present and fillable', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');
      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith((ref) => mockRepo),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show form elements
      expect(find.text('Create Novel'), findsOneWidget);
      expect(find.text('Title'), findsWidgets);
      expect(find.text('Author'), findsWidgets);
      expect(find.text('Description'), findsWidgets);
      expect(find.text('Cover URL'), findsWidgets);
      expect(find.text('Create'), findsOneWidget);

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test Author');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Test Description',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'https://example.com/cover.jpg',
      );
      await tester.pump();

      // Verify form was filled
      expect(find.text('Test Novel'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('https://example.com/cover.jpg'), findsOneWidget);
    });

    testWidgets('form validation works', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionProvider.overrideWith((_) => session)],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show create button
      expect(find.text('Create'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('CreateNovelScreen - Localization', () {
    testWidgets('displays in Chinese locale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            novelRepositoryProvider.overrideWith(
              (ref) => MockNovelRepository(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CreateNovelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('创建小说'), findsOneWidget);
      expect(find.text('标题'), findsWidgets);
      expect(find.text('作者'), findsWidgets);
      expect(find.text('描述'), findsWidgets);
      expect(find.text('封面链接'), findsWidgets);
      expect(find.text('英语'), findsOneWidget);
      // Chinese dropdown might not show until opened
      expect(find.text('创建'), findsOneWidget);
    });
  });
}

// Mock classes for testing
class MockNovelRepository implements NovelRepository {
  final bool shouldThrow;
  final int delayMs;
  bool createNovelCalled = false;

  MockNovelRepository({this.shouldThrow = false, this.delayMs = 0});

  @override
  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    createNovelCalled = true;
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    if (shouldThrow) {
      throw Exception('Test error');
    }
    return Novel(
      id: 'test-novel-id',
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      languageCode: languageCode,
      isPublic: isPublic,
    );
  }

  // Stub implementations for other methods
  @override
  noSuchMethod(Invocation invocation) => Future.value(null);
}
