import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/theme/no_animation_transitions.dart';
import 'package:writer/theme/fade_through_page_transitions.dart';
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
      themeState = const ThemeState(
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

    // Build palettes
    final lightPalette = themeForLight(
      themeState.hasSeparateDark ? themeState.familyLight : themeState.family,
    );
    final darkPalette = themeForDark(
      themeState.hasSeparateDark ? themeState.familyDark : themeState.family,
    );

    // Apply font pack first, then typography preset (per-mode if enabled)
    final withFontLight = applyFontPackOrCustom(
      lightPalette,
      themeState.fontPack,
      themeState.customFontFamily,
    );
    final withFontDark = applyFontPackOrCustom(
      darkPalette,
      themeState.fontPack,
      themeState.customFontFamily,
    );
    final themeLight = applyReaderTypography(
      withFontLight,
      themeState.hasSeparateTypography
          ? themeState.presetLight
          : themeState.preset,
    );
    final themeDark = applyReaderTypography(
      withFontDark,
      themeState.hasSeparateTypography
          ? themeState.presetDark
          : themeState.preset,
    );

    final motion = ref.watch(motionSettingsProvider);

    ThemeData applyMotion(ThemeData base) {
      final withFont = base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'Noto Sans SC'),
      );

      if (motion.reduceMotion) {
        return withFont.copyWith(
          splashFactory: NoSplash.splashFactory,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.fuchsia: NoAnimationPageTransitionsBuilder(),
            },
          ),
        );
      }

      // Apply Material FadeThrough transitions when motion is allowed.
      return withFont.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.fuchsia: FadeThroughPageTransitionsBuilder(),
          },
        ),
      );
    }

    return AppLifecycleMonitor(
      child: MaterialApp.router(
        title: 'Writer',
        theme: applyMotion(themeLight),
        darkTheme: applyMotion(themeDark),
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
