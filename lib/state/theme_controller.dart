import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
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
    Object? customFontFamily = _sentinel,
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
    customFontFamily: customFontFamily == _sentinel
        ? this.customFontFamily
        : customFontFamily as String?,
    fontScale: fontScale ?? this.fontScale,
    readerBgDepth: readerBgDepth ?? this.readerBgDepth,
  );
}

const _sentinel = Object();

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
    final customFontFamily = trimToNull(rawFamily);
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

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs.setString(_prefThemeMode, encodeMode(mode));
  }

  Future<void> setFamily(AppThemeFamily family) async {
    final next = state.copyWith(
      family: family,
      familyLight: family,
      familyDark: state.hasSeparateDark ? state.familyDark : family,
    );
    state = next;
    await _prefs.setString(_prefLightTheme, encodeFamily(family));
    if (!next.hasSeparateDark) {
      await _prefs.setString(_prefDarkTheme, encodeFamily(family));
    }
  }

  Future<void> setCustomFontFamily(String? family) async {
    final value = trimToNull(family);
    if (value == null) {
      state = state.copyWith(customFontFamily: null);
      await _prefs.remove(_prefCustomFontFamily);
    } else {
      state = state.copyWith(customFontFamily: value);
      await _prefs.setString(_prefCustomFontFamily, value);
    }
  }

  Future<void> setFontScale(double scale) async {
    final clamped = clampDouble(scale, 0.8, 3.2);
    state = state.copyWith(fontScale: clamped);
    await _prefs.setDouble(_prefFontScale, clamped);
  }

  Future<void> setSeparateDark(bool separate) async {
    final next = state.copyWith(
      hasSeparateDark: separate,
      // When enabling separate, keep current dark; when disabling, align to unified
      familyDark: separate ? state.familyDark : state.family,
    );
    state = next;
    await _prefs.setBool(_prefSeparateDark, separate);
    await _prefs.setString(
      _prefDarkTheme,
      encodeFamily(separate ? next.familyDark : next.family),
    );
  }

  Future<void> setFamilyLight(AppThemeFamily family) async {
    final next = state.copyWith(
      familyLight: family,
      family: family,
      familyDark: state.hasSeparateDark ? state.familyDark : family,
    );
    state = next;
    await _prefs.setString(_prefLightTheme, encodeFamily(family));
    if (!next.hasSeparateDark) {
      await _prefs.setString(_prefDarkTheme, encodeFamily(family));
    }
  }

  Future<void> setFamilyDark(AppThemeFamily family) async {
    state = state.copyWith(familyDark: family);
    await _prefs.setString(_prefDarkTheme, encodeFamily(family));
  }

  Future<void> setPreset(ReaderTypographyPreset preset) async {
    state = state.copyWith(
      preset: preset,
      presetLight: preset,
      presetDark: preset,
    );
    await _prefs.setString(_prefTypographyPreset, encodePreset(preset));
  }

  Future<void> setSeparateTypography(bool separate) async {
    if (separate) {
      state = state.copyWith(hasSeparateTypography: true);
      await _prefs.setBool(_prefSeparateTypography, true);
      return;
    }

    final next = state.copyWith(
      hasSeparateTypography: false,
      presetLight: state.preset,
      presetDark: state.preset,
    );
    state = next;
    await _prefs.setBool(_prefSeparateTypography, false);
    await _prefs.setString(
      _prefTypographyPresetLight,
      encodePreset(next.preset),
    );
    await _prefs.setString(
      _prefTypographyPresetDark,
      encodePreset(next.preset),
    );
  }

  Future<void> setPresetLight(ReaderTypographyPreset preset) async {
    state = state.copyWith(presetLight: preset);
    await _prefs.setString(_prefTypographyPresetLight, encodePreset(preset));
  }

  Future<void> setPresetDark(ReaderTypographyPreset preset) async {
    state = state.copyWith(presetDark: preset);
    await _prefs.setString(_prefTypographyPresetDark, encodePreset(preset));
  }

  Future<void> setFontPack(ReaderFontPack pack) async {
    state = state.copyWith(fontPack: pack);
    await _prefs.setString(_prefFontPack, encodeFontPack(pack));
  }

  Future<void> setReaderBackgroundDepth(ReaderBackgroundDepth depth) async {
    state = state.copyWith(readerBgDepth: depth);
    await _prefs.setString(_prefReaderBgDepth, encodeBgDepth(depth));
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((
  ref,
) {
  // Will be overridden in main.dart with a real instance using SharedPreferences
  throw UnimplementedError(
    'themeControllerProvider must be overridden in ProviderScope/main.dart',
  );
});
