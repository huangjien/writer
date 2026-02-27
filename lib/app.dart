import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/ui_style_controller.dart';
import 'package:writer/theme/app_theme_builder.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';
import 'package:writer/theme/ui_style_adapter.dart';
import 'package:writer/theme/ui_styles.dart';
import 'routing/app_router.dart';
import 'l10n/app_localizations.dart';
import 'services/app_lifecycle_monitor.dart';
import 'shared/widgets/error_boundary.dart';
import 'features/ai_chat/widgets/global_ai_overlay.dart';

// Sidebar UX Strategy:
// - Primary navigation: LEFT side (drawer)
// - Secondary tools (AI, formatting): RIGHT side (aligned)
// - Mobile: Bottom navigation bar
// - RTL support: Automatic position flip
// See: /docs/sidebar_ux_guidelines.md

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
        family: AppThemeFamily.modernMinimalist,
        hasSeparateDark: false,
        familyLight: AppThemeFamily.modernMinimalist,
        familyDark: AppThemeFamily.modernMinimalist,
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

    UiStyleState uiStyleState;
    try {
      uiStyleState = ref.watch(uiStyleControllerProvider);
    } catch (_) {
      uiStyleState = const UiStyleState(family: UiStyleFamily.glassmorphism);
    }

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

    // Apply typography presets to themes
    final lightThemeWithTypography = AppThemeBuilder.applyReaderTypography(
      lightTheme,
      preset: themeState.hasSeparateTypography
          ? themeState.presetLight
          : themeState.preset,
      separatePreset: themeState.hasSeparateTypography
          ? themeState.presetLight
          : null,
      hasSeparate: themeState.hasSeparateTypography,
    );

    final darkThemeWithTypography = AppThemeBuilder.applyReaderTypography(
      darkTheme,
      preset: themeState.hasSeparateTypography
          ? themeState.presetDark
          : themeState.preset,
      separatePreset: themeState.hasSeparateTypography
          ? themeState.presetDark
          : null,
      hasSeparate: themeState.hasSeparateTypography,
    );

    const styleAdapter = UiStyleAdapter();
    final stylePatch = styleAdapter.resolveStylePatch(uiStyleState.family);

    final lightThemeWithStyle = stylePatch.applyToTheme(
      lightThemeWithTypography,
      false,
    );
    final darkThemeWithStyle = stylePatch.applyToTheme(
      darkThemeWithTypography,
      true,
    );

    final themeLight = AppThemeBuilder.applyMotion(
      base: lightThemeWithStyle,
      reduceMotion: motion.reduceMotion,
    );
    final themeDark = AppThemeBuilder.applyMotion(
      base: darkThemeWithStyle,
      reduceMotion: motion.reduceMotion,
    );

    return AppLifecycleMonitor(
      child: ErrorBoundary(
        child: MaterialApp.router(
          title: 'Writer',
          theme: themeLight,
          darkTheme: themeDark,
          themeMode: themeState.mode,
          routerConfig: router,
          locale: appSettings,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final childWithScale = MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(themeState.fontScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
            return GlobalAiAssistantOverlay(child: childWithScale);
          },
        ),
      ),
    );
  }
}
