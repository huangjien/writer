import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/reader_typography.dart';
import '../../../theme/font_packs.dart';
import '../../../theme/reader_background.dart';
import '../../../state/theme_controller.dart';
import '../../../shared/widgets/neumorphic_dropdown.dart';
import '../../../shared/widgets/neumorphic_slider.dart';
import '../../../shared/widgets/neumorphic_switch.dart';

class TypographySettingsSection extends ConsumerWidget {
  const TypographySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeControllerProvider);
    String displayFontFamily(String family) {
      if (family == embeddedChineseSansFamily) return 'Noto Sans SC';
      return family;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.format_size),
          title: Row(
            children: [
              Expanded(child: Text(l10n.typographyPreset)),
              NeumorphicDropdown<ReaderTypographyPreset>(
                value: themeState.preset,
                onChanged: (ReaderTypographyPreset? p) {
                  if (p != null) {
                    ref.read(themeControllerProvider.notifier).setPreset(p);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ReaderTypographyPreset.system,
                    child: Text(l10n.system),
                  ),
                  DropdownMenuItem(
                    value: ReaderTypographyPreset.comfortable,
                    child: Text(l10n.typographyComfortable),
                  ),
                  DropdownMenuItem(
                    value: ReaderTypographyPreset.compact,
                    child: Text(l10n.typographyCompact),
                  ),
                  DropdownMenuItem(
                    value: ReaderTypographyPreset.serifLike,
                    child: Text(l10n.typographySerifLike),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.font_download_outlined),
          title: Row(
            children: [
              Expanded(child: Text(l10n.fontPack)),
              NeumorphicDropdown<ReaderFontPack>(
                value: themeState.fontPack,
                onChanged: (ReaderFontPack? fp) {
                  if (fp != null) {
                    ref.read(themeControllerProvider.notifier).setFontPack(fp);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ReaderFontPack.system,
                    child: Text(l10n.systemFont),
                  ),
                  DropdownMenuItem(
                    value: ReaderFontPack.inter,
                    child: Text(l10n.fontInter),
                  ),
                  DropdownMenuItem(
                    value: ReaderFontPack.merriweather,
                    child: Text(l10n.fontMerriweather),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.font_download),
          title: Row(
            children: [
              Expanded(child: Text(l10n.customFontFamily)),
              NeumorphicDropdown<String>(
                value:
                    supportedChineseFontFamilies().contains(
                      themeState.customFontFamily,
                    )
                    ? themeState.customFontFamily
                    : null,
                hint: Text(l10n.select),
                onChanged: (family) {
                  if (family != null) {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setCustomFontFamily(family);
                  }
                },
                items: supportedChineseFontFamilies()
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(displayFontFamily(f)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.clear,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setCustomFontFamily(null);
                },
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.text_increase),
          title: Text(l10n.textScale),
          subtitle: NeumorphicSlider(
            value: themeState.fontScale,
            onChanged: (value) {
              ref.read(themeControllerProvider.notifier).setFontScale(value);
            },
            min: 0.8,
            max: 3.2,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.layers),
          title: Row(
            children: [
              Expanded(child: Text(l10n.readerBackgroundDepth)),
              NeumorphicDropdown<ReaderBackgroundDepth>(
                value: themeState.readerBgDepth,
                onChanged: (ReaderBackgroundDepth? d) {
                  if (d != null) {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setReaderBackgroundDepth(d);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ReaderBackgroundDepth.low,
                    child: Text(l10n.depthLow),
                  ),
                  DropdownMenuItem(
                    value: ReaderBackgroundDepth.medium,
                    child: Text(l10n.depthMedium),
                  ),
                  DropdownMenuItem(
                    value: ReaderBackgroundDepth.high,
                    child: Text(l10n.depthHigh),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.separateTypographyPresets),
          leading: const Icon(Icons.text_fields_outlined),
          trailing: NeumorphicSwitch(
            value: themeState.hasSeparateTypography,
            onChanged: (v) => ref
                .read(themeControllerProvider.notifier)
                .setSeparateTypography(v),
          ),
        ),
        if (themeState.hasSeparateTypography) ...[
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.typographyLight)),
                NeumorphicDropdown<ReaderTypographyPreset>(
                  value: themeState.presetLight,
                  onChanged: (ReaderTypographyPreset? p) {
                    if (p != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setPresetLight(p);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.system,
                      child: Text(l10n.system),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.comfortable,
                      child: Text(l10n.typographyComfortable),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.compact,
                      child: Text(l10n.typographyCompact),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.serifLike,
                      child: Text(l10n.typographySerifLike),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.nights_stay_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.typographyDark)),
                NeumorphicDropdown<ReaderTypographyPreset>(
                  value: themeState.presetDark,
                  onChanged: (ReaderTypographyPreset? p) {
                    if (p != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setPresetDark(p);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.system,
                      child: Text(l10n.system),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.comfortable,
                      child: Text(l10n.typographyComfortable),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.compact,
                      child: Text(l10n.typographyCompact),
                    ),
                    DropdownMenuItem(
                      value: ReaderTypographyPreset.serifLike,
                      child: Text(l10n.typographySerifLike),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
