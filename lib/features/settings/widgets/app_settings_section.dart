import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/app_settings.dart';
import '../../../state/motion_settings.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/themes.dart';

class AppSettingsSection extends ConsumerWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appLocale = ref.watch(appSettingsProvider);
    final themeState = ref.watch(themeControllerProvider);
    final motion = ref.watch(motionSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appSettings, style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          leading: const Icon(Icons.language),
          title: Row(
            children: [
              Expanded(child: Text(l10n.appLanguage)),
              DropdownButton<String>(
                value: appLocale.languageCode,
                onChanged: (String? languageCode) {
                  if (languageCode != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setLanguage(languageCode);
                  }
                },
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                  DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: Row(
            children: [
              Expanded(child: Text(l10n.themeMode)),
              DropdownButton<ThemeMode>(
                value: themeState.mode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    ref.read(themeControllerProvider.notifier).setMode(mode);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(l10n.system),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(l10n.light),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(l10n.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SwitchListTile.adaptive(
            value: ref.watch(motionSettingsProvider).reduceMotion,
            onChanged: (v) =>
                ref.read(motionSettingsProvider.notifier).setReduceMotion(v),
            title: Text(l10n.reduceMotion),
            subtitle: Text(l10n.reduceMotionDescription),
            secondary: const Icon(Icons.motion_photos_off),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SwitchListTile.adaptive(
            value: motion.gesturesEnabled,
            onChanged: (v) =>
                ref.read(motionSettingsProvider.notifier).setGesturesEnabled(v),
            title: Text(l10n.gesturesEnabled),
            subtitle: Text(l10n.gesturesEnabledDescription),
            secondary: const Icon(Icons.touch_app),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.swipe),
            title: Text(l10n.readerSwipeSensitivity),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.readerSwipeSensitivityDescription),
                Slider(
                  value: motion.swipeMinVelocity,
                  onChanged: (value) {
                    ref
                        .read(motionSettingsProvider.notifier)
                        .setSwipeMinVelocity(value);
                  },
                  min: 50.0,
                  max: 800.0,
                  divisions: 15,
                  label: motion.swipeMinVelocity.round().toString(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SwitchListTile.adaptive(
            value: themeState.family == AppThemeFamily.highContrast,
            onChanged: (v) {
              final controller = ref.read(themeControllerProvider.notifier);
              controller.setFamily(
                v ? AppThemeFamily.highContrast : AppThemeFamily.sepia,
              );
            },
            title: Text(l10n.themeHighContrast),
            secondary: const Icon(Icons.invert_colors),
          ),
        ),
      ],
    );
  }
}
