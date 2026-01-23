import 'themes.dart';
import 'reader_typography.dart';
import 'font_packs.dart';

/// IDs for curated one-click reader bundles.
enum ReaderThemeBundleId { nordCalm, solarizedFocus, highContrastReadability }

class ReaderThemeBundleDef {
  final String labelKey; // l10n key for label
  final AppThemeFamily family;
  final ReaderTypographyPreset preset;
  final ReaderFontPack fontPack;
  const ReaderThemeBundleDef({
    required this.labelKey,
    required this.family,
    required this.preset,
    required this.fontPack,
  });
}

const Map<ReaderThemeBundleId, ReaderThemeBundleDef> readerThemeBundles = {
  ReaderThemeBundleId.nordCalm: ReaderThemeBundleDef(
    labelKey: 'bundleNordCalm',
    family: AppThemeFamily.arcticFrost,
    preset: ReaderTypographyPreset.comfortable,
    fontPack: ReaderFontPack.inter,
  ),
  ReaderThemeBundleId.solarizedFocus: ReaderThemeBundleDef(
    labelKey: 'bundleSolarizedFocus',
    family: AppThemeFamily.goldenHour,
    preset: ReaderTypographyPreset.compact,
    fontPack: ReaderFontPack.inter,
  ),
  ReaderThemeBundleId.highContrastReadability: ReaderThemeBundleDef(
    labelKey: 'bundleHighContrastReadability',
    family: AppThemeFamily.techInnovation,
    preset: ReaderTypographyPreset.comfortable,
    fontPack: ReaderFontPack.system,
  ),
};
