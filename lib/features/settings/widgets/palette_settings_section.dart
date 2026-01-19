import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/themes.dart';
import '../../../shared/widgets/neumorphic_dropdown.dart';
import '../../../shared/widgets/neumorphic_switch.dart';
import 'theme_preview.dart';

class PaletteSettingsSection extends ConsumerWidget {
  const PaletteSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeControllerProvider);
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
        if (!themeState.hasSeparateDark) ...[
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
                  items: [
                    DropdownMenuItem(
                      value: AppThemeFamily.defaultFamily,
                      child: Text(l10n.themeDefault),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.sepia,
                      child: Text(l10n.themeSepia),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.emeraldGreen,
                      child: Text(l10n.themeEmeraldGreen),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarized,
                      child: Text(l10n.themeSolarized),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarizedTan,
                      child: Text(l10n.themeSolarizedTan),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nord,
                      child: Text(l10n.themeNord),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordFrost,
                      child: Text(l10n.themeNordFrost),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordSnowstorm,
                      child: Text(l10n.themeNordSnowstorm),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.highContrast,
                      child: Text(l10n.themeHighContrast),
                    ),
                  ],
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
                  items: [
                    DropdownMenuItem(
                      value: AppThemeFamily.defaultFamily,
                      child: Text(l10n.themeDefault),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.sepia,
                      child: Text(l10n.themeSepia),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.emeraldGreen,
                      child: Text(l10n.themeEmeraldGreen),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarized,
                      child: Text(l10n.themeSolarized),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarizedTan,
                      child: Text(l10n.themeSolarizedTan),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nord,
                      child: Text(l10n.themeNord),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordFrost,
                      child: Text(l10n.themeNordFrost),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordSnowstorm,
                      child: Text(l10n.themeNordSnowstorm),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.highContrast,
                      child: Text(l10n.themeHighContrast),
                    ),
                  ],
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
                  items: [
                    DropdownMenuItem(
                      value: AppThemeFamily.defaultFamily,
                      child: Text(l10n.themeDefault),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.sepia,
                      child: Text(l10n.themeSepia),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.emeraldGreen,
                      child: Text(l10n.themeEmeraldGreen),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarized,
                      child: Text(l10n.themeSolarized),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.solarizedTan,
                      child: Text(l10n.themeSolarizedTan),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nord,
                      child: Text(l10n.themeNord),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordFrost,
                      child: Text(l10n.themeNordFrost),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.nordSnowstorm,
                      child: Text(l10n.themeNordSnowstorm),
                    ),
                    DropdownMenuItem(
                      value: AppThemeFamily.highContrast,
                      child: Text(l10n.themeHighContrast),
                    ),
                  ],
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
