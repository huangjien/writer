import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/design_tokens.dart';
import '../../shared/widgets/mobile_bottom_nav_bar.dart';
import '../../l10n/app_localizations.dart';

/// Mobile-optimized tools screen
/// Features:
/// - 2-column grid layout
/// - Large touch targets (80dp minimum)
/// - Quick access to all tools
class MobileToolsScreen extends StatefulWidget {
  const MobileToolsScreen({super.key});

  @override
  State<MobileToolsScreen> createState() => _MobileToolsScreenState();
}

class _MobileToolsScreenState extends State<MobileToolsScreen> {
  MobileNavTab _currentTab = MobileNavTab.tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, l10n, theme),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: Spacing.m,
            crossAxisSpacing: Spacing.m,
            childAspectRatio: 1.2,
            children: [
              _buildToolCard(
                context,
                icon: Icons.person,
                label: l10n.characterTemplates,
                color: theme.colorScheme.primary,
                onTap: () => _navigateToCharacterTemplates(context),
              ),
              _buildToolCard(
                context,
                icon: Icons.movie,
                label: l10n.sceneTemplates,
                color: theme.colorScheme.secondary,
                onTap: () => _navigateToSceneTemplates(context),
              ),
              _buildToolCard(
                context,
                icon: Icons.chat_bubble,
                label: l10n.prompts,
                color: theme.colorScheme.tertiary,
                onTap: () => context.push('/prompts'),
              ),
              _buildToolCard(
                context,
                icon: Icons.auto_awesome,
                label: l10n.patterns,
                color: theme.colorScheme.primary,
                onTap: () => context.push('/patterns'),
              ),
              _buildToolCard(
                context,
                icon: Icons.timeline,
                label: l10n.storyLines,
                color: theme.colorScheme.secondary,
                onTap: () => context.push('/story_lines'),
              ),
              _buildToolCard(
                context,
                icon: Icons.settings,
                label: l10n.settings,
                color: theme.colorScheme.tertiary,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MobileBottomNavBar(
        currentTab: _currentTab,
        onTabChanged: _onTabChanged,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return AppBar(
      title: Text(l10n.tools),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreMenu(context, l10n),
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.l),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Radii.l),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Radii.m),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: Spacing.s),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _onTabChanged(MobileNavTab tab) {
    setState(() {
      _currentTab = tab;
    });
    _handleTabNavigation(tab, context);
  }

  void _handleTabNavigation(MobileNavTab tab, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (tab) {
      case MobileNavTab.home:
        context.push('/');
        break;
      case MobileNavTab.write:
        // Navigate to write screen
        break;
      case MobileNavTab.read:
        // Navigate to reading screen
        break;
      case MobileNavTab.tools:
        // Already on tools
        break;
      case MobileNavTab.more:
        _showMoreMenu(context, l10n);
        break;
    }
  }

  void _showMoreMenu(BuildContext context, AppLocalizations l10n) {
    // This is a placeholder - implement based on actual menu items
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('More menu coming soon')));
  }

  void _navigateToCharacterTemplates(BuildContext context) {
    // Navigate to character templates
    // This would need the novel ID - for now show a placeholder
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Select a novel first')));
  }

  void _navigateToSceneTemplates(BuildContext context) {
    // Navigate to scene templates
    // This would need the novel ID - for now show a placeholder
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Select a novel first')));
  }
}
