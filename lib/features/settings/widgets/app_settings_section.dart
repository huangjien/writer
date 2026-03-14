import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/neumorphic_textfield.dart';
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
      _resetUnsupportedLocale();
    });
  }

  void _resetUnsupportedLocale() {
    final currentLocale = ref.read(appSettingsProvider);
    final supportedLocales = [
      'en',
      'zh',
      'zh-TW',
      'de',
      'es',
      'fr',
      'it',
      'ja',
      'ko',
    ];
    final currentLocaleTag = currentLocale.toLanguageTag();

    if (!supportedLocales.contains(currentLocaleTag)) {
      ref.read(appSettingsProvider.notifier).setLanguage('en');
    }
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
    final aiAgentSettings = ref.watch(aiAgentSettingsProvider);

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
                value: appLocale.toLanguageTag(),
                onChanged: (String? languageCode) {
                  if (languageCode != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setLanguage(languageCode);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                  DropdownMenuItem(value: 'zh-TW', child: Text('繁體')),
                  DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'it', child: Text('Italiano')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
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
          key: const Key('ai_service_url_setting'),
          leading: const Icon(Icons.auto_awesome),
          title: Text(l10n.aiServiceUrl),
          trailing: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: () => _showAiServiceUrlDialog(context),
            ),
          ),
          subtitle: Text(ref.watch(aiServiceProvider)),
        ),
        EnhancedSettingsSection(
          title: l10n.deepAgentSettingsTitle,
          icon: Icons.auto_awesome,
          description: l10n.deepAgentSettingsDescription,
          children: [
            SettingsToggle(
              title: l10n.deepAgentPreferTitle,
              subtitle: l10n.deepAgentPreferSubtitle,
              value: aiAgentSettings.preferDeepAgent,
              icon: Icons.auto_awesome,
              onChanged: (v) => ref
                  .read(aiAgentSettingsProvider.notifier)
                  .setPreferDeepAgent(v ?? true),
            ),
            SettingsToggle(
              title: l10n.deepAgentFallbackTitle,
              subtitle: l10n.deepAgentFallbackSubtitle,
              value: aiAgentSettings.deepAgentFallbackToQa,
              enabled: aiAgentSettings.preferDeepAgent,
              icon: Icons.alt_route,
              onChanged: (v) => ref
                  .read(aiAgentSettingsProvider.notifier)
                  .setDeepAgentFallbackToQa(v ?? true),
            ),
            SettingsSelection<DeepAgentReflectionMode>(
              title: l10n.deepAgentReflectionModeTitle,
              subtitle: l10n.deepAgentReflectionModeSubtitle,
              icon: Icons.auto_awesome,
              value: aiAgentSettings.deepAgentReflectionMode,
              options: [
                SettingsOption(
                  label: l10n.deepAgentReflectionModeOff,
                  value: DeepAgentReflectionMode.off,
                ),
                SettingsOption(
                  label: l10n.deepAgentReflectionModeOnFailure,
                  value: DeepAgentReflectionMode.onFailure,
                ),
                SettingsOption(
                  label: l10n.deepAgentReflectionModeAlways,
                  value: DeepAgentReflectionMode.always,
                ),
              ],
              onChanged: (mode) {
                if (mode == null) return;
                ref
                    .read(aiAgentSettingsProvider.notifier)
                    .setDeepAgentReflectionMode(mode);
              },
            ),
            SettingsToggle(
              title: l10n.deepAgentShowDetailsTitle,
              subtitle: l10n.deepAgentShowDetailsSubtitle,
              value: aiAgentSettings.deepAgentShowDetails,
              icon: Icons.subject,
              onChanged: (v) => ref
                  .read(aiAgentSettingsProvider.notifier)
                  .setDeepAgentShowDetails(v ?? false),
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: Text(l10n.deepAgentMaxPlanSteps),
              subtitle: NeumorphicSlider(
                value: aiAgentSettings.deepAgentMaxPlanSteps.toDouble(),
                min: 1,
                max: 12,
                onChanged: aiAgentSettings.preferDeepAgent
                    ? (value) => ref
                          .read(aiAgentSettingsProvider.notifier)
                          .setDeepAgentMaxPlanSteps(value.round())
                    : null,
              ),
              trailing: Text('${aiAgentSettings.deepAgentMaxPlanSteps}'),
            ),
            ListTile(
              leading: const Icon(Icons.loop),
              title: Text(l10n.deepAgentMaxToolRounds),
              subtitle: NeumorphicSlider(
                value: aiAgentSettings.deepAgentMaxToolRounds.toDouble(),
                min: 1,
                max: 20,
                onChanged: aiAgentSettings.preferDeepAgent
                    ? (value) => ref
                          .read(aiAgentSettingsProvider.notifier)
                          .setDeepAgentMaxToolRounds(value.round())
                    : null,
              ),
              trailing: Text('${aiAgentSettings.deepAgentMaxToolRounds}'),
            ),
          ],
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
            key: const Key('reduce_motion_setting'),
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
