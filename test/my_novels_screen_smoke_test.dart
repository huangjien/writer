import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/library/my_novels_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';

void main() {
  testWidgets('MyNovelsScreen shows sign-in prompt when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in to sync progress across devices.'), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('MyNovelsScreen shows empty state when signed in', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProvider.overrideWith((ref) async => const []),
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
    expect(find.text('No novels found.'), findsOneWidget);
  });

  testWidgets('MyNovelsScreen shows member novels list when signed in', (
    tester,
  ) async {
    const novels = [
      Novel(
        id: 'n1',
        title: 'Novel 1',
        author: 'Author',
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      Novel(
        id: 'n2',
        title: 'Novel 2',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          memberNovelsProvider.overrideWith((ref) async => novels),
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
    expect(find.text('Novel 1'), findsOneWidget);
    expect(find.text('Novel 2'), findsOneWidget);
  });
}
