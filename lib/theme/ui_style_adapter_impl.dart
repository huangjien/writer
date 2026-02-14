import 'package:flutter/material.dart';
import 'package:writer/theme/style_theme_patch.dart';
import 'ui_styles.dart';

class UiStyleAdapter {
  const UiStyleAdapter();

  StyleThemePatch resolveStylePatch(UiStyleFamily style) {
    switch (style) {
      case UiStyleFamily.glassmorphism:
        return _glassmorphismPatch();
      case UiStyleFamily.liquidGlass:
        return _liquidGlassPatch();
      case UiStyleFamily.neumorphism:
        return _neumorphismPatch();
      case UiStyleFamily.minimalism:
        return _minimalismPatch();
      case UiStyleFamily.flatDesign:
        return _flatDesignPatch();
    }
  }

  StyleThemePatch _glassmorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: BorderRadius.all(Radius.circular(12)),
      elevation: 0,
      useBackdropBlur: true,
      cardBlur: 16,
      cardShadows: [
        BoxShadow(
          color: Color(0x1A1F2387),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x19FFFFFF), Color(0x0DFFFFFF)],
      ),
      styleFamily: UiStyleFamily.glassmorphism,
    );
  }

  StyleThemePatch _liquidGlassPatch() {
    return StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: const BorderRadius.all(Radius.circular(14)),
      elevation: 0,
      useBackdropBlur: true,
      cardBlur: 24,
      cardShadows: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 36,
          offset: Offset(0, 12),
        ),
        BoxShadow(
          color: Color(0x1A1F2387),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
      cardBorder: Border.all(color: const Color(0x33FFFFFF), width: 1),
      cardGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
      ),
      styleFamily: UiStyleFamily.liquidGlass,
      dropdownBackgroundColor: const Color(0x1AFFFFFF),
      dropdownBorder: Border.all(color: const Color(0x26FFFFFF), width: 1),
      dropdownBorderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  StyleThemePatch _neumorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.neumorphism,
      inputBorderRadius: BorderRadius.all(Radius.circular(12)),
      inputFocusedBorderColor: Color(0xFF6366F1),
      dropdownBackgroundColor: null,
      dropdownBorder: null,
      dropdownBorderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  StyleThemePatch _minimalismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: BorderRadius.all(Radius.circular(8)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.minimalism,
      buttonBackgroundColor: Color(0xFFFAFAFA),
      buttonShadows: [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
      buttonPressedColor: Color(0xFFF0F0F0),
      cardBackgroundColor: Color(0xFFFAFAFA),
      cardPressedColor: Color(0xFFF0F0F0),
      inputBackgroundColor: Color(0xFFF5F5F5),
      inputBorderRadius: BorderRadius.all(Radius.circular(8)),
      inputFocusedBorderColor: Color(0xFF6366F1),
      switchBackgroundColor: Color(0xFFE0E0E0),
      switchThumbColor: Color(0xFFFFFFFF),
      dropdownBackgroundColor: null,
      dropdownBorderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  StyleThemePatch _flatDesignPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: BorderRadius.all(Radius.circular(4)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.flatDesign,
      buttonBackgroundColor: null,
      buttonPressedColor: null,
      cardBackgroundColor: null,
      inputBackgroundColor: null,
      inputBorderRadius: BorderRadius.all(Radius.circular(4)),
      inputFocusedBorderColor: null,
      switchBackgroundColor: null,
      switchThumbColor: null,
      dropdownBackgroundColor: null,
      dropdownBorderRadius: BorderRadius.all(Radius.circular(4)),
    );
  }
}
