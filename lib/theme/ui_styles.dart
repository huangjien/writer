import 'package:flutter/material.dart';

enum UiStyleFamily {
  minimalism,
  glassmorphism,
  liquidGlass,
  neumorphism,
  flatDesign,
}

String uiStyleDisplayName(UiStyleFamily style, BuildContext context) {
  switch (style) {
    case UiStyleFamily.minimalism:
      return 'Minimalism';
    case UiStyleFamily.glassmorphism:
      return 'Glassmorphism';
    case UiStyleFamily.liquidGlass:
      return 'Liquid Glass';
    case UiStyleFamily.neumorphism:
      return 'Neumorphism';
    case UiStyleFamily.flatDesign:
      return 'Flat Design';
  }
}
