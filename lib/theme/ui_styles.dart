import 'package:flutter/material.dart';

enum UiStyleFamily {
  glassmorphism,
  neumorphism,
  claymorphism,
  minimalism,
  brutalism,
  skeuomorphism,
  bentoGrid,
  responsive,
  flatDesign,
}

String uiStyleDisplayName(UiStyleFamily style, BuildContext context) {
  switch (style) {
    case UiStyleFamily.glassmorphism:
      return 'Glassmorphism';
    case UiStyleFamily.neumorphism:
      return 'Neumorphism';
    case UiStyleFamily.claymorphism:
      return 'Claymorphism';
    case UiStyleFamily.minimalism:
      return 'Minimalism';
    case UiStyleFamily.brutalism:
      return 'Brutalism';
    case UiStyleFamily.skeuomorphism:
      return 'Skeuomorphism';
    case UiStyleFamily.bentoGrid:
      return 'Bento Grid';
    case UiStyleFamily.responsive:
      return 'Responsive';
    case UiStyleFamily.flatDesign:
      return 'Flat Design';
  }
}
