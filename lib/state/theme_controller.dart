import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/themes.dart';
import '../theme/reader_typography.dart';
import '../theme/font_packs.dart';
import '../theme/reader_background.dart';

const String _prefThemeMode = 'theme_mode';
const String _prefLightTheme = 'light_theme';
const String _prefDarkTheme = 'dark_theme';
const String _prefSeparateDark = 'use_separate_dark_palette';
const String _prefTypographyPreset = 'reader_typography_preset';
const String _prefSeparateTypography = 'use_separate_typography';
const String _prefTypographyPresetLight = 'reader_typography_preset_light';
const String _prefTypographyPresetDark = 'reader_typography_preset_dark';
const String _prefFontPack = 'reader_font_pack';
const String _prefCustomFontFamily = 'reader_custom_font_family';
const String _prefFontScale = 'reader_font_scale';
const String _prefReaderBgDepth = 'reader_background_depth';

class ThemeState {
  final ThemeMode mode;
  final AppThemeFamily family; // unified selection
  final bool hasSeparateDark;
  final AppThemeFamily familyLight;
  final AppThemeFamily familyDark;
  final ReaderTypographyPreset preset;
  final bool hasSeparateTypography;
  final ReaderTypographyPreset presetLight;
  final ReaderTypographyPreset presetDark;
  final ReaderFontPack fontPack;
  final String? customFontFamily;
  final double fontScale;
  final ReaderBackgroundDepth readerBgDepth;

  const ThemeState({
    required this.mode,
    required this.family,
    required this.hasSeparateDark,
    required this.familyLight,
    required this.familyDark,
    required this.preset,
    required this.hasSeparateTypography,
    required this.presetLight,
    required this.presetDark,
    required this.fontPack,
    required this.customFontFamily,
    required this.fontScale,
    required this.readerBgDepth,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    AppThemeFamily? family,
    bool? hasSeparateDark,
    AppThemeFamily? familyLight,
    AppThemeFamily? familyDark,
    ReaderTypographyPreset? preset,
    bool? hasSeparateTypography,
    ReaderTypographyPreset? presetLight,
    ReaderTypographyPreset? presetDark,
    ReaderFontPack? fontPack,
    String? customFontFamily,
    double? fontScale,
    ReaderBackgroundDepth? readerBgDepth,
  }) => ThemeState(
    mode: mode ?? this.mode,
    family: family ?? this.family,
    hasSeparateDark: hasSeparateDark ?? this.hasSeparateDark,
    familyLight: familyLight ?? this.familyLight,
    familyDark: familyDark ?? this.familyDark,
    preset: preset ?? this.preset,
    hasSeparateTypography: hasSeparateTypography ?? this.hasSeparateTypography,
    presetLight: presetLight ?? this.presetLight,
    presetDark: presetDark ?? this.presetDark,
    fontPack: fontPack ?? this.fontPack,
    customFontFamily: customFontFamily ?? this.customFontFamily,
    fontScale: fontScale ?? this.fontScale,
    readerBgDepth: readerBgDepth ?? this.readerBgDepth,
  );
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController(this._prefs) : super(_initialState(_prefs));

  static ThemeState _initialState(SharedPreferences prefs) {
    final mode = _decodeMode(prefs.getString(_prefThemeMode));
    // Default to Sepia when no prior preference exists
    final unified = prefs.containsKey(_prefLightTheme)
        ? _decodeFamily(prefs.getString(_prefLightTheme))
        : AppThemeFamily.sepia;
    final preset = _decodePreset(prefs.getString(_prefTypographyPreset));
    final separate = prefs.getBool(_prefSeparateDark) ?? false;
    final separateTypo = prefs.getBool(_prefSeparateTypography) ?? false;
    // Use nullable decode to allow fallback to unified preset when unset
    final presetLight =
        _tryDecodePreset(prefs.getString(_prefTypographyPresetLight)) ?? preset;
    final presetDark =
        _tryDecodePreset(prefs.getString(_prefTypographyPresetDark)) ?? preset;
    final fontPack = _decodeFontPack(prefs.getString(_prefFontPack));
    // Default primary font family to Consolas when unset
    final rawFamily = prefs.getString(_prefCustomFontFamily);
    final customFontFamily = () {
      final v = rawFamily?.trim();
      if (v == null || v.isEmpty) return 'Consolas';
      return v;
    }();
    final fontScale = prefs.getDouble(_prefFontScale) ?? 1.0;
    final readerBgDepth = _decodeBgDepth(prefs.getString(_prefReaderBgDepth));
    final famLight = unified;
    final famDark = separate
        ? _decodeFamily(prefs.getString(_prefDarkTheme))
        : unified;
    return ThemeState(
      mode: mode,
      family: unified,
      hasSeparateDark: separate,
      familyLight: famLight,
      familyDark: famDark,
      preset: preset,
      hasSeparateTypography: separateTypo,
      presetLight: presetLight,
      presetDark: presetDark,
      fontPack: fontPack,
      customFontFamily: customFontFamily,
      fontScale: fontScale,
      readerBgDepth: readerBgDepth,
    );
  }

  final SharedPreferences _prefs;

  void setMode(ThemeMode mode) {
    _prefs.setString(_prefThemeMode, _encodeMode(mode));
    state = state.copyWith(mode: mode);
  }

