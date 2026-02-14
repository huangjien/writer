import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/create_novel_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

void main() {
  group('CreateNovelScreen - Cover URL Length Validation', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('rejects cover URL longer than 2048 characters', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Create a URL longer than 2048 characters
      final longUrl = 'https://example.com/${'a' * 2100}';
      await tester.enterText(coverUrlField, longUrl);
      await tester.pump();

      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsOneWidget,
      );
    });

    testWidgets('accepts cover URL under 2048 characters', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Create a URL under 2048 characters
      final shortUrl = 'https://example.com/${'a' * 100}';
      await tester.enterText(coverUrlField, shortUrl);
      await tester.pump();

      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsNothing,
      );
    });
  });

  group('CreateNovelScreen - Form Submission', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows loading indicator during submission', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository(delayMs: 100);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Wait for submission to complete
      await tester.pumpAndSettle();

      // Loading indicator should be gone
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows error message on submission failure', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository(shouldThrow: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Fill in form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show error message - check for any error text widget
      final errorTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.contains('Test error'),
      );
      expect(errorTextFinder, findsOneWidget);
    });

    testWidgets('clears error message on new submission attempt', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository(shouldThrow: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Fill in form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show error message
      final errorTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.contains('Test error'),
      );
      expect(errorTextFinder, findsOneWidget);

      // Update repo to not throw
      mockRepo.shouldThrow = false;

      await tester.tap(createButton);
      await tester.pump();

      // Error message should be cleared
      expect(errorTextFinder, findsNothing);

      // Wait for success
      await tester.pumpAndSettle();
    });
  });

  group('CreateNovelScreen - Form Data Handling', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('submits with trimmed title using default when empty', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Enter title with extra whitespace
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  Test Novel  ',
      );
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should have called createNovel with trimmed title
      expect(mockRepo.createNovelCalled, isTrue);
      expect(mockRepo.lastCreateParams?['title'], 'Test Novel');
    });

    testWidgets('submits with trimmed optional fields', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Enter optional fields with extra whitespace
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '  Test Author  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '  Test Description  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '  https://example.com/cover.jpg  ',
      );
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should have called createNovel with trimmed values
      expect(mockRepo.createNovelCalled, isTrue);
      expect(mockRepo.lastCreateParams?['author'], 'Test Author');
      expect(mockRepo.lastCreateParams?['description'], 'Test Description');
      expect(
        mockRepo.lastCreateParams?['coverUrl'],
        'https://example.com/cover.jpg',
      );
    });

    testWidgets('submits with null for empty optional fields', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Only fill required field
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should have called createNovel with null for optional fields
      expect(mockRepo.createNovelCalled, isTrue);
      expect(mockRepo.lastCreateParams?['author'], isNull);
      expect(mockRepo.lastCreateParams?['description'], isNull);
      expect(mockRepo.lastCreateParams?['coverUrl'], isNull);
    });

    testWidgets('submits with selected language code', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Change language to Chinese
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chinese'));
      await tester.pumpAndSettle();

      // Fill in title
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should have called createNovel with zh language code
      expect(mockRepo.createNovelCalled, isTrue);
      expect(mockRepo.lastCreateParams?['languageCode'], 'zh');
    });
  });

  group('CreateNovelScreen - Edge Cases', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('handles rapid submission attempts', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository(delayMs: 200);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Fill in form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Novel');
      await tester.pumpAndSettle();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pump();
      await tester.tap(createButton);
      await tester.pump();

      // Should only call createNovel once (button disabled during submission)
      expect(mockRepo.createNovelCallCount, 1);

      // Wait for submission to complete
      await tester.pumpAndSettle();
    });

    testWidgets('does not submit when form is invalid', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('test-session-id');

      final mockRepo = MockNovelRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((_) => session),
            isSignedInProvider.overrideWithValue(true),
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

      // Don't fill in required title field
      // Enter invalid cover URL
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'http://bad link',
      );
      await tester.pump();

      final createButton = find.byType(NeumorphicButton);
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pump();

      // Should not call createNovel
      expect(mockRepo.createNovelCalled, isFalse);
    });
  });
}

// Mock classes for testing
class MockNovelRepository implements NovelRepository {
  bool shouldThrow = false;
  int delayMs = 0;
  bool createNovelCalled = false;
  int createNovelCallCount = 0;
  Map<String, dynamic>? lastCreateParams;

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
    createNovelCallCount++;
    lastCreateParams = {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'languageCode': languageCode,
      'isPublic': isPublic,
    };
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
