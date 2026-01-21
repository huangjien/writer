import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../../theme/design_tokens.dart';
import '../../shared/widgets/mobile_bottom_nav_bar.dart';
import '../../shared/widgets/mobile_fab.dart';
import '../../shared/widgets/mobile_novel_card.dart';
import '../../shared/widgets/mobile_bottom_sheet.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/theme_aware_card.dart';
import '../../shared/widgets/animated_list_builder.dart';
import '../../shared/widgets/parallax_header.dart';
import '../../shared/widgets/scroll_reveal.dart';
import '../../shared/widgets/gestures/pull_to_refresh.dart';
import '../../shared/widgets/empty_states/novel_empty_state.dart';
import '../../shared/widgets/neumorphic_textfield.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../models/novel.dart';
import '../../features/reader/reader_screen.dart';
import '../../state/motion_settings.dart';
import 'widgets/enhanced_search_bar.dart';

/// Mobile-optimized library screen wrapper
/// Features:
/// - Bottom navigation bar
/// - FAB for quick actions
/// - Pull-to-refresh
/// - Swipe actions on cards
/// - Simplified app bar
class MobileLibraryScreen extends ConsumerStatefulWidget {
  const MobileLibraryScreen({
    super.key,
    required this.novels,
    required this.onRefresh,
    required this.onCreateNovel,
    this.onDownload,
    this.onDelete,
    this.onFavorite,
    this.favorites = const <String>{},
    this.progressMap = const <String, double>{},
    this.lastReadMap = const <String, String>{},
    this.searchQuery = '',
    this.onSearchChanged,
    this.filterChips,
    this.selectedFilter,
    this.onFilterChanged,
  });

  final List<Novel> novels;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreateNovel;
  final void Function(String novelId)? onDownload;
  final void Function(String novelId)? onDelete;
  final void Function(String novelId)? onFavorite;
  final Set<String> favorites;
  final Map<String, double> progressMap;
  final Map<String, String> lastReadMap;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final List<String>? filterChips;
  final String? selectedFilter;
  final ValueChanged<String>? onFilterChanged;

  @override
  ConsumerState<MobileLibraryScreen> createState() =>
      _MobileLibraryScreenState();
}

