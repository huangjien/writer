import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:writer/shared/widgets/theme_aware_card.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/theme/ui_styles.dart';

import '../../helpers/test_utils.dart';

ThemeData _theme({
  required Brightness brightness,
  required UiStyleFamily styleFamily,
  bool useBackdropBlur = false,
  double cardBlur = 0,
  Border? cardBorder,
  List<BoxShadow>? cardShadows,
  LinearGradient? cardGradient,
  Color? cardColor,
  CardThemeData? cardTheme,
}) {
  return ThemeData(
    brightness: brightness,
    cardTheme: cardTheme ?? const CardThemeData(),
    extensions: <ThemeExtension<dynamic>>[
      UiStyleThemeExtension(
        styleFamily: styleFamily,
        useBackdropBlur: useBackdropBlur,
        cardBlur: cardBlur,
        cardBorder: cardBorder,
        cardShadows: cardShadows,
        cardGradient: cardGradient,
        cardColor: cardColor,
      ),
    ],
  );
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required ThemeData theme,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  BorderRadius? borderRadius,
  double? elevation,
  VoidCallback? onTap,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: ThemeAwareCard(
          padding: padding,
          margin: margin,
          borderRadius: borderRadius,
          elevation: elevation,
          onTap: onTap,
          child: child,
        ),
      ),
    ),
  );
}

BoxDecoration _containerDecoration(WidgetTester tester) {
  final container = tester.widgetList<Container>(find.byType(Container)).first;
  return container.decoration! as BoxDecoration;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoldenFileComparator prevComparator;
  setUpAll(() {
    prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.03,
    );
  });
  tearDownAll(() {
    goldenFileComparator = prevComparator;
  });

  testWidgets('wraps with InkWell and triggers onTap', (tester) async {
    var tapped = 0;
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.flatDesign,
      ),
      onTap: () => tapped++,
      margin: const EdgeInsets.all(8),
      child: const Text('Tap target'),
    );

    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.text('Tap target'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('uses cardTheme margin when margin is null and onTap is null', (
    tester,
  ) async {
    final theme = _theme(
      brightness: Brightness.light,
      styleFamily: UiStyleFamily.flatDesign,
      cardTheme: const CardThemeData(margin: EdgeInsets.all(12)),
    );
    await _pumpCard(
      tester,
      theme: theme,
      padding: EdgeInsets.zero,
      child: const Text('Content'),
    );

    expect(
      find.byWidgetPredicate(
        (w) => w is Padding && w.padding == const EdgeInsets.all(12),
      ),
      findsOneWidget,
    );
  });

  testWidgets('derives borderRadius from CardTheme shape when possible', (
    tester,
  ) async {
    final theme = _theme(
      brightness: Brightness.light,
      styleFamily: UiStyleFamily.flatDesign,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    await _pumpCard(tester, theme: theme, child: const Text('Content'));

    final decoration = _containerDecoration(tester);
    expect(decoration.borderRadius, BorderRadius.circular(20));
  });

  testWidgets('falls back to BorderRadius.zero for non-BorderRadius geometry', (
    tester,
  ) async {
    final theme = _theme(
      brightness: Brightness.light,
      styleFamily: UiStyleFamily.flatDesign,
      cardTheme: CardThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(18)),
        ),
      ),
    );
    await _pumpCard(tester, theme: theme, child: const Text('Content'));

    final decoration = _containerDecoration(tester);
    expect(decoration.borderRadius, BorderRadius.zero);
  });

  testWidgets('glassmorphism uses BackdropFilter when enabled', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.dark,
        styleFamily: UiStyleFamily.glassmorphism,
        useBackdropBlur: true,
        cardBlur: 12,
      ),
      child: const Text('Glass'),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('bentoGrid uses BackdropFilter when enabled', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.bentoGrid,
        useBackdropBlur: true,
        cardBlur: 8,
      ),
      elevation: 2,
      child: const Text('Bento'),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('neumorphism uses provided shadows override when set', (
    tester,
  ) async {
    final customShadows = [
      const BoxShadow(color: Colors.red, blurRadius: 3, offset: Offset(1, 2)),
    ];
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.neumorphism,
        cardShadows: customShadows,
      ),
      elevation: 1,
      child: const Text('Neumorphic'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.boxShadow, customShadows);
  });

  testWidgets('minimalism renders a border', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.minimalism,
      ),
      child: const Text('Minimal'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.border, isNotNull);
  });

  testWidgets('brutalism uses default border when no override provided', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.brutalism,
      ),
      child: const Text('Brutal'),
    );

    final decoration = _containerDecoration(tester);
    final border = decoration.border! as Border;
    expect(border.top.width, 2);
  });

  testWidgets('responsive uses default shadow derived from elevation', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.responsive,
      ),
      elevation: 2,
      child: const Text('Standard'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.boxShadow, isNotEmpty);
    expect(decoration.boxShadow!.first.blurRadius, 4);
  });

  testWidgets('flatDesign does not apply shadows or borders', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.flatDesign,
      ),
      child: const Text('Flat'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border, isNull);
  });

  testWidgets('claymorphism renders a gradient by default', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.claymorphism,
      ),
      elevation: 2,
      child: const Text('Clay'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.gradient, isNotNull);
  });

  testWidgets('skeuomorphism renders a gradient by default', (tester) async {
    await _pumpCard(
      tester,
      theme: _theme(
        brightness: Brightness.light,
        styleFamily: UiStyleFamily.skeuomorphism,
      ),
      elevation: 1,
      child: const Text('Skeuo'),
    );

    final decoration = _containerDecoration(tester);
    expect(decoration.gradient, isNotNull);
  });

  testWidgets('ThemeAwareCard_flatDesign_golden', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(
          brightness: Brightness.light,
          styleFamily: UiStyleFamily.flatDesign,
        ),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 140,
              child: ThemeAwareCard(child: Text('ThemeAwareCard')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ThemeAwareCard),
      matchesGoldenFile('goldens/theme_aware_card_flat_design.png'),
    );
  });

  testWidgets('ThemeAwareCard_brutalism_golden', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(
          brightness: Brightness.light,
          styleFamily: UiStyleFamily.brutalism,
        ),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 140,
              child: ThemeAwareCard(child: Text('ThemeAwareCard')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ThemeAwareCard),
      matchesGoldenFile('goldens/theme_aware_card_brutalism.png'),
    );
  });

  testWidgets('theme transition switches blur behavior without exceptions', (
    tester,
  ) async {
    final themeA = _theme(
      brightness: Brightness.light,
      styleFamily: UiStyleFamily.glassmorphism,
      useBackdropBlur: false,
      cardBlur: 10,
    );
    final themeB = _theme(
      brightness: Brightness.light,
      styleFamily: UiStyleFamily.glassmorphism,
      useBackdropBlur: true,
      cardBlur: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedTheme(
            duration: const Duration(milliseconds: 1000),
            data: themeA,
            child: const ThemeAwareCard(child: Text('Animated')),
          ),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedTheme(
            duration: const Duration(milliseconds: 1000),
            data: themeB,
            child: const ThemeAwareCard(child: Text('Animated')),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
