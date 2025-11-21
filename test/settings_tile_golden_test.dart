import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'package:novel_reader/state/motion_settings.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Golden: Reduce Motion tile (en)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.04,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs); // en
    final themeController = ThemeController(prefs);
    final motionNotifier = MotionSettingsNotifier(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          motionSettingsProvider.overrideWith((_) => motionNotifier),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            platform: TargetPlatform.android,
            visualDensity: VisualDensity.standard,
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.zero,
            ),
          ),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(
                body: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SwitchListTile.adaptive(
                        value: false,
                        onChanged: (_) {},
                        title: Text(l10n.reduceMotion),
                        subtitle: Text(l10n.reduceMotionDescription),
                        secondary: const Icon(Icons.motion_photos_off),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final tileFinder = find.widgetWithText(SwitchListTile, 'Reduce motion');
    expect(tileFinder, findsOneWidget);
    await expectLater(
      tileFinder,
      matchesGoldenFile('goldens/settings_reduce_motion_en.png'),
    );
  });

  testWidgets('Golden: Reduce Motion tile (zh)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.02,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    appNotifier.setLanguage('zh');
    final themeController = ThemeController(prefs);
    final motionNotifier = MotionSettingsNotifier(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          motionSettingsProvider.overrideWith((_) => motionNotifier),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            platform: TargetPlatform.android,
            visualDensity: VisualDensity.standard,
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.zero,
            ),
          ),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(
                body: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SwitchListTile.adaptive(
                        value: false,
                        onChanged: (_) {},
                        title: Text(l10n.reduceMotion),
                        subtitle: Text(l10n.reduceMotionDescription),
                        secondary: const Icon(Icons.motion_photos_off),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final tileFinder = find.widgetWithText(SwitchListTile, '减少动效');
    expect(tileFinder, findsOneWidget);
    await expectLater(
      tileFinder,
      matchesGoldenFile('goldens/settings_reduce_motion_zh.png'),
    );
  });
}
