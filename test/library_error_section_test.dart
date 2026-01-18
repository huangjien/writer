import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/widgets/library_error_section.dart';
import 'package:writer/state/novel_providers.dart';

void main() {
  testWidgets('LibraryErrorSection shows error UI and reload button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LibraryErrorSection(error: 'Oops')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });

  testWidgets('LibraryErrorSection uses provided message and tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibraryErrorSection(
              error: FormatException('bad'),
              message: 'Custom',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'FormatException: bad');
  });

  testWidgets('Reload invalidates novel providers when onRetry is null', (
    tester,
  ) async {
    var novelsBuilds = 0;
    var memberBuilds = 0;
    var libraryBuilds = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async {
            novelsBuilds++;
            return const [];
          }),
          memberNovelsProvider.overrideWith((ref) async {
            memberBuilds++;
            return const [];
          }),
          libraryNovelsProvider.overrideWith((ref) async {
            libraryBuilds++;
            return const [];
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    ref.watch(novelsProvider);
                    ref.watch(memberNovelsProvider);
                    ref.watch(libraryNovelsProvider);
                    return SizedBox.shrink();
                  },
                ),
                const LibraryErrorSection(error: 'Oops'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(novelsBuilds, 1);
    expect(memberBuilds, 1);
    expect(libraryBuilds, 1);

    await tester.tap(find.text('Reload'));
    await tester.pumpAndSettle();

    expect(novelsBuilds, greaterThanOrEqualTo(2));
    expect(memberBuilds, greaterThanOrEqualTo(2));
    expect(libraryBuilds, greaterThanOrEqualTo(2));
  });

  testWidgets('Reload uses onRetry callback when provided', (tester) async {
    var retryCalls = 0;
    var novelsBuilds = 0;
    var memberBuilds = 0;
    var libraryBuilds = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelsProvider.overrideWith((ref) async {
            novelsBuilds++;
            return const [];
          }),
          memberNovelsProvider.overrideWith((ref) async {
            memberBuilds++;
            return const [];
          }),
          libraryNovelsProvider.overrideWith((ref) async {
            libraryBuilds++;
            return const [];
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    ref.watch(novelsProvider);
                    ref.watch(memberNovelsProvider);
                    ref.watch(libraryNovelsProvider);
                    return SizedBox.shrink();
                  },
                ),
                LibraryErrorSection(error: 'Oops', onRetry: () => retryCalls++),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(novelsBuilds, 1);
    expect(memberBuilds, 1);
    expect(libraryBuilds, 1);

    await tester.tap(find.text('Reload'));
    await tester.pumpAndSettle();

    expect(retryCalls, 1);
    expect(novelsBuilds, 1);
    expect(memberBuilds, 1);
    expect(libraryBuilds, 1);
  });
}
