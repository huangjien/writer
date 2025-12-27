import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animations/animations.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/motion_settings.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../state/novel_providers.dart';
import '../../widgets/recent_chapters.dart';
import '../../widgets/app_drawer.dart';
import '../../state/providers.dart';
import 'library_providers.dart';
import 'widgets/session_section.dart';
import 'widgets/library_list_header.dart';
import 'widgets/library_loading_list.dart';
import 'widgets/library_error_section.dart';
import 'widgets/library_item_row.dart';
import 'widgets/library_grid_item.dart';
import 'widgets/enhanced_search_bar.dart';
import '../../shared/widgets/empty_state.dart';

// Basic diacritics normalization for case-insensitive, accent-insensitive matching.
String _normalizeForSearch(String input) {
  const map = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'Á': 'A',
    'À': 'A',
    'Ä': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Å': 'A',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'É': 'E',
    'È': 'E',
    'Ë': 'E',
    'Ê': 'E',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'Í': 'I',
    'Ì': 'I',
    'Ï': 'I',
    'Î': 'I',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'Ó': 'O',
    'Ò': 'O',
    'Ö': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'Ú': 'U',
    'Ù': 'U',
    'Ü': 'U',
    'Û': 'U',
    'ñ': 'n',
    'Ñ': 'N',
    'ç': 'c',
    'Ç': 'C',
    'ý': 'y',
    'ÿ': 'y',
    'Ý': 'Y',
  };
  final sb = StringBuffer();
  for (final ch in input.characters) {
    sb.write(map[ch] ?? ch);
  }
  return sb.toString().toLowerCase();
}

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

  List<dynamic> _filterNovels(List<dynamic> novels, Set<String> removedIds) {
    final query = _normalizeForSearch(_searchQuery.trim());
    var filtered = query.isEmpty
        ? [...novels]
        : novels
              .where((n) => _normalizeForSearch(n.title).contains(query))
              .toList();

    // Apply filter chips
    switch (_filter) {
      case LibraryFilter.reading:
        filtered = filtered.where((n) {
          final progress = n.currentChapterIndex ?? 0;
          final totalChapters = n.chapterCount ?? 0;
          return progress > 0 && progress < totalChapters;
        }).toList();
        break;
      case LibraryFilter.completed:
        filtered = filtered.where((n) {
          final progress = n.currentChapterIndex ?? 0;
          final totalChapters = n.chapterCount ?? 0;
          return progress >= totalChapters && totalChapters > 0;
        }).toList();
        break;
      case LibraryFilter.downloaded:
        filtered = filtered.where((n) => n.isDownloaded == true).toList();
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
    final novelsAsync = ref.watch(libraryNovelsProvider);
    final motion = ref.watch(motionSettingsProvider);

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
    final canDownload = true; // safe testing override

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: kIsWeb
                      ? Image.network(
                          '/icons/Icon-192.png',
                          height: 40,
                          key: const ValueKey('home_logo'),
                          errorBuilder: (context, error, stack) => Text(
                            'Unable to load asset: "assetmanifest.bin.json"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        )
                      : Image.asset(
                          'web/icons/Icon-192.png',
                          height: 40,
                          key: const ValueKey('home_logo'),
                          errorBuilder: (context, error, stack) => Text(
                            'Unable to load asset: "assetmanifest.bin.json"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: Spacing.xs),
            ],
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                tooltip: l10n.reload,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(libraryNovelsProvider);
                  ref.invalidate(memberNovelsProvider);
                },
              );
            },
          ),
          if (isSignedIn)
            IconButton(
              tooltip: l10n.createNovel,
              icon: const Icon(Icons.add),
              onPressed: () => context.pushNamed('createNovel'),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.about,
            onPressed: () => context.push('/about'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
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
              hintText: 'Search novels...',
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              showFilters: true,
              filters: [
                LibraryFilterChip(
                  label: 'All',
                  selected: _filter == LibraryFilter.all,
                  onTap: () => setState(() => _filter = LibraryFilter.all),
                  icon: Icons.apps,
                ),
                LibraryFilterChip(
                  label: 'Reading',
                  selected: _filter == LibraryFilter.reading,
                  onTap: () => setState(() => _filter = LibraryFilter.reading),
                  icon: Icons.menu_book,
                ),
                LibraryFilterChip(
                  label: 'Completed',
                  selected: _filter == LibraryFilter.completed,
                  onTap: () =>
                      setState(() => _filter = LibraryFilter.completed),
                  icon: Icons.check_circle,
                ),
                LibraryFilterChip(
                  label: 'Downloaded',
                  selected: _filter == LibraryFilter.downloaded,
                  onTap: () =>
                      setState(() => _filter = LibraryFilter.downloaded),
                  icon: Icons.download_done,
                ),
              ],
            ),
            const SizedBox(height: Spacing.m),
            Expanded(
              child: novelsAsync.when(
                data: (novels) {
                  final visible = _filterNovels(novels, removedIds);
                  // Apply sort order
                  visible.sort((a, b) {
                    switch (_sort) {
                      case LibrarySort.titleAsc:
                        return a.title.toLowerCase().compareTo(
                          b.title.toLowerCase(),
                        );
                      case LibrarySort.authorAsc:
                        final aAuth = (a.author ?? '').toLowerCase();
                        final bAuth = (b.author ?? '').toLowerCase();
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
                            setState(() => _sort = LibrarySort.titleAsc);
                          } else if (v == 'authorAsc') {
                            setState(() => _sort = LibrarySort.authorAsc);
                          }
                        },
                        viewMode: _viewMode,
                        onViewModeChanged: (mode) {
                          setState(() => _viewMode = mode);
                        },
                      ),
                      if (visible.isEmpty)
                        Expanded(
                          child: EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: l10n.noNovelsFound,
                            subtitle:
                                'Try adjusting your search or create a new novel',
                            actionLabel: 'Create Novel',
                            onAction: () => context.pushNamed('createNovel'),
                          ),
                        )
                      else
                        Expanded(
                          child: PageTransitionSwitcher(
                            duration: Duration(
                              milliseconds: motion.reduceMotion ? 0 : 300,
                            ),
                            transitionBuilder:
                                (
                                  Widget child,
                                  Animation<double> primaryAnimation,
                                  Animation<double> secondaryAnimation,
                                ) {
                                  return FadeThroughTransition(
                                    animation: primaryAnimation,
                                    secondaryAnimation: secondaryAnimation,
                                    child: child,
                                  );
                                },
                            child: _viewMode == LibraryViewMode.list
                                ? ListView.separated(
                                    key: const Key('libraryListView'),
                                    itemCount: visible.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final n = visible[index];
                                      return LibraryItemRow(
                                        novel: n,
                                        isSignedIn: isSignedIn,
                                        canRemove: canRemove,
                                        canDownload: canDownload,
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    key: const Key('libraryGridView'),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.7,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: visible.length,
                                    itemBuilder: (context, index) {
                                      final n = visible[index];
                                      return LibraryGridItem(
                                        novel: n,
                                        isSignedIn: isSignedIn,
                                        canRemove: canRemove,
                                        canDownload: canDownload,
                                      );
                                    },
                                  ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => LibraryLoadingList(),
                error: (e, _) => LibraryErrorSection(error: e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
