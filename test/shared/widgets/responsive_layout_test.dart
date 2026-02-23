import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/responsive_layout.dart';

void main() {
  group('Responsive static methods', () {
    testWidgets('getWidth returns MediaQuery width', (tester) async {
      late double actualWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                actualWidth = Responsive.getWidth(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(actualWidth, 800.0);
    });

    testWidgets('isMobile returns true for mobile width', (tester) async {
      late bool isMobile;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(300, 800)),
            child: Builder(
              builder: (context) {
                isMobile = Responsive.isMobile(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isMobile, true);
    });

    testWidgets('isMobile returns false for tablet width', (tester) async {
      late bool isMobile;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                isMobile = Responsive.isMobile(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isMobile, false);
    });

    testWidgets('isTablet returns true for tablet width', (tester) async {
      late bool isTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                isTablet = Responsive.isTablet(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isTablet, true);
    });

    testWidgets('isTablet returns false for mobile width', (tester) async {
      late bool isTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(300, 800)),
            child: Builder(
              builder: (context) {
                isTablet = Responsive.isTablet(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isTablet, false);
    });

    testWidgets('isTablet returns false for desktop width', (tester) async {
      late bool isTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 800)),
            child: Builder(
              builder: (context) {
                isTablet = Responsive.isTablet(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isTablet, false);
    });

    testWidgets('isDesktop returns true for desktop width', (tester) async {
      late bool isDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 800)),
            child: Builder(
              builder: (context) {
                isDesktop = Responsive.isDesktop(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isDesktop, true);
    });

    testWidgets('isDesktop returns false for tablet width', (tester) async {
      late bool isDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                isDesktop = Responsive.isDesktop(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isDesktop, false);
    });

    testWidgets('isTabletOrWider returns true for tablet', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                result = Responsive.isTabletOrWider(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('isTabletOrWider returns true for desktop', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 800)),
            child: Builder(
              builder: (context) {
                result = Responsive.isTabletOrWider(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('isTabletOrWider returns false for mobile', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(300, 800)),
            child: Builder(
              builder: (context) {
                result = Responsive.isTabletOrWider(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, false);
    });

    testWidgets('isDesktopOrWider returns true for desktop', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 800)),
            child: Builder(
              builder: (context) {
                result = Responsive.isDesktopOrWider(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('isDesktopOrWider returns false for tablet', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                result = Responsive.isDesktopOrWider(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, false);
    });
  });

  group('Responsive widget', () {
    testWidgets('returns child when no breakpoint widgets provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(700, 800)),
            child: Responsive(child: Text('default')),
          ),
        ),
      );

      expect(find.text('default'), findsOneWidget);
    });

    testWidgets('returns mobile widget on mobile width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(300, 800)),
            child: Responsive(mobile: Text('mobile'), child: Text('default')),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('default'), findsNothing);
    });

    testWidgets('returns tablet widget on tablet width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(700, 800)),
            child: Responsive(tablet: Text('tablet'), child: Text('default')),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('default'), findsNothing);
    });

    testWidgets('returns desktop widget on desktop width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(900, 800)),
            child: Responsive(desktop: Text('desktop'), child: Text('default')),
          ),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('default'), findsNothing);
    });

    testWidgets('desktop takes precedence over tablet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(900, 800)),
            child: Responsive(
              tablet: Text('tablet'),
              desktop: Text('desktop'),
              child: Text('default'),
            ),
          ),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('tablet takes precedence over mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(700, 800)),
            child: Responsive(
              mobile: Text('mobile'),
              tablet: Text('tablet'),
              child: Text('default'),
            ),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('calls builder with correct breakpoints', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late bool capturedIsMobile;
      late bool capturedIsTablet;
      late bool capturedIsDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, isMobile, isTablet, isDesktop) {
              capturedIsMobile = isMobile;
              capturedIsTablet = isTablet;
              capturedIsDesktop = isDesktop;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedIsMobile, false);
      expect(capturedIsTablet, true);
      expect(capturedIsDesktop, false);
    });

    testWidgets('detects mobile correctly', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, isMobile, _, _) {
              return Text(isMobile ? 'mobile' : 'not-mobile');
            },
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('detects desktop correctly', (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, _, _, isDesktop) {
              return Text(isDesktop ? 'desktop' : 'not-desktop');
            },
          ),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('uses LayoutBuilder constraints', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, isMobile, _, _) {
              return Text(isMobile ? 'mobile-400' : 'desktop-400');
            },
          ),
        ),
      );

      expect(find.text('mobile-400'), findsOneWidget);
    });
  });

  group('MobileSwitch', () {
    testWidgets('shows mobile widget on mobile', (tester) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileSwitch(mobile: Text('mobile'), desktop: Text('desktop')),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('desktop'), findsNothing);
    });

    testWidgets('shows desktop widget on desktop', (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileSwitch(mobile: Text('mobile'), desktop: Text('desktop')),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('shows desktop widget on tablet', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileSwitch(mobile: Text('mobile'), desktop: Text('desktop')),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });
  });

  group('SidebarWidth', () {
    test('appDrawer is 260', () {
      expect(SidebarWidth.appDrawer, 260);
    });

    test('sideBar is 260', () {
      expect(SidebarWidth.sideBar, 260);
    });
  });
}
