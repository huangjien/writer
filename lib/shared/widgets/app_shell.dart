import 'package:flutter/material.dart';
import 'package:writer/shared/widgets/responsive_layout.dart';
import 'package:writer/widgets/app_drawer.dart';
import 'package:writer/widgets/side_bar.dart';

enum AppShellType { none, appDrawer, novel }

class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

        return Scaffold(
          appBar: isMobile ? appBar : null,
          drawer: effectiveDrawer,
          body: isMobile
              ? child
              : Row(
                  children: [
                    if (effectiveDrawer != null)
                      SizedBox(
                        width: SidebarWidth.appDrawer,
                        child: effectiveDrawer,
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
}
