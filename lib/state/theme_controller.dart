import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/themes.dart';
import '../theme/reader_typography.dart';
import '../theme/font_packs.dart';
import '../theme/reader_background.dart';
import 'theme_prefs.dart';
import '../shared/strings.dart';
import '../shared/math.dart';

const String _prefThemeMode = prefThemeMode;
const String _prefLightTheme = prefLightTheme;
const String _prefDarkTheme = prefDarkTheme;
const String _prefSeparateDark = prefSeparateDark;
const String _prefTypographyPreset = prefTypographyPreset;
const String _prefSeparateTypography = prefSeparateTypography;
const String _prefTypographyPresetLight = prefTypographyPresetLight;
const String _prefTypographyPresetDark = prefTypographyPresetDark;
const String _prefFontPack = prefFontPack;
const String _prefCustomFontFamily = prefCustomFontFamily;
const String _prefFontScale = prefFontScale;
const String _prefReaderBgDepth = prefReaderBgDepth;

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
    final mode = decodeMode(prefs.getString(_prefThemeMode));
    // Default to Sepia when no prior preference exists
    final unified = prefs.containsKey(_prefLightTheme)
        ? decodeFamily(prefs.getString(_prefLightTheme))
        : AppThemeFamily.sepia;
    final preset = decodePreset(prefs.getString(_prefTypographyPreset));
    final separate = prefs.getBool(_prefSeparateDark) ?? false;
    final separateTypo = prefs.getBool(_prefSeparateTypography) ?? false;
    // Use nullable decode to allow fallback to unified preset when unset
    final presetLight =
        tryDecodePreset(prefs.getString(_prefTypographyPresetLight)) ?? preset;
    final presetDark =
        tryDecodePreset(prefs.getString(_prefTypographyPresetDark)) ?? preset;
    final fontPack = decodeFontPack(prefs.getString(_prefFontPack));
    final rawFamily = prefs.getString(_prefCustomFontFamily);
    final customFontFamily = trimOrDefault(rawFamily, 'Consolas');
    final fontScale = prefs.getDouble(_prefFontScale) ?? 1.0;
    final readerBgDepth = decodeBgDepth(prefs.getString(_prefReaderBgDepth));
    final famLight = unified;
    final famDark = separate
        ? decodeFamily(prefs.getString(_prefDarkTheme))
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
    _prefs.setString(_prefThemeMode, encodeMode(mode));
    state = state.copyWith(mode: mode);
  }

  void setFamily(AppThemeFamily family) {
    _prefs.setString(_prefLightTheme, encodeFamily(family));
    // Update unified selection and both palettes when not separate
    state = state.copyWith(
      family: family,
      familyLight: family,
      familyDark: state.hasSeparateDark ? state.familyDark : family,
    );
    if (!state.hasSeparateDark) {
      _prefs.setString(_prefDarkTheme, encodeFamily(family));
    }
  }

  void setCustomFontFamily(String? family) {
    final value = trimToNull(family);
    if (value == null) {
      _prefs.remove(_prefCustomFontFamily);
      state = state.copyWith(customFontFamily: null);
    } else {
      _prefs.setString(_prefCustomFontFamily, value);
      state = state.copyWith(customFontFamily: value);
    }
  }

  void setFontScale(double scale) {
    final clamped = clampDouble(scale, 0.8, 3.2);
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
    _prefs.setString(_prefLightTheme, encodeFamily(family));
    state = state.copyWith(familyLight: family, family: family);
  }

  void setFamilyDark(AppThemeFamily family) {
    _prefs.setString(_prefDarkTheme, encodeFamily(family));
    state = state.copyWith(familyDark: family);
  }

  void setPreset(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPreset, encodePreset(preset));
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
      _prefs.setString(_prefTypographyPresetLight, encodePreset(state.preset));
      _prefs.setString(_prefTypographyPresetDark, encodePreset(state.preset));
      state = state.copyWith(
        presetLight: state.preset,
        presetDark: state.preset,
      );
    }
  }

  void setPresetLight(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPresetLight, encodePreset(preset));
    state = state.copyWith(presetLight: preset);
  }

  void setPresetDark(ReaderTypographyPreset preset) {
    _prefs.setString(_prefTypographyPresetDark, encodePreset(preset));
    state = state.copyWith(presetDark: preset);
  }

  void setFontPack(ReaderFontPack pack) {
    _prefs.setString(_prefFontPack, encodeFontPack(pack));
    state = state.copyWith(fontPack: pack);
  }

  void setReaderBackgroundDepth(ReaderBackgroundDepth depth) {
    _prefs.setString(_prefReaderBgDepth, encodeBgDepth(depth));
    state = state.copyWith(readerBgDepth: depth);
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((
  ref,
) {
  // Will be overridden in main.dart with a real instance using SharedPreferences
  throw UnimplementedError();
});
