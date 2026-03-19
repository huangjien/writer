import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts_dialog.dart';
import 'package:writer/shared/widgets/quick_search_modal.dart';
import 'package:go_router/go_router.dart';

/// Global shortcuts wrapper that provides app-wide keyboard shortcuts
/// Wrap your root widget or individual screens with this widget
class GlobalShortcutsWrapper extends ConsumerWidget {
  const GlobalShortcutsWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: getGlobalShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          // Home navigation
          NavigateHomeIntent: CallbackAction<NavigateHomeIntent>(
            onInvoke: (_) {
              try {
                context.go('/');
              } catch (_) {
                // Fallback to Navigator if GoRouter not available
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              return null;
            },
          ),
          // Settings
          NavigateSettingsIntent: CallbackAction<NavigateSettingsIntent>(
            onInvoke: (_) {
              try {
                context.push('/settings');
              } catch (_) {
                Navigator.of(context).pushNamed('settings');
              }
              return null;
            },
          ),
          // Help
          ShowShortcutsHelpIntent: CallbackAction<ShowShortcutsHelpIntent>(
            onInvoke: (_) {
              showKeyboardShortcutsDialog(context);
              return null;
            },
          ),
          // Quick search
          QuickSearchIntent: CallbackAction<QuickSearchIntent>(
            onInvoke: (_) {
              showQuickSearchModal(context);
              return null;
            },
          ),
          // Close
          CloseIntent: CallbackAction<CloseIntent>(
            onInvoke: (_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return null;
            },
          ),
          // Back/Forward navigation
          NavigateBackIntent: CallbackAction<NavigateBackIntent>(
            onInvoke: (_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return null;
            },
          ),
          NavigateForwardIntent: CallbackAction<NavigateForwardIntent>(
            onInvoke: (_) {
              // Forward navigation is only available on web platforms
              // using browser history API. On mobile, this has no effect.
              if (kIsWeb) {
                // GoRouter does not provide a forward navigation method
                // This would require implementing custom history tracking
                // For now, this is a no-op on all platforms
              }
              return null;
            },
          ),
          // Force refresh
          ForceRefreshIntent: CallbackAction<ForceRefreshIntent>(
            onInvoke: (_) {
              try {
                final router = GoRouter.of(context);
                final currentLocation =
                    router.routeInformationProvider.value.uri;
                // Navigate to the same location to trigger a rebuild
                router.go(currentLocation.toString());
              } catch (_) {
                // Fallback: trigger a rebuild by accessing the current state
                GoRouterState.of(context);
              }
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Library shortcuts wrapper
class LibraryShortcutsWrapper extends ConsumerWidget {
  const LibraryShortcutsWrapper({
    super.key,
    required this.onCreateNovel,
    required this.onFocusSearch,
    required this.onDeleteNovel,
    required this.child,
  });

  final VoidCallback onCreateNovel;
  final VoidCallback onFocusSearch;
  final VoidCallback onDeleteNovel;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: getLibraryShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          CreateNovelIntent: CallbackAction<CreateNovelIntent>(
            onInvoke: (_) {
              onCreateNovel();
              return null;
            },
          ),
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (_) {
              onFocusSearch();
              return null;
            },
          ),
          DeleteNovelIntent: CallbackAction<DeleteNovelIntent>(
            onInvoke: (_) {
              onDeleteNovel();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Chapter list shortcuts wrapper
class ChapterListShortcutsWrapper extends ConsumerWidget {
  const ChapterListShortcutsWrapper({
    super.key,
    required this.onCreateChapter,
    required this.onRefreshChapters,
    required this.onDuplicateChapter,
    required this.onDeleteChapter,
    required this.child,
  });

  final VoidCallback onCreateChapter;
  final VoidCallback onRefreshChapters;
  final VoidCallback onDuplicateChapter;
  final VoidCallback onDeleteChapter;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: getChapterListShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          CreateChapterIntent: CallbackAction<CreateChapterIntent>(
            onInvoke: (_) {
              onCreateChapter();
              return null;
            },
          ),
          RefreshChaptersIntent: CallbackAction<RefreshChaptersIntent>(
            onInvoke: (_) {
              onRefreshChapters();
              return null;
            },
          ),
          DuplicateChapterIntent: CallbackAction<DuplicateChapterIntent>(
            onInvoke: (_) {
              onDuplicateChapter();
              return null;
            },
          ),
          DeleteChapterIntent: CallbackAction<DeleteChapterIntent>(
            onInvoke: (_) {
              onDeleteChapter();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Sidebar shortcuts wrapper
class SidebarShortcutsWrapper extends ConsumerWidget {
  const SidebarShortcutsWrapper({
    super.key,
    required this.onToggleSidebar,
    required this.onToggleAiSidebar,
    required this.onNavigateToChapters,
    required this.onNavigateToCharacters,
    required this.onNavigateToScenes,
    required this.onNavigateToSummaries,
    required this.onNavigateToSettings,
    required this.child,
  });

  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleAiSidebar;
  final VoidCallback onNavigateToChapters;
  final VoidCallback onNavigateToCharacters;
  final VoidCallback onNavigateToScenes;
  final VoidCallback onNavigateToSummaries;
  final VoidCallback onNavigateToSettings;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: getSidebarShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          ToggleSidebarIntent: CallbackAction<ToggleSidebarIntent>(
            onInvoke: (_) {
              onToggleSidebar();
              return null;
            },
          ),
          ToggleAiSidebarIntent: CallbackAction<ToggleAiSidebarIntent>(
            onInvoke: (_) {
              onToggleAiSidebar();
              return null;
            },
          ),
          NavigateToChaptersIntent: CallbackAction<NavigateToChaptersIntent>(
            onInvoke: (_) {
              onNavigateToChapters();
              return null;
            },
          ),
          NavigateToCharactersIntent:
              CallbackAction<NavigateToCharactersIntent>(
                onInvoke: (_) {
                  onNavigateToCharacters();
                  return null;
                },
              ),
          NavigateToScenesIntent: CallbackAction<NavigateToScenesIntent>(
            onInvoke: (_) {
              onNavigateToScenes();
              return null;
            },
          ),
          NavigateToSummariesIntent: CallbackAction<NavigateToSummariesIntent>(
            onInvoke: (_) {
              onNavigateToSummaries();
              return null;
            },
          ),
          NavigateSettingsIntent: CallbackAction<NavigateSettingsIntent>(
            onInvoke: (_) {
              onNavigateToSettings();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Settings shortcuts wrapper
class SettingsShortcutsWrapper extends ConsumerWidget {
  const SettingsShortcutsWrapper({
    super.key,
    required this.onFocusAppSettings,
    required this.onFocusColorTheme,
    required this.onFocusTypography,
    required this.onFocusPerformance,
    required this.onFocusTTSSettings,
    required this.child,
  });

  final VoidCallback onFocusAppSettings;
  final VoidCallback onFocusColorTheme;
  final VoidCallback onFocusTypography;
  final VoidCallback onFocusPerformance;
  final VoidCallback onFocusTTSSettings;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: getSettingsShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          FocusAppSettingsIntent: CallbackAction<FocusAppSettingsIntent>(
            onInvoke: (_) {
              onFocusAppSettings();
              return null;
            },
          ),
          FocusColorThemeIntent: CallbackAction<FocusColorThemeIntent>(
            onInvoke: (_) {
              onFocusColorTheme();
              return null;
            },
          ),
          FocusTypographyIntent: CallbackAction<FocusTypographyIntent>(
            onInvoke: (_) {
              onFocusTypography();
              return null;
            },
          ),
          FocusPerformanceIntent: CallbackAction<FocusPerformanceIntent>(
            onInvoke: (_) {
              onFocusPerformance();
              return null;
            },
          ),
          FocusTTSSettingsIntent: CallbackAction<FocusTTSSettingsIntent>(
            onInvoke: (_) {
              onFocusTTSSettings();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
