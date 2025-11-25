import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/create_novel_screen.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/novel_repository.dart';

class CapturingNovelRepository extends NovelRepository {
  String? lastTitle;
  String? lastAuthor;
  String? lastDescription;
  String? lastCoverUrl;
  String? lastLanguageCode;
  bool? lastIsPublic;

  CapturingNovelRepository()
    : super(SupabaseClient('http://localhost', 'anon'));

  @override
  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    lastTitle = title;
    lastAuthor = author;
    lastDescription = description;
    lastCoverUrl = coverUrl;
    lastLanguageCode = languageCode;
    lastIsPublic = isPublic;
    return Novel(
      id: 'created-1',
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      languageCode: languageCode,
      isPublic: isPublic,
    );
  }
}

Session _fakeSession() {
  return Session.fromJson(<String, dynamic>{
    'access_token': 'test',
    'token_type': 'bearer',
    'expires_in': 3600,
    'refresh_token': 'refresh',
    'user': <String, dynamic>{
      'id': 'user-id',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'user@example.com',
      'phone': '',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
  })!;
}

void main() {
  testWidgets('Enabled path renders form and validates cover URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWithValue(true),
          supabaseSessionProvider.overrideWithValue(_fakeSession()),
          authStateProvider.overrideWith((_) => const Stream.empty()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreateNovelScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Novel'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Cover URL'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), 'http://bad link');
    await tester.pump();
    expect(
      find.text('Enter a valid http(s) URL without spaces.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'https://example.com/img.png',
    );
    await tester.pump();
    expect(
      find.text('Enter a valid http(s) URL without spaces.'),
      findsNothing,
    );
  });

  // Submission path covered in integration; keep this file focused on gating and validation.
}
