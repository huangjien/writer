import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  testWidgets('Go to About via router', (tester) async {
    final container = ProviderContainer();
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
    router.go('/about');
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text(AppLocalizationsEn().appTitle), findsOneWidget);
  });

  testWidgets('Go to Reader list uses mock data when Supabase disabled', (
    tester,
  ) async {
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
    router.go('/novel/novel-001');
    await tester.pumpAndSettle();
    expect(find.text('Chapters'), findsOneWidget);
  });
}