  void setFamily(AppThemeFamily family) {
    _prefs.setString(_prefLightTheme, _encodeFamily(family));
    // Update unified selection and both palettes when not separate
    state = state.copyWith(
      family: family,
      familyLight: family,
      familyDark: state.hasSeparateDark ? state.familyDark : family,
    );
    if (!state.hasSeparateDark) {
      _prefs.setString(_prefDarkTheme, _encodeFamily(family));
    }
  }

  void setCustomFontFamily(String? family) {
    final value = family?.trim();
    if (value == null || value.isEmpty) {
      _prefs.remove(_prefCustomFontFamily);
      state = state.copyWith(customFontFamily: null);
    } else {
      _prefs.setString(_prefCustomFontFamily, value);
      state = state.copyWith(customFontFamily: value);
    }
  }

  void setFontScale(double scale) {
    // Clamp to reasonable range
    final clamped = scale.clamp(0.8, 3.2);
    _prefs.setDouble(_prefFontScale, clamped);
    state = state.copyWith(fontScale: clamped);
  }

  void setSeparateDark(bool separate) {
    _prefs.setBool(_prefSeparateDark, separate);
    state = state.copyWith(
      hasSeparateDark: separate,
      // When enabling separate, keep current dark; when disabling, align to unified
      familyDark: separate ? state.familyDark : state.family,
    );
  }

  void setFamilyLight(AppThemeFamily family) {
    _prefs.setString(_prefLightTheme, _encodeFamily(family));
    state = state.copyWith(familyLight: family, family: family);
  }

  void setFamilyDark(AppThemeFamily family) {
    _prefs.setString(_prefDarkTheme, _encodeFamily(family));
    state = state.copyWith(familyDark: family);
  }

  void setPreset(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPreset, _encodePreset(preset));
    state = state.copyWith(
      preset: preset,
      presetLight: preset,
      presetDark: preset,
    );
  }

  void setSeparateTypography(bool separate) {
    _prefs.setBool(_prefSeparateTypography, separate);
    state = state.copyWith(hasSeparateTypography: separate);
    // When disabling separate typography, align light/dark to unified preset
    if (!separate) {
      _prefs.setString(_prefTypographyPresetLight, _encodePreset(state.preset));
      _prefs.setString(_prefTypographyPresetDark, _encodePreset(state.preset));
      state = state.copyWith(
        presetLight: state.preset,
        presetDark: state.preset,
      );
    }
  }

  void setPresetLight(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPresetLight, _encodePreset(preset));
    state = state.copyWith(presetLight: preset);
  }

  void setPresetDark(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPresetDark, _encodePreset(preset));
    state = state.copyWith(presetDark: preset);
  }

  void setFontPack(ReaderFontPack pack) {
    _prefs.setString(_prefFontPack, _encodeFontPack(pack));
    state = state.copyWith(fontPack: pack);
  }

  void setReaderBackgroundDepth(ReaderBackgroundDepth depth) {
    _prefs.setString(_prefReaderBgDepth, _encodeBgDepth(depth));
    state = state.copyWith(readerBgDepth: depth);
  }

  static ThemeMode _decodeMode(String? raw) {
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

  static String _encodeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static AppThemeFamily _decodeFamily(String? raw) {
    switch (raw) {
      case 'sepia':
        return AppThemeFamily.sepia;
      case 'highContrast':
        return AppThemeFamily.highContrast;
      case 'solarized':
        return AppThemeFamily.solarized;
      case 'solarizedTan':
        return AppThemeFamily.solarizedTan;
      case 'nord':
        return AppThemeFamily.nord;
      case 'nordFrost':
        return AppThemeFamily.nordFrost;
      case 'nordSnowstorm':
        return AppThemeFamily.nordSnowstorm;
      case 'light':
      default:
        return AppThemeFamily.defaultFamily;
    }
  }

  static String _encodeFamily(AppThemeFamily family) {
    switch (family) {
      case AppThemeFamily.defaultFamily:
        return 'light';
      case AppThemeFamily.sepia:
        return 'sepia';
      case AppThemeFamily.highContrast:
        return 'highContrast';
      case AppThemeFamily.solarized:
        return 'solarized';
      case AppThemeFamily.solarizedTan:
        return 'solarizedTan';
      case AppThemeFamily.nord:
        return 'nord';
      case AppThemeFamily.nordFrost:
        return 'nordFrost';
      case AppThemeFamily.nordSnowstorm:
        return 'nordSnowstorm';
    }
  }

  static ReaderTypographyPreset _decodePreset(String? raw) {
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

  // Returns null if raw is null, allowing callers to apply fallback logic
  static ReaderTypographyPreset? _tryDecodePreset(String? raw) {
    if (raw == null) return null;
    return _decodePreset(raw);
  }

  static String _encodePreset(ReaderTypographyPreset preset) {
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

  static ReaderFontPack _decodeFontPack(String? raw) {
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

  static String _encodeFontPack(ReaderFontPack pack) {
    switch (pack) {
      case ReaderFontPack.system:
        return 'system';
      case ReaderFontPack.inter:
        return 'inter';
      case ReaderFontPack.merriweather:
        return 'merriweather';
    }
  }

  static ReaderBackgroundDepth _decodeBgDepth(String? raw) {
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

  static String _encodeBgDepth(ReaderBackgroundDepth depth) {
    switch (depth) {
      case ReaderBackgroundDepth.low:
        return 'low';
      case ReaderBackgroundDepth.medium:
        return 'medium';
      case ReaderBackgroundDepth.high:
        return 'high';
    }
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((
  ref,
) {
  // Will be overridden in main.dart with a real instance using SharedPreferences
  throw UnimplementedError();
});
