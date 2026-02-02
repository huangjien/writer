import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:go_router/go_router.dart';
import '../../state/novel_providers.dart';

/// Quick Search Modal - Global search dialog for rapid navigation
/// Activated by ⌘/Ctrl + K shortcut
class QuickSearchModal extends ConsumerStatefulWidget {
  const QuickSearchModal({super.key});

  @override
  ConsumerState<QuickSearchModal> createState() => _QuickSearchModalState();
}

class _QuickSearchModalState extends ConsumerState<QuickSearchModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SearchResult> _results = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _selectedIndex = 0;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Search novels
    try {
      final novels = await ref.read(novelsProvider.future);
      final novelResults = novels
          .where(
            (n) =>
                n.title.toLowerCase().contains(query.toLowerCase()) ||
                (n.author ?? '').toLowerCase().contains(query.toLowerCase()),
          )
          .map(
            (n) => SearchResult(
              type: SearchResultType.novel,
              id: n.id,
              title: n.title,
              subtitle: n.author ?? '',
              route: '/novel/${n.id}/chapters',
            ),
          )
          .toList();

      // Search chapters (if possible - this would require more complex logic)
      // For now, just novels and settings
      setState(() {
        _results = novelResults;
        _isLoading = false;
        _selectedIndex = 0;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResult(SearchResult result) {
    Navigator.of(context).pop();
    try {
      context.push(result.route);
    } catch (_) {
      // Fallback for older navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(Spacing.l),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.onSurface),
                  const SizedBox(width: Spacing.m),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l10n.searchLabel,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      onChanged: (_) => _performSearch(),
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(Spacing.s),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.close,
                  ),
                ],
              ),
            ),
            // Results
            Flexible(
              child: _results.isEmpty && !_isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: Spacing.m),
                            Text(
                              l10n.noNovelsFound,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        final isSelected = index == _selectedIndex;
                        return Shortcuts(
                          shortcuts: <ShortcutActivator, Intent>{
                            const SingleActivator(LogicalKeyboardKey.escape):
                                const CloseIntent(),
                            const SingleActivator(LogicalKeyboardKey.enter):
                                const NavigateResultIntent(),
                            const SingleActivator(LogicalKeyboardKey.arrowDown):
                                const NextResultIntent(),
                            const SingleActivator(LogicalKeyboardKey.arrowUp):
                                const PrevResultIntent(),
                          },
                          child: Actions(
                            actions: <Type, Action<Intent>>{
                              CloseIntent: CallbackAction<CloseIntent>(
                                onInvoke: (_) {
                                  Navigator.of(context).pop();
                                  return null;
                                },
                              ),
                              NavigateResultIntent:
                                  CallbackAction<NavigateResultIntent>(
                                    onInvoke: (_) {
                                      _navigateToResult(result);
                                      return null;
                                    },
                                  ),
                              NextResultIntent:
                                  CallbackAction<NextResultIntent>(
                                    onInvoke: (_) {
                                      setState(() {
                                        _selectedIndex =
                                            (_selectedIndex + 1) %
                                            _results.length;
                                      });
                                      return null;
                                    },
                                  ),
                              PrevResultIntent:
                                  CallbackAction<PrevResultIntent>(
                                    onInvoke: (_) {
                                      setState(() {
                                        _selectedIndex =
                                            (_selectedIndex -
                                                1 +
                                                _results.length) %
                                            _results.length;
                                      });
                                      return null;
                                    },
                                  ),
                            },
                            child: InkWell(
                              onTap: () => _navigateToResult(result),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primaryContainer
                                      : Colors.transparent,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.l,
                                  vertical: Spacing.m,
                                ),
                                child: Row(
                                  children: [
                                    _ResultIcon(result.type),
                                    const SizedBox(width: Spacing.m),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            result.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (result.subtitle != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              result.subtitle!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    _ResultTypeChip(result.type, l10n),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon(this.type);
  final SearchResultType type;

  @override
  Widget build(BuildContext context) {
    return Icon(
      type == SearchResultType.novel ? Icons.book : Icons.settings,
      size: 20,
    );
  }
}

class _ResultTypeChip extends StatelessWidget {
  const _ResultTypeChip(this.type, this.l10n);
  final SearchResultType type;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label = type == SearchResultType.novel ? 'Novel' : 'Settings';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.route,
    this.subtitle,
  });

  final SearchResultType type;
  final String id;
  final String title;
  final String route;
  final String? subtitle;
}

enum SearchResultType { novel, setting }

// Intents for quick search navigation
class NavigateResultIntent extends Intent {
  const NavigateResultIntent();
}

class NextResultIntent extends Intent {
  const NextResultIntent();
}

class PrevResultIntent extends Intent {
  const PrevResultIntent();
}

/// Show quick search modal
void showQuickSearchModal(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => const QuickSearchModal(),
  );
}