class _MobileLibraryScreenState extends ConsumerState<MobileLibraryScreen> {
  MobileNavTab _currentTab = MobileNavTab.home;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    widget.onSearchChanged?.call(_searchController.text);
  }

  void _onTabChanged(MobileNavTab tab) {
    setState(() {
      _currentTab = tab;
    });
    _handleTabNavigation(tab);
  }

  void _handleTabNavigation(MobileNavTab tab) {
    switch (tab) {
      case MobileNavTab.home:
        // Already on home
        break;
      case MobileNavTab.write:
        // Navigate to write screen
        break;
      case MobileNavTab.read:
        // Navigate to reading screen
        break;
      case MobileNavTab.tools:
        _showToolsMenu();
        break;
      case MobileNavTab.more:
        _showMoreMenu();
        break;
    }
  }

  void _showToolsMenu() {
    MobileBottomSheet.showActionSheet(
      context: context,
      items: [
        const ActionSheetItem(
          label: 'Character Templates',
          icon: Icons.person,
          value: 'characters',
        ),
        const ActionSheetItem(
          label: 'Scene Templates',
          icon: Icons.movie,
          value: 'scenes',
        ),
        const ActionSheetItem(
          label: 'Prompts',
          icon: Icons.chat_bubble,
          value: 'prompts',
        ),
        const ActionSheetItem(
          label: 'Patterns',
          icon: Icons.auto_awesome,
          value: 'patterns',
        ),
        const ActionSheetItem(
          label: 'Story Lines',
          icon: Icons.timeline,
          value: 'storylines',
        ),
      ],
    );
  }

  void _showMoreMenu() {
    MobileBottomSheet.showActionSheet(
      context: context,
      items: [
        const ActionSheetItem(
          label: 'Settings',
          icon: Icons.settings,
          value: 'settings',
        ),
        const ActionSheetItem(label: 'About', icon: Icons.info, value: 'about'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = ref.watch(motionSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: PullToRefresh(
            onRefresh: widget.onRefresh,
            controller: _scrollController,
            child: _buildContent(context, theme, motion),
          ),
        ),
      ),
      // FAB
      floatingActionButton: MobileFab(
        onPressed: widget.onCreateNovel,
        label: 'Create Novel',
        icon: Icons.add,
        type: MobileFabType.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Bottom Navigation
      bottomNavigationBar: MobileBottomNavBar(
        currentTab: _currentTab,
        onTabChanged: _onTabChanged,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    MotionSettings motion,
  ) {
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        ParallaxHeader(
          minExtent: 64,
          maxExtent: 112,
          builder: (context, shrinkOffset, overlaps) {
            final t = (shrinkOffset / (112 - 64)).clamp(0.0, 1.0);
            final titleStyle = theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22 - (4 * t),
            );

            return ThemeAwareCard(
              borderRadius: BorderRadius.zero,
              semanticType: CardSemanticType.default_,
              padding: EdgeInsets.lerp(
                const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.m,
                ),
                const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                t,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(0, -6 * t),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: Spacing.s),
                            Text('Library', style: titleStyle),
                          ],
                        ),
                      ),
                    ),
                    AppButtons.icon(
                      iconData: Icons.more_vert,
                      onPressed: _showMoreMenu,
                      tooltip: 'More',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Search bar
        SliverToBoxAdapter(
          child: ScrollReveal(
            enabled: !motion.reduceMotion,
            child: _buildSearchBar(context, theme),
          ),
        ),
        // Filter chips
        if (widget.filterChips != null && widget.filterChips!.isNotEmpty)
          SliverToBoxAdapter(
            child: ScrollReveal(
              enabled: !motion.reduceMotion,
              child: _buildFilterChips(context, theme),
            ),
          ),
        // Novel list
        if (widget.novels.isEmpty)
          SliverFillRemaining(child: _buildEmptyState(context, theme))
        else
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.m),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final novel = widget.novels[index];
                final item = Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.m),
                  child: OpenContainer(
                    closedElevation: 0,
                    closedColor: Colors.transparent,
                    transitionDuration: Duration(
                      milliseconds: motion.reduceMotion ? 0 : 400,
                    ),
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (context, _) {
                      return ReaderScreen(novelId: novel.id);
                    },
                    closedBuilder: (context, action) {
                      return MobileNovelCard(
                        novel: novel,
                        onTap: action,
                        onDownload: widget.onDownload != null
                            ? () => widget.onDownload!(novel.id)
                            : null,
                        onDelete: widget.onDelete != null
                            ? () => widget.onDelete!(novel.id)
                            : null,
                        onFavorite: widget.onFavorite != null
                            ? () => widget.onFavorite!(novel.id)
                            : null,
                        isFavorite: widget.favorites.contains(novel.id),
                        progress: widget.progressMap[novel.id] ?? 0.0,
                        lastRead: widget.lastReadMap[novel.id],
                      );
                    },
                  ),
                );

                return AnimatedListItem(
                  index: index,
                  reduceMotion: motion.reduceMotion,
                  child: ScrollReveal(
                    enabled: !motion.reduceMotion,
                    child: item,
                  ),
                );
              }, childCount: widget.novels.length),
            ),
          ),
        // Bottom padding for FAB and nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.m),
      child: NeumorphicTextField(
        controller: _searchController,
        hintText: 'Search novels...',
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: AppButtons.icon(
                  iconData: Icons.clear,
                  onPressed: () => _searchController.clear(),
                  tooltip: 'Clear search',
                  color: theme.colorScheme.onSurfaceVariant,
                  focusPadding: EdgeInsets.zero,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
          itemCount: widget.filterChips!.length,
          itemBuilder: (context, index) {
            final filter = widget.filterChips![index];
            final isSelected = filter == widget.selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.s),
              child: LibraryFilterChip(
                label: filter,
                selected: isSelected,
                onTap: () => widget.onFilterChanged?.call(filter),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return NovelEmptyState(
      title: 'No novels found',
      subtitle: 'Create your first novel to get started',
      actionLabel: 'Create Novel',
      onAction: widget.onCreateNovel,
    );
  }
}
