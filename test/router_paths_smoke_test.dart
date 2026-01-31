import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/state/novel_providers_v2.dart';

void main() {
  testWidgets('Go to About via router', (tester) async {
    final container = ProviderContainer(
      overrides: [chaptersProviderV2.overrideWith((ref, id) async => const [])],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/about');
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
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text(AppLocalizationsEn().appTitle), findsOneWidget);
  });

  testWidgets('Go to Reader list shows chapters screen', (tester) async {
    final container = ProviderContainer(
      overrides: [chaptersProviderV2.overrideWith((ref, id) async => const [])],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/novel/novel-001');
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
    await tester.pumpAndSettle();
    expect(find.text('Chapters'), findsOneWidget);
  });
}
