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
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/neumorphic_slider.dart';
import '../../../shared/widgets/neumorphic_dropdown.dart';
import '../../../shared/widgets/neumorphic_textfield.dart';
import 'enhanced_settings_section.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final currentUrl = ref.read(aiServiceProvider);
    final controller = TextEditingController(text: currentUrl);
    String? validationError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AppDialog(
            title: l10n.aiServiceUrl,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiServiceUrlHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.m),
                Text(l10n.urlLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: Spacing.xs),
                NeumorphicTextField(
                  controller: controller,
                  hintText: l10n.aiServiceUrlHint,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {
                      validationError = _validateAiServiceUrl(value, context);
                    });
                  },
                  onSubmitted: (_) async {
                    if (validationError != null) return;
                    final newUrl = controller.text.trim();
                    if (newUrl.isNotEmpty) {
                      await ref
                          .read(aiServiceProvider.notifier)
                          .setAiServiceUrl(newUrl);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                if (validationError != null) ...[
                  const SizedBox(height: Spacing.s),
                  Text(
                    validationError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              AppButtons.text(
                onPressed: () {
                  ref.read(aiServiceProvider.notifier).resetToDefault();
                  controller.text = ref.read(aiServiceProvider);
                  setState(() {
                    validationError = null;
                  });
                },
                label: l10n.resetToDefault,
              ),
              AppButtons.text(
                onPressed: () => Navigator.of(context).pop(),
                label: l10n.cancel,
              ),
              AppButtons.primary(
                onPressed: validationError == null
                    ? () async {
                        final newUrl = controller.text.trim();
                        if (newUrl.isNotEmpty) {
                          await ref
                              .read(aiServiceProvider.notifier)
                              .setAiServiceUrl(newUrl);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : () {},
                label: l10n.save,
                enabled: validationError == null,
              ),
            ],
          );
        },
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
              NeumorphicDropdown<String>(
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
              NeumorphicDropdown<ThemeMode>(
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
            return SettingsToggle(
              title: l10n.adminMode,
              value: enabled,
              enabled: notifier != null,
              onChanged: (v) => notifier?.setAdmin(v ?? false),
              icon: Icons.security,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SettingsToggle(
            value: ref.watch(motionSettingsProvider).reduceMotion,
            title: l10n.reduceMotion,
            subtitle: l10n.reduceMotionDescription,
            icon: Icons.motion_photos_off,
            onChanged: (v) => ref
                .read(motionSettingsProvider.notifier)
                .setReduceMotion(v ?? false),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SettingsToggle(
            value: motion.gesturesEnabled,
            title: l10n.gesturesEnabled,
            subtitle: l10n.gesturesEnabledDescription,
            icon: Icons.touch_app,
            onChanged: (v) => ref
                .read(motionSettingsProvider.notifier)
                .setGesturesEnabled(v ?? false),
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
                const SizedBox(height: Spacing.s),
                NeumorphicSlider(
                  value: motion.swipeMinVelocity,
                  onChanged: (value) => ref
                      .read(motionSettingsProvider.notifier)
                      .setSwipeMinVelocity(value),
                  min: 100,
                  max: 2000,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.22),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  motion.swipeMinVelocity.round().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (isBiometricAvailable && sessionId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsToggle(
              value: biometricState == BiometricAuthState.enabled,
              onChanged: (v) async {
                if (v ?? false) {
                  await ref
                      .read(biometricSessionProvider.notifier)
                      .enableBiometricAuth(sessionId);
                } else {
                  await ref
                      .read(biometricSessionProvider.notifier)
                      .disableBiometricAuth();
                }
              },
              title: l10n.enableBiometricLogin,
              subtitle: l10n.enableBiometricLoginDescription,
              icon: Icons.fingerprint,
            ),
          ),
      ],
    );
  }
}
