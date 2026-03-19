import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/reader_bundles.dart';
import 'package:writer/features/settings/widgets/reader_bundle_grid.dart';
import 'package:writer/features/settings/widgets/performance_section.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/features/settings/widgets/style_settings_section.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/token_usage_section.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _appSettingsKey = GlobalKey();
  final _paletteSettingsKey = GlobalKey();
  final _typographySettingsKey = GlobalKey();
  final _performanceKey = GlobalKey();
  final _ttsSettingsKey = GlobalKey();

  void _focusSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 200),
      alignment: 0.08,
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[Settings] initState');
    // Ensure latest progress is refreshed when opening Settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          ref.invalidate(latestUserProgressProvider);
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final userAsync = ref.watch(userProvider);
    final isAdmin = userAsync.value?.isAdmin ?? false;

    return SettingsShortcutsWrapper(
      onFocusAppSettings: () => _focusSection(_appSettingsKey),
      onFocusColorTheme: () => _focusSection(_paletteSettingsKey),
      onFocusTypography: () => _focusSection(_typographySettingsKey),
      onFocusPerformance: () => _focusSection(_performanceKey),
      onFocusTTSSettings: () => _focusSection(_ttsSettingsKey),
      child: Scaffold(
        appBar: AppBar(
          leading: AppButtons.icon(
            iconData: Icons.home,
            tooltip: l10n.home,
            onPressed: () => context.go('/'),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settings),
              if (currentUser != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.signedInAs(currentUser.email ?? currentUser.id),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          actions: const [],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            KeyedSubtree(
              key: _appSettingsKey,
              child: const AppSettingsSection(),
            ),
            const Divider(),
            KeyedSubtree(
              key: _paletteSettingsKey,
              child: const PaletteSettingsSection(),
            ),
            const StyleSettingsSection(),
            KeyedSubtree(
              key: _typographySettingsKey,
              child: const TypographySettingsSection(),
            ),
            const Divider(),
            Text(
              l10n.readerBundles,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ReaderBundleGrid(
              onApply: (id) {
                final def = readerThemeBundles[id]!;
                final controller = ref.read(themeControllerProvider.notifier);
                controller.setSeparateDark(false);
                controller.setFamily(def.family);
                controller.setFontPack(def.fontPack);
                controller.setPreset(def.preset);
              },
            ),
            const Divider(),
            KeyedSubtree(
              key: _performanceKey,
              child: const PerformanceSection(),
            ),
            const Divider(),
            KeyedSubtree(
              key: _ttsSettingsKey,
              child: const TtsSettingsContainer(),
            ),
            const Divider(),
            if (currentUser != null) ...[
              ListTile(
                title: Text(
                  l10n.tokenUsage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                enabled: false,
              ),
              const TokenUsageSection(),
            ],
            const Divider(),
            if (isAdmin) ...[
              const Divider(),
              ListTile(
                title: Text(
                  l10n.adminMode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => context.push('/admin'),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: Text(l10n.adminLogs),
                subtitle: Text(l10n.viewAndFilterBackendLogs),
                onTap: () => context.push('/admin/logs'),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.style),
                title: Text(l10n.styleGuide),
                onTap: () => context.push('/style-guide'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
            if (!isSignedIn)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: AppButtons.primary(
                    onPressed: () => context.push('/auth'),
                    label: l10n.signIn,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: AppButtons.text(
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () async {
                      await ref.read(sessionProvider.notifier).clear();
                      ref.invalidate(currentUserProvider);
                      if (mounted) setState(() {});
                    },
                    label: l10n.signOut,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
