import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/theme_controller.dart';
import 'widgets/reader_bundle_grid.dart';
import 'widgets/performance_section.dart';
import 'widgets/typography_settings_section.dart';
import 'widgets/app_settings_section.dart';
import 'widgets/palette_settings_section.dart';
import 'widgets/tts_settings_container.dart';
import 'package:writer/theme/reader_bundles.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import '../../state/user_state.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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
    final isSignedIn = ref.watch(isSignedInProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final userAsync = ref.watch(userProvider);
    final isAdmin = userAsync.value?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
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
          const TtsSettingsContainer(),
          const Divider(),
          if (isAdmin) ...[
            ListTile(
              title: const Text('User Management'),
              leading: const Icon(Icons.people),
              onTap: () => context.push('/admin/users'),
            ),
            const Divider(),
          ],
          if (!isSignedIn)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: FilledButton(
                  onPressed: () => context.push('/auth'),
                  child: Text(l10n.signIn),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  onPressed: () async {
                    await ref.read(sessionProvider.notifier).clear();
                    ref.invalidate(currentUserProvider);
                    if (mounted) setState(() {});
                  },
                  child: Text(l10n.signOut),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
