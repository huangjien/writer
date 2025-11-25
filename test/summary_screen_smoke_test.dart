import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('Summary screen shows for novel route', (tester) async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
    );
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    router.go('/novel/novel-001/summary');
    await tester.pumpAndSettle();
    expect(find.text('Summary'), findsOneWidget);
    expect(find.textContaining('Chapters'), findsWidgets);
  });
}
