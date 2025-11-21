import 'package:flutter/material.dart';

enum ReaderBackgroundDepth { low, medium, high }

Color readerBackgroundColor(ColorScheme scheme, ReaderBackgroundDepth depth) {
  switch (depth) {
    case ReaderBackgroundDepth.low:
      // Slightly tinted, close to neutral surface
      return scheme.surface;
    case ReaderBackgroundDepth.medium:
      // Noticeably tinted
      return scheme.surfaceContainerHigh;
    case ReaderBackgroundDepth.high:
      // Most pronounced tint
      return scheme.surfaceContainerHighest;
  }
}
