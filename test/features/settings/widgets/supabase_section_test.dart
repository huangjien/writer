import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/models/novel.dart';

void main() {
  testWidgets('SupabaseSection renders correctly when Supabase is disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: null)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    if (!supabaseEnabled) {
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SupabaseSection)),
      )!;
      expect(find.text(l10n.supabaseNotEnabled), findsOneWidget);
    }
  });

  testWidgets('SupabaseSection shows fetch controls when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: SupabaseSection(user: null)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (supabaseEnabled) {
      expect(find.text('Supabase Settings'), findsOneWidget);
      expect(find.text('Fetch from Supabase'), findsOneWidget);
      expect(
        find.text('Fetch latest novels and progress from Supabase.'),
        findsOneWidget,
      );
    }
  });

  testWidgets('Fetch disabled when no user', (tester) async {
    if (!supabaseEnabled) return;
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: null)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fetchTile = find.ancestor(
      of: find.text('Fetch from Supabase'),
      matching: find.byType(ListTile),
    );
    expect(fetchTile, findsOneWidget);
    await tester.tap(fetchTile);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Shows confirm dialog when user present', (tester) async {
    if (!supabaseEnabled) return;
    final mockUser = MockUser();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: mockUser)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Confirm Fetch'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Fetch'), findsOneWidget);
  });

  testWidgets('Fetch closes dialog and invalidates novelsProvider', (
    tester,
  ) async {
    if (!supabaseEnabled) return;
    final mockUser = MockUser();
    var recomputeCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async {
            recomputeCount += 1;
            return const <Novel>[];
          }),
          latestUserProgressProvider.overrideWith((ref) async* {
            yield null;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: SupabaseSection(user: mockUser)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(recomputeCount, 1);
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pump();
    await tester.tap(find.text('Fetch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(recomputeCount >= 2, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

class MockUser extends Mock implements User {}
