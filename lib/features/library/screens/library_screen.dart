import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/widgets/library_list_header.dart';
import 'package:writer/features/library/widgets/library_grid_item.dart';
import 'package:writer/features/library/widgets/library_item_row.dart';
import 'package:writer/features/library/widgets/library_loading_list.dart';
import 'package:writer/features/library/widgets/library_error_section.dart';
import 'package:writer/features/library/widgets/session_section.dart';
import 'package:writer/features/library/widgets/enhanced_search_bar.dart';
import 'package:writer/features/library/state/library_providers.dart';
import 'package:writer/features/library/state/library_screen_state.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/widgets/app_drawer.dart';
import 'package:writer/widgets/offline_banner.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/widgets/recent_chapters.dart';
import 'package:writer/widgets/sync_status_indicator.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/shared/widgets/mobile_fab.dart';
import 'package:writer/shared/widgets/mobile_novel_card.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/shared/widgets/empty_states/novel_empty_state.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';
import 'package:writer/features/ai_chat/widgets/ai_assistant_button.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  List<Novel> filterNovels(
    List<Novel> novels,
    Set<String> removedIds,
    Set<String> downloadedIds,
    List<UserProgress> recentProgress,
    String searchQuery,
    LibraryFilter filter,
  ) {
    final query = normalizeForSearch(searchQuery.trim());
    var filtered = query.isEmpty
        ? [...novels]
        : novels
              .where((n) => normalizeForSearch(n.title).contains(query))
              .toList();

    // Apply filter chips
    switch (filter) {
      case LibraryFilter.reading:
        // Show novels that are in recent progress OR have downloaded chapters
        final recentIds = recentProgress.map((p) => p.novelId).toSet();
        filtered = filtered
            .where(
              (n) => recentIds.contains(n.id) || downloadedIds.contains(n.id),
            )
            .toList();
        break;
      case LibraryFilter.completed:
        // Completion status is not currently tracked in Novel or UserProgress models
        // For now, return empty list
        filtered = [];
        break;
      case LibraryFilter.downloaded:
        filtered = filtered.where((n) => downloadedIds.contains(n.id)).toList();
        break;
      case LibraryFilter.all:
        break;
    }

    // Apply local removals with undo support
    return filtered.where((n) => !removedIds.contains(n.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    bool isAdmin;
    try {
      isAdmin = ref.watch(isAdminProvider);
    } catch (_) {
      // Fallback for tests or environments that don't override isAdminProvider
      isAdmin = false;
    }
    final libraryScreen = ref.watch(libraryScreenProvider);
    final novelsAsync = ref.watch(libraryNovelsProviderV2);

    // Watch providers for filtering
    final downloadedIdsAsync = ref.watch(downloadedNovelIdsProvider);
    final recentProgressAsync = ref.watch(recentUserProgressProvider);

    final downloadedIds = downloadedIdsAsync.asData?.value ?? {};
    final recentProgress = recentProgressAsync.asData?.value ?? [];

    ref.listen(memberNovelsProviderV2, (prev, next) {
      if (next.hasError) {
        final msg = l10n.errorLoadingNovels;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.showingCachedPublicData(msg))),
          );
        }
      }
    });

    final removedIds = ref.watch(removedNovelIdsProvider);
    // Remove is allowed offline for local hide/undo.
    // When signed-in, remove also deletes remotely (with confirmation).
    const canRemove = true;
    final canDownload = isSignedIn;

    // Use mobile layout for small screens
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;

    return LibraryShortcutsWrapper(
      onCreateNovel: () => context.pushNamed('createNovel'),
      onFocusSearch: () {},
      onDeleteNovel: () {},
      child: Scaffold(
        appBar: isMobile
            ? buildMobileAppBar(context, l10n)
            : buildDesktopAppBar(context, l10n, isSignedIn, isAdmin),
        drawer: isMobile ? null : const AppDrawer(),
        body: isMobile && libraryScreen.currentTab != MobileNavTab.home
            ? buildMobileTabContent(libraryScreen.currentTab)
            : Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.l,
                        Spacing.m,
                        Spacing.l,
                        Spacing.l,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SessionSection(isSignedIn: isSignedIn),
                          if (isSignedIn) ...[
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(
                                l10n.recentlyRead,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              children: const [
                                SizedBox(height: 8),
                                SizedBox(height: 150, child: RecentChapters()),
                              ],
                            ),
                            const SizedBox(height: Spacing.s),
                          ],
                          EnhancedSearchBar(
                            onChanged: (query) {
                              ref
                                  .read(libraryScreenProvider.notifier)
                                  .setSearchQuery(query);
                            },
                            hintText: l10n.searchNovels,
                            onClear: () {
                              ref
                                  .read(libraryScreenProvider.notifier)
                                  .setSearchQuery('');
                            },
                            showFilters: true,
                            filters: [
                              LibraryFilterChip(
                                label: l10n.allFilter,
                                selected:
                                    libraryScreen.filter == LibraryFilter.all,
                                onTap: () => ref
                                    .read(libraryScreenProvider.notifier)
                                    .setFilter(LibraryFilter.all),
                                icon: Icons.apps,
                              ),
                              LibraryFilterChip(
                                label: l10n.readingFilter,
                                selected:
                                    libraryScreen.filter ==
                                    LibraryFilter.reading,
                                onTap: () => ref
                                    .read(libraryScreenProvider.notifier)
                                    .setFilter(LibraryFilter.reading),
                                icon: Icons.menu_book,
                              ),
                              LibraryFilterChip(
                                label: l10n.completedFilter,
                                selected:
                                    libraryScreen.filter ==
                                    LibraryFilter.completed,
                                onTap: () => ref
                                    .read(libraryScreenProvider.notifier)
                                    .setFilter(LibraryFilter.completed),
                                icon: Icons.check_circle,
                              ),
                              LibraryFilterChip(
                                label: l10n.downloadedFilter,
                                selected:
                                    libraryScreen.filter ==
                                    LibraryFilter.downloaded,
                                onTap: () => ref
                                    .read(libraryScreenProvider.notifier)
                                    .setFilter(LibraryFilter.downloaded),
                                icon: Icons.download_done,
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.m),
                          Expanded(
                            child: novelsAsync.when(
                              data: (novels) {
                                final visible = filterNovels(
                                  novels,
                                  removedIds,
                                  downloadedIds,
                                  recentProgress,
                                  libraryScreen.searchQuery,
                                  libraryScreen.filter,
                                );
                                // Apply sort order
                                visible.sort((a, b) {
                                  switch (libraryScreen.sort) {
                                    case LibrarySort.titleAsc:
                                      return a.title.toLowerCase().compareTo(
                                        b.title.toLowerCase(),
                                      );
                                    case LibrarySort.authorAsc:
                                      final aAuth = (a.author ?? '')
                                          .toLowerCase();
                                      final bAuth = (b.author ?? '')
                                          .toLowerCase();
                                      return aAuth.compareTo(bAuth);
                                  }
                                });
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LibraryListHeader(
                                      visibleCount: visible.length,
                                      totalCount: novels.length,
                                      sortValue:
                                          libraryScreen.sort ==
                                              LibrarySort.titleAsc
                                          ? 'titleAsc'
                                          : 'authorAsc',
                                      onSortChanged: (v) {
                                        if (v == 'titleAsc') {
                                          ref
                                              .read(
                                                libraryScreenProvider.notifier,
                                              )
                                              .setSort(LibrarySort.titleAsc);
                                        } else if (v == 'authorAsc') {
                                          ref
                                              .read(
                                                libraryScreenProvider.notifier,
                                              )
                                              .setSort(LibrarySort.authorAsc);
                                        }
                                      },
                                      viewMode: libraryScreen.viewMode,
                                      onViewModeChanged: (mode) {
                                        ref
                                            .read(
                                              libraryScreenProvider.notifier,
                                            )
                                            .setViewMode(mode);
                                      },
                                    ),
                                    const SizedBox(height: Spacing.m),
                                    if (visible.isEmpty)
                                      Expanded(
                                        child: NovelEmptyState(
                                          title: l10n.noNovelsFound,
                                          subtitle:
                                              l10n.createFirstNovelSubtitle,
                                          actionLabel: l10n.createNovel,
                                          onAction: () =>
                                              context.pushNamed('createNovel'),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child:
                                            libraryScreen.viewMode ==
                                                LibraryViewMode.grid
                                            ? GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 200,
                                                      childAspectRatio: 0.6,
                                                      crossAxisSpacing:
                                                          Spacing.m,
                                                      mainAxisSpacing:
                                                          Spacing.m,
                                                    ),
                                                itemCount: visible.length,
                                                itemBuilder: (context, index) {
                                                  final novel = visible[index];
                                                  return LibraryGridItem(
                                                    novel: novel,
                                                    isSignedIn: isSignedIn,
                                                    canRemove: canRemove,
                                                    canDownload: canDownload,
                                                    onRemove: () => removeNovel(
                                                      context,
                                                      l10n,
                                                      novel,
                                                    ),
                                                  );
                                                },
                                              )
                                            : ListView.builder(
                                                key: const ValueKey(
                                                  'libraryListView',
                                                ),
                                                itemCount: visible.length,
                                                itemBuilder: (context, index) {
                                                  final novel = visible[index];
                                                  if (!isMobile) {
                                                    return LibraryItemRow(
                                                      novel: novel,
                                                      isSignedIn: isSignedIn,
                                                      canRemove: canRemove,
                                                      canDownload: canDownload,
                                                      onRemove: () {
                                                        showDeleteConfirmDialog(
                                                          context,
                                                          l10n,
                                                          novel,
                                                          () => removeNovel(
                                                            context,
                                                            l10n,
                                                            novel,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  return OpenContainer(
                                                    closedElevation: 0,
                                                    closedColor:
                                                        Colors.transparent,
                                                    transitionType:
                                                        ContainerTransitionType
                                                            .fadeThrough,
                                                    openBuilder: (context, _) {
                                                      return ReaderScreen(
                                                        novelId: novel.id,
                                                      );
                                                    },
                                                    closedBuilder:
                                                        (context, action) {
                                                          return MobileNovelCard(
                                                            novel: novel,
                                                            onTap: action,
                                                            onLongPress: () {
                                                              showDeleteConfirmDialog(
                                                                context,
                                                                l10n,
                                                                novel,
                                                                () =>
                                                                    removeNovel(
                                                                      context,
                                                                      l10n,
                                                                      novel,
                                                                    ),
                                                              );
                                                            },
                                                            onDownload:
                                                                canDownload
                                                                ? () {}
                                                                : null,
                                                            onDelete: () {
                                                              removeNovel(
                                                                context,
                                                                l10n,
                                                                novel,
                                                              );
                                                            },
                                                          );
                                                        },
                                                  );
                                                },
                                              ),
                                      ),
                                  ],
                                );
                              },
                              loading: () => const LibraryLoadingList(),
                              error: (err, st) {
                                // Suppress 401 errors as they are handled by the repository/service layer
                                // redirecting to login
                                if (err is ApiException &&
                                    err.statusCode == 401) {
                                  return const SizedBox.shrink();
                                }
                                return LibraryErrorSection(
                                  error: err,
                                  message: err.toString(),
                                  onRetry: () =>
                                      ref.refresh(libraryNovelsProvider),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: isMobile
            ? MobileFab(
                icon: Icons.add,
                label: l10n.createNovel,
                onPressed: () {
                  Navigator.of(context).pushNamed('/novel/create');
                },
              )
            : null,
        bottomNavigationBar: isMobile
            ? MobileBottomNavBar(
                currentTab: libraryScreen.currentTab,
                onTabChanged: (tab) {
                  ref.read(libraryScreenProvider.notifier).setCurrentTab(tab);
                },
              )
            : null,
      ),
    );
  }

  Widget buildMobileTabContent(MobileNavTab currentTab) {
    switch (currentTab) {
      case MobileNavTab.tools:
        return const Center(child: Text('Prompts'));
      case MobileNavTab.more:
        return const Center(child: Text('Settings'));
      default:
        return Center(child: Text(currentTab.name));
    }
  }

  PreferredSizeWidget buildMobileAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      title: Text(l10n.libraryTitle),
      actions: [
        const AiAssistantButton(),
        AppButtons.icon(
          iconData: Icons.more_vert,
          onPressed: () => showMoreMenu(context, l10n),
        ),
      ],
    );
  }

  void showMoreMenu(BuildContext context, AppLocalizations l10n) {
    MobileBottomSheet.showActionSheet(
      context: context,
      items: [
        ActionSheetItem(
          label: l10n.hotTopics,
          icon: Icons.local_fire_department,
          value: 'hot-topics',
          onPressed: () => context.pushNamed('hotTopics'),
        ),
        ActionSheetItem(
          label: l10n.settings,
          icon: Icons.settings,
          value: 'settings',
          onPressed: () => context.pushNamed('settings'),
        ),
        ActionSheetItem(
          label: l10n.about,
          icon: Icons.info_outline,
          value: 'about',
          onPressed: () => context.pushNamed('about'),
        ),
        ActionSheetItem(
          label: l10n.tools,
          icon: Icons.build,
          value: 'tools',
          onPressed: () => context.pushNamed('tools'),
        ),
      ],
    );
  }

  PreferredSizeWidget buildDesktopAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isSignedIn,
    bool isAdmin,
  ) {
    return AppBar(
      title: Text(l10n.libraryTitle),
      actions: [
        const SyncStatusIndicator(),
        const AiAssistantButton(),
        if (isSignedIn)
          AppButtons.icon(
            iconData: Icons.refresh,
            onPressed: () => ref.refresh(libraryNovelsProvider),
          ),
        if (isAdmin)
          AppButtons.icon(
            iconData: Icons.admin_panel_settings,
            onPressed: () => context.pushNamed('userManagement'),
          ),
        AppButtons.icon(
          iconData: Icons.settings,
          onPressed: () => context.pushNamed('settings'),
        ),
        AppButtons.icon(
          iconData: Icons.info_outline,
          onPressed: () => context.pushNamed('about'),
        ),
      ],
    );
  }

  void removeNovel(BuildContext context, AppLocalizations l10n, Novel novel) {
    // If signed in, delete remotely.
    if (ref.read(isSignedInProvider)) {
      ref.read(novelRepositoryProvider).deleteNovel(novel.id);
    }

    ref.read(removedNovelIdsProvider.notifier).update((s) => {...s, novel.id});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.removedNovel(novel.title)),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            ref
                .read(removedNovelIdsProvider.notifier)
                .update((s) => {...s}..remove(novel.id));
          },
        ),
      ),
    );
  }

  void showDeleteConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
    Novel novel,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.confirmDelete,
        content: Text(l10n.confirmDeleteDescription(novel.title)),
        actions: [
          AppButtons.text(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButtons.text(
            label: l10n.delete,
            color: Theme.of(context).colorScheme.error,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  String normalizeForSearch(String s) {
    // Remove extra spaces and convert to lowercase
    var normalized = s.toLowerCase().replaceAll(RegExp(r'\s+'), '').trim();

    // Handle diacritics by normalizing both search term and data
    // This allows searching for "café" to find "Café Novel"
    // and searching for "café" to find "Café Novel" (with accent on e)
    final Map<String, String> diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ø': 'o',
      'ù': 'u',
      'ú': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
    };

    for (final entry in diacriticsMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    return normalized;
  }
}
