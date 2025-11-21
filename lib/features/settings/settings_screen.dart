import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'widgets/reader_bundle_grid.dart';
import 'widgets/performance_section.dart';
import 'widgets/typography_settings_section.dart';
import 'widgets/supabase_section.dart';
import 'widgets/app_settings_section.dart';
import 'widgets/palette_settings_section.dart';
import 'widgets/tts_settings_container.dart';
import 'package:novel_reader/theme/reader_bundles.dart';
import 'package:novel_reader/state/progress_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('[Settings] initState');
    // Ensure latest progress is refreshed when opening Settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.invalidate(latestUserProgressProvider);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = supabaseEnabled
        ? Supabase.instance.client.auth.currentUser
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          if (supabaseEnabled)
            IconButton(
              icon: Icon(user == null ? Icons.login : Icons.logout),
              onPressed: () async {
                if (user == null) {
                  context.go('/settings/login');
                } else {
                  await Supabase.instance.client.auth.signOut();
                  setState(() {});
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                l10n.signedInAs(user.email!),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          const AppSettingsSection(),
          const PaletteSettingsSection(),
          const TypographySettingsSection(),
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
          // Performance Settings
          const PerformanceSection(),
          const Divider(),
          SupabaseSection(user: user),
          const Divider(),
          const TtsSettingsContainer(),
        ],
      ),
    );
  }
}
