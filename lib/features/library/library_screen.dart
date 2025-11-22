import 'package:flutter/material.dart';
import 'package:novel_reader/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../state/novel_providers.dart';
import '../../state/mock_providers.dart';
import '../../widgets/recent_chapters.dart';
import '../../state/providers.dart';
import 'library_providers.dart';
import 'widgets/session_section.dart';
import 'widgets/library_list_header.dart';
import 'widgets/library_search_bar.dart';
import 'widgets/library_loading_list.dart';
import 'widgets/library_error_section.dart';
import 'widgets/library_item_row.dart';

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

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late final TextEditingController _searchController;
  LibrarySort _sort = LibrarySort.titleAsc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSupabaseEnabled = ref.watch(supabaseEnabledProvider);
    final session = isSupabaseEnabled
        ? ref.watch(supabaseSessionProvider)
        : null;
    final novelsAsync = isSupabaseEnabled
        ? ref.watch(libraryNovelsProvider)
        : ref.watch(mockNovelsProvider);

    if (isSupabaseEnabled) {
      ref.listen(memberNovelsProvider, (prev, next) {
        if (next.hasError) {
          final msg = l10n.errorLoadingNovels;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$msg — showing cached/public data')),
            );
          }
        }
      });
    }

    final removedIds = ref.watch(removedNovelIdsProvider);
    // Remove is allowed offline (mock mode) for local hide/undo.
    // In Supabase mode, require a signed-in session to show Delete.
    final canRemove = isSupabaseEnabled ? (session != null) : true;
    final canDownload =
        isSupabaseEnabled ||
        ref.watch(downloadFeatureFlagProvider); // safe testing override
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.appTitle),
              const SizedBox(width: Spacing.xs),
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                isSupabaseEnabled ? l10n.modeSupabase : l10n.modeMockData,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          if (isSupabaseEnabled && session == null)
            IconButton(
              tooltip: l10n.signIn,
              icon: const Icon(Icons.login),
              onPressed: () => context.push('/auth'),
            ),
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                tooltip: l10n.reload,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (isSupabaseEnabled) {
                    ref.invalidate(novelsProvider);
                  } else {
                    ref.invalidate(mockNovelsProvider);
                  }
                },
              );
            },
          ),
          if (isSupabaseEnabled && session != null)
            IconButton(
              tooltip: l10n.createNovel,
              icon: const Icon(Icons.add),
              onPressed: () => context.pushNamed('createNovel'),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => context.push('/about'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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
            SessionSection(
              isSupabaseEnabled: isSupabaseEnabled,
              isSignedIn: session != null,
            ),
            if (isSupabaseEnabled && session != null) ...[
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
            LibrarySearchBar(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: Spacing.m),
            Expanded(
              child: novelsAsync.when(
                data: (novels) {
                  final query = _normalizeForSearch(
                    _searchController.text.trim(),
                  );
                  final filtered = query.isEmpty
                      ? [...novels]
                      : novels
                            .where(
                              (n) =>
                                  _normalizeForSearch(n.title).contains(query),
                            )
                            .toList();
                  // Apply local removals with undo support
                  final visible = filtered
                      .where((n) => !removedIds.contains(n.id))
                      .toList();
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
                      ),
                      if (visible.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  label: l10n.noNovelsFound,
                                  image: true,
                                  child: const Icon(
                                    Icons.menu_book_outlined,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: Spacing.s),
                                Text(l10n.noNovelsFound),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            key: const Key('libraryListView'),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final n = visible[index];
                              return LibraryItemRow(
                                novel: n,
                                isSupabaseEnabled: isSupabaseEnabled,
                                isSignedIn: session != null,
                                canRemove: canRemove,
                                canDownload: canDownload,
                              );
                            },
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
