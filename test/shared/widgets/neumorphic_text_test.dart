import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/neumorphic_text.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/theme/ui_styles.dart';

ThemeData _theme({
  List<BoxShadow>? cardShadows,
  Color? cardBackgroundColor,
  Color? buttonBackgroundColor,
}) {
  return ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      UiStyleThemeExtension(
        styleFamily: UiStyleFamily.neumorphism,
        cardShadows: cardShadows,
        cardBackgroundColor: cardBackgroundColor,
        buttonBackgroundColor: buttonBackgroundColor,
      ),
    ],
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required ThemeData theme,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders Text with forwarded properties', (tester) async {
    await _pump(
      tester,
      theme: _theme(),
      child: const NeumorphicText(
        'Hello',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    final text = tester.widget<Text>(find.text('Hello'));
    expect(text.textAlign, TextAlign.center);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, 1);
  });

  testWidgets('maps styleCardShadows to text shadows and scales by depth', (
    tester,
  ) async {
    final cardShadows = [
      const BoxShadow(
        color: Color(0x11000000),
        blurRadius: 5,
        offset: Offset(1, 2),
      ),
      const BoxShadow(
        color: Color(0x22000000),
        blurRadius: 7,
        offset: Offset(-2, -1),
      ),
    ];

    await _pump(
      tester,
      theme: _theme(cardShadows: cardShadows),
      child: const NeumorphicText('Shadow', depth: 2),
    );

    final text = tester.widget<Text>(find.text('Shadow'));
    final style = text.style;
    expect(style, isNotNull);
    expect(style!.shadows, isNotNull);
    expect(style.shadows, hasLength(2));

    final s0 = style.shadows![0];
    expect(s0.color, cardShadows[0].color);
    expect(s0.offset, cardShadows[0].offset);
    expect(s0.blurRadius, cardShadows[0].blurRadius * 2);

    final s1 = style.shadows![1];
    expect(s1.color, cardShadows[1].color);
    expect(s1.offset, cardShadows[1].offset);
    expect(s1.blurRadius, cardShadows[1].blurRadius * 2);
  });

  testWidgets('depth <= 0 produces zero-blur shadows', (tester) async {
    final cardShadows = [
      const BoxShadow(
        color: Color(0x33000000),
        blurRadius: 10,
        offset: Offset(0, 1),
      ),
    ];

    await _pump(
      tester,
      theme: _theme(cardShadows: cardShadows),
      child: const NeumorphicText('Depth', depth: 0),
    );

    final text = tester.widget<Text>(find.text('Depth'));
    final style = text.style;
    expect(style, isNotNull);
    expect(style!.shadows, isNotNull);
    expect(style.shadows, hasLength(1));
    expect(style.shadows!.first.blurRadius, 0);
  });

  testWidgets(
    'useNeumorphicColor uses cardBackgroundColor then buttonBackgroundColor then surface',
    (tester) async {
      await _pump(
        tester,
        theme: _theme(
          cardBackgroundColor: const Color(0xFF111111),
          buttonBackgroundColor: const Color(0xFF222222),
        ),
        child: const NeumorphicText('Color', useNeumorphicColor: true),
      );
      var text = tester.widget<Text>(find.text('Color'));
      expect(text.style?.color, const Color(0xFF111111));

      await _pump(
        tester,
        theme: _theme(buttonBackgroundColor: const Color(0xFF222222)),
        child: const NeumorphicText('Color', useNeumorphicColor: true),
      );
      text = tester.widget<Text>(find.text('Color'));
      expect(text.style?.color, const Color(0xFF222222));

      final fallbackTheme = _theme();
      await _pump(
        tester,
        theme: fallbackTheme,
        child: const NeumorphicText('Color', useNeumorphicColor: true),
      );
      text = tester.widget<Text>(find.text('Color'));
      expect(text.style?.color, fallbackTheme.colorScheme.surface);
    },
  );

  testWidgets(
    'does not override provided style color when useNeumorphicColor is false',
    (tester) async {
      await _pump(
        tester,
        theme: _theme(cardBackgroundColor: const Color(0xFF111111)),
        child: const NeumorphicText(
          'Styled',
          style: TextStyle(color: Colors.red),
          useNeumorphicColor: false,
        ),
      );

      final text = tester.widget<Text>(find.text('Styled'));
      expect(text.style?.color, Colors.red);
    },
  );
}
