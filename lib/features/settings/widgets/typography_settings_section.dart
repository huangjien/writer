import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/reader_typography.dart';
import '../../../theme/font_packs.dart';
import '../../../theme/reader_background.dart';
import '../../../state/theme_controller.dart';

class TypographySettingsSection extends ConsumerWidget {
  const TypographySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.format_size),
          title: Row(
            children: [
              Expanded(child: Text(l10n.typographyPreset)),
              DropdownButton<ReaderTypographyPreset>(
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
              DropdownButton<ReaderFontPack>(
                value: themeState.fontPack,
                onChanged: (ReaderFontPack? fp) {
                  if (fp != null) {
                    ref.read(themeControllerProvider.notifier).setFontPack(fp);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ReaderFontPack.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ReaderFontPack.inter,
                    child: Text('Inter'),
                  ),
                  DropdownMenuItem(
                    value: ReaderFontPack.merriweather,
                    child: Text('Merriweather'),
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
              PopupMenuButton<String>(
                tooltip: l10n.commonFonts,
                onSelected: (family) {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setCustomFontFamily(family);
                },
                itemBuilder: (context) {
                  const families = <String>[
                    'system-ui',
                    'Segoe UI',
                    '.SF NS Display',
                    'San Francisco',
                    'Helvetica Neue',
                    'Helvetica',
                    'Arial',
                    'Times New Roman',
                    'Georgia',
                    'Cambria',
                    'Noto Sans',
                    'Noto Serif',
                    'Roboto',
                    'Courier New',
                    'Menlo',
                    'Monaco',
                    'Consolas',
                  ];
                  return families
                      .map(
                        (f) => PopupMenuItem<String>(value: f, child: Text(f)),
                      )
                      .toList();
                },
                child: Row(
                  children: [
                    Text(
                      themeState.customFontFamily?.isNotEmpty == true
                          ? themeState.customFontFamily!
                          : l10n.select,
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
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
          subtitle: Slider(
            value: themeState.fontScale,
            onChanged: (value) {
              ref.read(themeControllerProvider.notifier).setFontScale(value);
            },
            min: 0.8,
            max: 3.2,
            divisions: 24,
            label: '${(themeState.fontScale * 100).round()}%',
            semanticFormatterCallback: (double v) => '${(v * 100).round()}%',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.layers),
          title: Row(
            children: [
              Expanded(child: Text(l10n.readerBackgroundDepth)),
              DropdownButton<ReaderBackgroundDepth>(
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
        SwitchListTile.adaptive(
          value: themeState.hasSeparateTypography,
          onChanged: (v) => ref
              .read(themeControllerProvider.notifier)
              .setSeparateTypography(v),
          title: Text(l10n.separateTypographyPresets),
          secondary: const Icon(Icons.text_fields_outlined),
        ),
        if (themeState.hasSeparateTypography) ...[
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.typographyLight)),
                DropdownButton<ReaderTypographyPreset>(
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
                DropdownButton<ReaderTypographyPreset>(
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
