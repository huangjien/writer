import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'theme_preview.dart';

class PaletteSettingsSection extends ConsumerWidget {
  const PaletteSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeControllerProvider);
    const themes = themeFactoryThemes;
    final hasThemes = themes.isNotEmpty;
    final dropdownItems = themes
        .map((t) {
          String label;
          switch (t.id) {
            case AppThemeFamily.oceanDepths:
              label = l10n.themeOceanDepths;
              break;
            case AppThemeFamily.sunsetBoulevard:
              label = l10n.themeSunsetBoulevard;
              break;
            case AppThemeFamily.forestCanopy:
              label = l10n.themeForestCanopy;
              break;
            case AppThemeFamily.modernMinimalist:
              label = l10n.themeModernMinimalist;
              break;
            case AppThemeFamily.goldenHour:
              label = l10n.themeGoldenHour;
              break;
            case AppThemeFamily.arcticFrost:
              label = l10n.themeArcticFrost;
              break;
            case AppThemeFamily.desertRose:
              label = l10n.themeDesertRose;
              break;
            case AppThemeFamily.techInnovation:
              label = l10n.themeTechInnovation;
              break;
            case AppThemeFamily.botanicalGarden:
              label = l10n.themeBotanicalGarden;
              break;
            case AppThemeFamily.midnightGalaxy:
              label = l10n.themeMidnightGalaxy;
              break;
          }
          return DropdownMenuItem(value: t.id, child: Text(label));
        })
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            title: Text(l10n.separateDarkPalette),
            leading: const Icon(Icons.brightness_6_outlined),
            trailing: NeumorphicSwitch(
              value: themeState.hasSeparateDark,
              onChanged: (v) =>
                  ref.read(themeControllerProvider.notifier).setSeparateDark(v),
            ),
          ),
        ),
        if (!hasThemes) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.colorTheme),
              subtitle: Text(l10n.themeFactoryNotDefined),
            ),
          ),
        ] else if (!themeState.hasSeparateDark) ...[
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.colorTheme)),
                NeumorphicDropdown<AppThemeFamily>(
                  value: themeState.family,
                  onChanged: (AppThemeFamily? f) {
                    if (f != null) {
                      ref.read(themeControllerProvider.notifier).setFamily(f);
                    }
                  },
                  items: dropdownItems,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ThemePreviewGrid(
              selected: themeState.family,
              onSelected: (f) =>
                  ref.read(themeControllerProvider.notifier).setFamily(f),
            ),
          ),
        ] else ...[
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.lightPalette)),
                NeumorphicDropdown<AppThemeFamily>(
                  value: themeState.familyLight,
                  onChanged: (AppThemeFamily? f) {
                    if (f != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setFamilyLight(f);
                    }
                  },
                  items: dropdownItems,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ThemePreviewGrid(
              selected: themeState.familyLight,
              onSelected: (f) =>
                  ref.read(themeControllerProvider.notifier).setFamilyLight(f),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.nights_stay_outlined),
            title: Row(
              children: [
                Expanded(child: Text(l10n.darkPalette)),
                NeumorphicDropdown<AppThemeFamily>(
                  value: themeState.familyDark,
                  onChanged: (AppThemeFamily? f) {
                    if (f != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setFamilyDark(f);
                    }
                  },
                  items: dropdownItems,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ThemePreviewGrid(
              selected: themeState.familyDark,
              onSelected: (f) =>
                  ref.read(themeControllerProvider.notifier).setFamilyDark(f),
            ),
          ),
        ],
      ],
    );
  }
}
