import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/features/library/my_novels_screen.dart';
import 'package:novel_reader/state/providers.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  testWidgets('MyNovelsScreen shows member novels when Supabase enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => true),
          memberNovelsProvider.overrideWith(
            (ref) async => const [
              Novel(
                id: 'stub-001',
                title: 'Stub Novel',
                author: 'Tester',
                description: 'Stub',
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('My Novels'), findsOneWidget);
    expect(find.text('Stub Novel'), findsOneWidget);
  });
}
