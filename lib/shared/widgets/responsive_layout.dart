import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) =>
      getWidth(context) < Breakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      getWidth(context) >= Breakpoints.tablet &&
      getWidth(context) < Breakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      getWidth(context) >= Breakpoints.desktop;

  static bool isTabletOrWider(BuildContext context) =>
      getWidth(context) >= Breakpoints.tablet;

  static bool isDesktopOrWider(BuildContext context) =>
      getWidth(context) >= Breakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop && desktop != null) return desktop!;
    if (width >= Breakpoints.tablet && tablet != null) return tablet!;
    if (width < Breakpoints.tablet && mobile != null) return mobile!;
    return child;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return builder(
          context,
          width < Breakpoints.tablet,
          width >= Breakpoints.tablet && width < Breakpoints.desktop,
          width >= Breakpoints.desktop,
        );
      },
    );
  }
}

class MobileSwitch extends StatelessWidget {
  const MobileSwitch({super.key, required this.mobile, required this.desktop});

  final Widget mobile;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, _, _) => isMobile ? mobile : desktop,
    );
  }
}

class SidebarWidth {
  static const double appDrawer = 260;
  static const double sideBar = 260;
}
