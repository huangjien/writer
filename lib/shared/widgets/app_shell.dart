import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/shared/widgets/responsive_layout.dart';
import 'package:writer/widgets/app_drawer.dart';
import 'package:writer/widgets/side_bar.dart';

enum AppShellType { none, appDrawer, novel }

final appDrawerExpandedProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    this.shellType = AppShellType.appDrawer,
    this.novelId,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  final Widget child;
  final AppShellType shellType;
  final String? novelId;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      builder: (context, isMobile, _, _) {
        final effectiveDrawer =
            drawer ??
            (isMobile
                ? null
                : switch (shellType) {
                    AppShellType.appDrawer => const AppDrawer(),
                    AppShellType.novel =>
                      novelId != null ? SideBar(novelId: novelId!) : null,
                    AppShellType.none => null,
                  });

        final bool showSidebar = effectiveDrawer != null && !isMobile;
        final bool isExpanded = showSidebar
            ? ref.watch(appDrawerExpandedProvider)
            : false;

        return Scaffold(
          appBar: isMobile
              ? appBar
              : (showSidebar
                    ? _buildDesktopAppBarWithToggle(
                        context,
                        ref,
                        appBar,
                        isExpanded,
                      )
                    : null),
          drawer: effectiveDrawer,
          body: isMobile
              ? child
              : Row(
                  children: [
                    if (showSidebar)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isExpanded ? SidebarWidth.appDrawer : 0,
                        child: isExpanded
                            ? effectiveDrawer
                            : const SizedBox.shrink(),
                      ),
                    Expanded(child: child),
                  ],
                ),
          floatingActionButton: isMobile ? floatingActionButton : null,
          bottomNavigationBar: isMobile ? bottomNavigationBar : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildDesktopAppBarWithToggle(
    BuildContext context,
    WidgetRef ref,
    PreferredSizeWidget? existingAppBar,
    bool isExpanded,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Material(
        elevation: 1,
        child: Row(
          children: [
            IconButton(
              icon: Icon(isExpanded ? Icons.menu_open : Icons.menu),
              onPressed: () {
                ref.read(appDrawerExpandedProvider.notifier).state =
                    !isExpanded;
              },
              tooltip: isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
            ),
            if (existingAppBar != null)
              Expanded(
                child: SizedBox(height: kToolbarHeight, child: existingAppBar),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
