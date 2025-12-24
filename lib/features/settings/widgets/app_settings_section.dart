import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/ai_service_settings.dart';
import '../../../state/app_settings.dart';
import '../../../state/admin_settings.dart';
import '../../../state/biometric_session_state.dart';
import '../../../state/motion_settings.dart';
import '../../../state/session_state.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/themes.dart';

class AppSettingsSection extends ConsumerStatefulWidget {
  const AppSettingsSection({super.key});

  @override
  ConsumerState<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends ConsumerState<AppSettingsSection> {
  @override
  void initState() {
    super.initState();
    // Check availability when settings are opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricSessionProvider.notifier).checkBiometricAvailability();
    });
  }

  void _showAiServiceUrlDialog(BuildContext context) {
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
              hintText: AppLocalizations.of(context)!.aiServiceUrlHint,
              labelText: AppLocalizations.of(context)!.urlLabel,
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
                controller.text = ref.read(aiServiceProvider);
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appLocale = ref.watch(appSettingsProvider);
    final themeState = ref.watch(themeControllerProvider);
    final motion = ref.watch(motionSettingsProvider);
    final biometricState = ref.watch(biometricSessionProvider);
    final isBiometricAvailable =
        ref.watch(biometricAvailableProvider).asData?.value ?? false;
    final sessionId = ref.watch(sessionProvider);

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
                value: ThemeMode.values.firstWhere(
                  (e) => e.name == themeState.mode.name,
                  orElse: () => ThemeMode.system,
                ),
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
          leading: const Icon(Icons.smart_toy_outlined),
          title: Text(l10n.aiServiceUrl),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showAiServiceUrlDialog(context),
          ),
          subtitle: Text(ref.watch(aiServiceProvider)),
        ),
        Builder(
          builder: (context) {
            bool enabled = false;
            AdminModeNotifier? notifier;
            try {
              enabled = ref.watch(adminModeProvider);
              notifier = ref.read(adminModeProvider.notifier);
            } catch (_) {}
            return SwitchListTile.adaptive(
              value: enabled,
              onChanged: notifier == null ? null : (v) => notifier!.setAdmin(v),
              title: Text(l10n.adminMode),
              secondary: const Icon(Icons.security),
            );
          },
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
                  min: 100,
                  max: 2000,
                  divisions: 19,
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
        if (isBiometricAvailable && sessionId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile.adaptive(
              value: biometricState == BiometricAuthState.enabled,
              onChanged: (v) async {
                if (v) {
                  await ref
                      .read(biometricSessionProvider.notifier)
                      .enableBiometricAuth(sessionId);
                } else {
                  await ref
                      .read(biometricSessionProvider.notifier)
                      .disableBiometricAuth();
                }
              },
              title: Text(l10n.enableBiometricLogin),
              subtitle: Text(l10n.enableBiometricLoginDescription),
              secondary: const Icon(Icons.fingerprint),
            ),
          ),
      ],
    );
  }
}
