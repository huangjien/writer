import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/ai_service_settings.dart';
import '../../../state/app_settings.dart';
import '../../../state/motion_settings.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/themes.dart';

class AppSettingsSection extends ConsumerWidget {
  const AppSettingsSection({super.key});

  void _showAiServiceUrlDialog(BuildContext context, WidgetRef ref) {
    final currentUrl = ref.read(aiServiceProvider);
    final controller = TextEditingController(text: currentUrl);
    String? validationError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.aiServiceUrl),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'http://localhost:5600/',
              labelText: 'URL',
              errorText: validationError,
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              setState(() {
                validationError = _validateAiServiceUrl(value, context);
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(aiServiceProvider.notifier).resetToDefault();
                controller.text = 'http://localhost:5600/';
                setState(() {
                  validationError = null;
                });
              },
              child: Text(AppLocalizations.of(context)!.resetToDefault),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: validationError == null
                  ? () {
                      final newUrl = controller.text.trim();
                      if (newUrl.isNotEmpty) {
                        ref
                            .read(aiServiceProvider.notifier)
                            .setAiServiceUrl(newUrl);
                      }
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAiServiceUrl(String? raw, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null; // Allow empty for optional reset
    if (value.length > 2048) return l10n.urlTooLong;
    if (value.contains(' ')) return l10n.urlContainsSpaces;
    final lower = value.toLowerCase();
    final hasValidScheme =
        lower.startsWith('http://') || lower.startsWith('https://');
    if (!hasValidScheme) return l10n.urlInvalidScheme;
    return null;
  }

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
        ListTile(
          leading: const Icon(Icons.computer),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.aiServiceUrl),
                    Text(
                      l10n.aiServiceUrlDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAiServiceUrlDialog(context, ref),
              ),
            ],
          ),
          subtitle: Text(ref.watch(aiServiceProvider)),
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
