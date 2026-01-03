import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/widgets/library_list_header.dart';
import 'package:writer/features/library/widgets/library_grid_item.dart';
import 'package:writer/features/library/widgets/library_item_row.dart';
import 'package:writer/features/library/widgets/library_loading_list.dart';
import 'package:writer/features/library/widgets/library_error_section.dart';
import 'package:writer/features/library/widgets/session_section.dart';
import 'package:writer/features/library/widgets/enhanced_search_bar.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/state/novel_providers.dart';
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
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';
import 'package:writer/shared/widgets/mobile_fab.dart';
import 'package:writer/shared/widgets/mobile_novel_card.dart';

enum LibrarySort { titleAsc, authorAsc }

enum LibraryFilter { all, reading, completed, downloaded }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibrarySort _sort = LibrarySort.titleAsc;
  LibraryViewMode _viewMode = LibraryViewMode.list;
  LibraryFilter _filter = LibraryFilter.all;
  String _searchQuery = '';
  MobileNavTab _currentTab = MobileNavTab.home;

  List<Novel> _filterNovels(
    List<Novel> novels,
    Set<String> removedIds,
    Set<String> downloadedIds,
    List<UserProgress> recentProgress,
  ) {
    final query = _normalizeForSearch(_searchQuery.trim());
    var filtered = query.isEmpty
        ? [...novels]
        : novels
              .where((n) => _normalizeForSearch(n.title).contains(query))
              .toList();

    // Apply filter chips
    switch (_filter) {
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
    final novelsAsync = ref.watch(libraryNovelsProvider);

    // Watch providers for filtering
    final downloadedIdsAsync = ref.watch(downloadedNovelIdsProvider);
    final recentProgressAsync = ref.watch(recentUserProgressProvider);

    final downloadedIds = downloadedIdsAsync.asData?.value ?? {};
    final recentProgress = recentProgressAsync.asData?.value ?? [];

    ref.listen(memberNovelsProvider, (prev, next) {
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

    return Scaffold(
      appBar: isMobile
          ? _buildMobileAppBar(context, l10n)
          : _buildDesktopAppBar(context, l10n, isSignedIn, isAdmin),
      drawer: isMobile ? null : const AppDrawer(),
      body: isMobile && _currentTab != MobileNavTab.home
          ? _buildMobileTabContent()
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
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          hintText: l10n.searchNovels,
                          onClear: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          showFilters: true,
                          filters: [
                            LibraryFilterChip(
                              label: l10n.allFilter,
                              selected: _filter == LibraryFilter.all,
                              onTap: () =>
                                  setState(() => _filter = LibraryFilter.all),
                              icon: Icons.apps,
                            ),
                            LibraryFilterChip(
                              label: l10n.readingFilter,
                              selected: _filter == LibraryFilter.reading,
                              onTap: () => setState(
                                () => _filter = LibraryFilter.reading,
                              ),
                              icon: Icons.menu_book,
                            ),
                            LibraryFilterChip(
                              label: l10n.completedFilter,
                              selected: _filter == LibraryFilter.completed,
                              onTap: () => setState(
                                () => _filter = LibraryFilter.completed,
                              ),
                              icon: Icons.check_circle,
                            ),
                            LibraryFilterChip(
                              label: l10n.downloadedFilter,
                              selected: _filter == LibraryFilter.downloaded,
                              onTap: () => setState(
                                () => _filter = LibraryFilter.downloaded,
                              ),
                              icon: Icons.download_done,
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.m),
                        Expanded(
                          child: novelsAsync.when(
                            data: (novels) {
                              final visible = _filterNovels(
                                novels,
                                removedIds,
                                downloadedIds,
                                recentProgress,
                              );
                              // Apply sort order
                              visible.sort((a, b) {
                                switch (_sort) {
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
                                    sortValue: _sort == LibrarySort.titleAsc
                                        ? 'titleAsc'
                                        : 'authorAsc',
                                    onSortChanged: (v) {
                                      if (v == 'titleAsc') {
                                        setState(
                                          () => _sort = LibrarySort.titleAsc,
                                        );
                                      } else if (v == 'authorAsc') {
                                        setState(
                                          () => _sort = LibrarySort.authorAsc,
                                        );
                                      }
                                    },
                                    viewMode: _viewMode,
                                    onViewModeChanged: (mode) {
                                      setState(() => _viewMode = mode);
                                    },
                                  ),
                                  const SizedBox(height: Spacing.m),
                                  if (visible.isEmpty)
                                    Expanded(
                                      child: Center(
                                        child: Text(l10n.noNovelsFound),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: _viewMode == LibraryViewMode.grid
                                          ? GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 200,
                                                    childAspectRatio: 0.6,
                                                    crossAxisSpacing: Spacing.m,
                                                    mainAxisSpacing: Spacing.m,
                                                  ),
                                              itemCount: visible.length,
                                              itemBuilder: (context, index) {
                                                final novel = visible[index];
                                                return LibraryGridItem(
                                                  novel: novel,
                                                  isSignedIn: isSignedIn,
                                                  canRemove: canRemove,
                                                  canDownload: canDownload,
                                                  onRemove: () => _removeNovel(
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
                                                      _showDeleteConfirmDialog(
                                                        context,
                                                        l10n,
                                                        novel,
                                                        () => _removeNovel(
                                                          context,
                                                          l10n,
                                                          novel,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                                return MobileNovelCard(
                                                  novel: novel,
                                                  onTap: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pushNamed(
                                                      '/novel/${novel.id}',
                                                    );
                                                  },
                                                  onLongPress: () {
                                                    // Show delete confirmation dialog
                                                    _showDeleteConfirmDialog(
                                                      context,
                                                      l10n,
                                                      novel,
                                                      () => _removeNovel(
                                                        context,
                                                        l10n,
                                                        novel,
                                                      ),
                                                    );
                                                  },
                                                  onDownload: canDownload
                                                      ? () {
                                                          // Handle download
                                                        }
                                                      : null,
                                                  onDelete: () {
                                                    // Mobile delete immediately without confirmation to support swipe-to-delete pattern
                                                    _removeNovel(
                                                      context,
                                                      l10n,
                                                      novel,
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
                            error: (err, st) => LibraryErrorSection(
                              error: err,
                              message: err.toString(),
                              onRetry: () => ref.refresh(libraryNovelsProvider),
                            ),
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
              currentTab: _currentTab,
              onTabChanged: (tab) {
                setState(() {
                  _currentTab = tab;
                });
              },
            )
          : null,
    );
  }

  Widget _buildMobileTabContent() {
    switch (_currentTab) {
      case MobileNavTab.tools:
        return const Center(child: Text('Prompts'));
      case MobileNavTab.more:
        return const Center(child: Text('Settings'));
      default:
        return Center(child: Text(_currentTab.name));
    }
  }

  PreferredSizeWidget _buildMobileAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      title: Text(l10n.libraryTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreMenu(context, l10n),
        ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.about),
              onTap: () => _showAboutDialog(context, l10n),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: Text(l10n.tools),
              onTap: () {
                Navigator.of(context).pushNamed('/tools');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Text('Author Console Writer v1.0.0'),
        actions: [
          TextButton(
            child: Text(l10n.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isSignedIn,
    bool isAdmin,
  ) {
    return AppBar(
      title: Text(l10n.libraryTitle),
      actions: [
        if (isSignedIn)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(libraryNovelsProvider),
          ),
        SyncStatusIndicator(),
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/admin'),
          ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showAboutDialog(context, l10n),
        ),
      ],
    );
  }

  void _removeNovel(BuildContext context, AppLocalizations l10n, Novel novel) {
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

  void _showDeleteConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
    Novel novel,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteDescription(novel.title)),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(l10n.delete),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  String _normalizeForSearch(String s) {
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
