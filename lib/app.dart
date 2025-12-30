import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/app_theme_builder.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';
import 'routing/app_router.dart';
import 'l10n/app_localizations.dart';
import 'services/app_lifecycle_monitor.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    Locale appSettings;
    try {
      appSettings = ref.watch(appSettingsProvider);
    } catch (_) {
      // Fallback for tests or environments that don't override appSettingsProvider
      appSettings = const Locale('en');
    }

    ThemeState themeState;
    try {
      themeState = ref.watch(themeControllerProvider);
    } catch (_) {
      // Fallback for tests that don't override themeControllerProvider
      themeState = ThemeState(
        mode: ThemeMode.system,
        family: AppThemeFamily.defaultFamily,
        hasSeparateDark: false,
        familyLight: AppThemeFamily.defaultFamily,
        familyDark: AppThemeFamily.defaultFamily,
        preset: ReaderTypographyPreset.system,
        hasSeparateTypography: false,
        presetLight: ReaderTypographyPreset.system,
        presetDark: ReaderTypographyPreset.system,
        fontPack: ReaderFontPack.system,
        customFontFamily: null,
        fontScale: 1.0,
        readerBgDepth: ReaderBackgroundDepth.medium,
      );
    }

    final motion = ref.watch(motionSettingsProvider);

    final lightTheme = AppThemeBuilder.buildLight(
      family: themeState.hasSeparateDark
          ? themeState.familyLight
          : themeState.family,
      fontPack: themeState.fontPack,
      customFontFamily: themeState.customFontFamily,
      preset: themeState.hasSeparateTypography
          ? themeState.presetLight
          : themeState.preset,
    );

    final darkTheme = AppThemeBuilder.buildDark(
      family: themeState.hasSeparateDark
          ? themeState.familyDark
          : themeState.family,
      fontPack: themeState.fontPack,
      customFontFamily: themeState.customFontFamily,
      preset: themeState.hasSeparateTypography
          ? themeState.presetDark
          : themeState.preset,
    );

    final themeLight = AppThemeBuilder.applyMotion(
      base: lightTheme,
      reduceMotion: motion.reduceMotion,
    );
    final themeDark = AppThemeBuilder.applyMotion(
      base: darkTheme,
      reduceMotion: motion.reduceMotion,
    );

    return AppLifecycleMonitor(
      child: MaterialApp.router(
        title: 'Writer',
        theme: themeLight,
        darkTheme: themeDark,
        themeMode: themeState.mode,
        routerConfig: router,
        locale: Locale(appSettings.languageCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(themeState.fontScale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
