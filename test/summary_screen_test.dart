import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/summary_screen.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// removed unnecessary supabase import; supabase_flutter exports AuthClientOptions
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/state/providers.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  final Map<String, String> savedSummaries = {};
  @override
  Future<void> saveSummaryText(String novelId, String text) async {
    savedSummaries[novelId] = text;
  }
}

class StubNovelRepository extends NovelRepository {
  StubNovelRepository(super.client);
  @override
  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {}
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SummaryScreen loads description and saves summary', (
    tester,
  ) async {
    final repo = CapturingLocalRepo();
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Existing description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    final chapters = [
      Chapter(
        id: 'c1',
        novelId: 'n-1',
        idx: 1,
        title: 'One',
        content: List.filled(10, 'word').join(' '),
      ),
      Chapter(
        id: 'c2',
        novelId: 'n-1',
        idx: 2,
        title: 'Two',
        content: List.filled(20, 'word').join(' '),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWith((_) => repo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          mockChaptersProvider.overrideWith((ref, id) async => chapters),
          novelProvider.overrideWith((ref, id) async => novel),
          chaptersProvider.overrideWith((ref, id) async => chapters),
          novelRepositoryProvider.overrideWith(
            (ref) => StubNovelRepository(
              SupabaseClient(
                'http://localhost',
                'anon',
                authOptions: const AuthClientOptions(autoRefreshToken: false),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: SummaryScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    // Header shows title and author.
    expect(find.text('Test Novel'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);

    // Initial text field filled with existing description when no cached summary.
    final summaryField = find.byType(TextFormField);
    expect(summaryField, findsOneWidget);
    expect(
      (tester.widget(summaryField) as TextFormField).controller?.text,
      'Existing description',
    );

    // Chapters summary shows counts and average words.
    expect(find.text('Chapters: 2'), findsOneWidget);

    // Save a new summary.
    await tester.enterText(summaryField, 'New summary text');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repo.savedSummaries['n-1'], 'New summary text');
    if (!supabaseEnabled) {
      expect(find.text('Saved'), findsOneWidget);
    }
  });

  testWidgets('SummaryScreen save disabled until changes', (tester) async {
    final repo = CapturingLocalRepo();
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Existing description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWith((_) => repo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: SummaryScreen(novelId: 'n-1')),
      ),
    );
    await tester.pumpAndSettle();
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);
    final btn = tester.widget<ElevatedButton>(saveButton);
    expect(btn.onPressed, isNull);
    final summaryField = find.byType(TextFormField);
    await tester.enterText(summaryField, 'Changed');
    await tester.pump();
    final btn2 = tester.widget<ElevatedButton>(saveButton);
    expect(btn2.onPressed, isNotNull);
  });

  testWidgets('SummaryScreen toggles AI Coach and shows widget (small layout)', (
    tester,
  ) async {
    final repo = CapturingLocalRepo();
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Existing description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    // Mock Snowflake service to return a refined summary immediately
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path.endsWith('snowflake/refine')) {
        return http.Response(
          '{"novel_id":"n-1","summary_content":"AI update","status":"refined"}',
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWith((_) => repo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
          snowflakeServiceProvider.overrideWithValue(
            SnowflakeService('http://example.com/', client: client),
          ),
          supabaseEnabledProvider.overrideWith((_) => false),
        ],
        child: const MaterialApp(home: SummaryScreen(novelId: 'n-1')),
      ),
    );
    await tester.pumpAndSettle();

    // Toggle coach via suffix icon button
    await tester.tap(find.byTooltip('Toggle AI Coach'));
    await tester.pumpAndSettle();

    expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    // Small layout uses Column with a Divider between sections
    expect(find.byType(Divider), findsOneWidget);

    // Coach applies update and makes form dirty; Save becomes enabled
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    final btn = tester.widget<ElevatedButton>(saveButton);
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('SummaryScreen shows split view with coach on wide screens', (
    tester,
  ) async {
    final repo = CapturingLocalRepo();
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Existing description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path.endsWith('snowflake/refine')) {
        return http.Response(
          '{"novel_id":"n-1","summary_content":"AI update","status":"refined"}',
          200,
        );
      }
      return http.Response('not found', 404);
    });

    // Set a wide test surface
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWith((_) => repo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
          snowflakeServiceProvider.overrideWithValue(
            SnowflakeService('http://example.com/', client: client),
          ),
          supabaseEnabledProvider.overrideWith((_) => false),
        ],
        child: const MaterialApp(home: SummaryScreen(novelId: 'n-1')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Toggle AI Coach'));
    await tester.pumpAndSettle();

    expect(find.byType(SnowflakeCoachWidget), findsOneWidget);
    // Wide layout includes a VerticalDivider between panels
    expect(find.byType(VerticalDivider), findsOneWidget);
  });
}
