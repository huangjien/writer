import 'package:flutter/material.dart';
import 'package:writer/theme/reader_background.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/ui_styles.dart';

const String prefThemeMode = 'theme_mode';
const String prefLightTheme = 'light_theme';
const String prefDarkTheme = 'dark_theme';
const String prefSeparateDark = 'use_separate_dark_palette';
const String prefTypographyPreset = 'reader_typography_preset';
const String prefSeparateTypography = 'use_separate_typography';
const String prefTypographyPresetLight = 'reader_typography_preset_light';
const String prefTypographyPresetDark = 'reader_typography_preset_dark';
const String prefFontPack = 'reader_font_pack';
const String prefCustomFontFamily = 'reader_custom_font_family';
const String prefFontScale = 'reader_font_scale';
const String prefReaderBgDepth = 'reader_background_depth';
const String prefUiStyleFamily = 'ui_style_family';

UiStyleFamily decodeUiStyleFamily(String? raw) {
  switch (raw) {
    case 'minimalism':
      return UiStyleFamily.minimalism;
    case 'glassmorphism':
      return UiStyleFamily.glassmorphism;
    case 'liquidGlass':
      return UiStyleFamily.liquidGlass;
    case 'neumorphism':
      return UiStyleFamily.neumorphism;
    case 'flatDesign':
      return UiStyleFamily.flatDesign;
    case 'claymorphism':
      return UiStyleFamily.neumorphism;
    case 'brutalism':
      return UiStyleFamily.flatDesign;
    case 'skeuomorphism':
      return UiStyleFamily.neumorphism;
    case 'bentoGrid':
      return UiStyleFamily.minimalism;
    case 'responsive':
      return UiStyleFamily.minimalism;
    default:
      return UiStyleFamily.minimalism;
  }
}

String encodeUiStyleFamily(UiStyleFamily family) {
  switch (family) {
    case UiStyleFamily.minimalism:
      return 'minimalism';
    case UiStyleFamily.glassmorphism:
      return 'glassmorphism';
    case UiStyleFamily.liquidGlass:
      return 'liquidGlass';
    case UiStyleFamily.neumorphism:
      return 'neumorphism';
    case UiStyleFamily.flatDesign:
      return 'flatDesign';
  }
}

ThemeMode decodeMode(String? raw) {
  switch (raw) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String encodeMode(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

AppThemeFamily decodeFamily(String? raw) {
  switch (raw) {
    case 'oceanDepths':
      return AppThemeFamily.oceanDepths;
    case 'sunsetBoulevard':
      return AppThemeFamily.sunsetBoulevard;
    case 'forestCanopy':
      return AppThemeFamily.forestCanopy;
    case 'modernMinimalist':
      return AppThemeFamily.modernMinimalist;
    case 'goldenHour':
      return AppThemeFamily.goldenHour;
    case 'arcticFrost':
      return AppThemeFamily.arcticFrost;
    case 'desertRose':
      return AppThemeFamily.desertRose;
    case 'techInnovation':
      return AppThemeFamily.techInnovation;
    case 'botanicalGarden':
      return AppThemeFamily.botanicalGarden;
    case 'midnightGalaxy':
      return AppThemeFamily.midnightGalaxy;
    case 'light':
      return AppThemeFamily.modernMinimalist;
    case 'sepia':
      return AppThemeFamily.goldenHour;
    case 'emerald':
    case 'emeraldGreen':
      return AppThemeFamily.forestCanopy;
    case 'contrast':
    case 'highContrast':
      return AppThemeFamily.techInnovation;
    case 'solarizedTan':
      return AppThemeFamily.sunsetBoulevard;
    case 'nord':
    case 'nordFrost':
      return AppThemeFamily.arcticFrost;
    default:
      return AppThemeFamily.modernMinimalist;
  }
}

String encodeFamily(AppThemeFamily family) {
  switch (family) {
    case AppThemeFamily.oceanDepths:
      return 'oceanDepths';
    case AppThemeFamily.sunsetBoulevard:
      return 'sunsetBoulevard';
    case AppThemeFamily.forestCanopy:
      return 'forestCanopy';
    case AppThemeFamily.modernMinimalist:
      return 'modernMinimalist';
    case AppThemeFamily.goldenHour:
      return 'goldenHour';
    case AppThemeFamily.arcticFrost:
      return 'arcticFrost';
    case AppThemeFamily.desertRose:
      return 'desertRose';
    case AppThemeFamily.techInnovation:
      return 'techInnovation';
    case AppThemeFamily.botanicalGarden:
      return 'botanicalGarden';
    case AppThemeFamily.midnightGalaxy:
      return 'midnightGalaxy';
  }
}

ReaderTypographyPreset decodePreset(String? raw) {
  switch (raw) {
    case 'comfortable':
      return ReaderTypographyPreset.comfortable;
    case 'compact':
      return ReaderTypographyPreset.compact;
    case 'serifLike':
      return ReaderTypographyPreset.serifLike;
    case 'system':
    default:
      return ReaderTypographyPreset.system;
  }
}

ReaderTypographyPreset? tryDecodePreset(String? raw) {
  if (raw == null) return null;
  return decodePreset(raw);
}

String encodePreset(ReaderTypographyPreset preset) {
  switch (preset) {
    case ReaderTypographyPreset.system:
      return 'system';
    case ReaderTypographyPreset.comfortable:
      return 'comfortable';
    case ReaderTypographyPreset.compact:
      return 'compact';
    case ReaderTypographyPreset.serifLike:
      return 'serifLike';
  }
}

ReaderFontPack decodeFontPack(String? raw) {
  switch (raw) {
    case 'inter':
      return ReaderFontPack.inter;
    case 'merriweather':
      return ReaderFontPack.merriweather;
    case 'system':
    default:
      return ReaderFontPack.system;
  }
}

String encodeFontPack(ReaderFontPack pack) {
  switch (pack) {
    case ReaderFontPack.system:
      return 'system';
    case ReaderFontPack.inter:
      return 'inter';
    case ReaderFontPack.merriweather:
      return 'merriweather';
  }
}

ReaderBackgroundDepth decodeBgDepth(String? raw) {
  switch (raw) {
    case 'low':
      return ReaderBackgroundDepth.low;
    case 'high':
      return ReaderBackgroundDepth.high;
    case 'medium':
    default:
      return ReaderBackgroundDepth.medium;
  }
}

String encodeBgDepth(ReaderBackgroundDepth depth) {
  switch (depth) {
    case ReaderBackgroundDepth.low:
      return 'low';
    case ReaderBackgroundDepth.medium:
      return 'medium';
    case ReaderBackgroundDepth.high:
      return 'high';
  }
}
